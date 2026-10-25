# TACMA Caso 1 — 06: formulación bayesiana beta-binomial (JAGS)
# Exige instalación independiente de JAGS y el paquete R2jags

source("codigo/01_preparacion.R")
if (!requireNamespace("mgcv", quietly = TRUE)) stop("Instala 'mgcv'.")
if (!requireNamespace("R2jags", quietly = TRUE)) stop("Instala 'R2jags' y JAGS.")
library(mgcv)
library(splines)
library(R2jags)

datos <- na.omit(datos)
N <- nrow(datos)
n_reps <- length(levels(datos$replicate))
isol_num <- as.integer(datos$isol) - 1L
rep_idx <- as.integer(datos$replicate)

cat("N =", N, "| n_reps =", n_reps, "\n")
cat("Niveles isol:", levels(datos$isol), "\n")

ns_obj <- ns(datos$temp, df = 5)
ns_raw <- unname(ns_obj)
ns_scale <- scale(ns_raw)
ns_temp <- unname(ns_scale)

# Bases escaladas: interacción específica por aislado
Z_iref <- unname(ns_temp * datos$wet_c * (1 - isol_num))
Z_ialt <- unname(ns_temp * datos$wet_c * isol_num)
X_param <- unname(cbind(1, datos$wet_c, isol_num,
                        datos$wet_c * isol_num))
stopifnot(ncol(X_param) == 4L)
stopifnot(all(c(nrow(X_param), nrow(ns_temp), nrow(Z_iref),
                nrow(Z_ialt)) == N))

# Modelo auxiliar para los valores iniciales del muestreador
d_aux <- cbind(
  datos,
  setNames(as.data.frame(ns_temp), paste0("ns", 1:5)),
  setNames(as.data.frame(Z_iref), paste0("ir", 1:5)),
  setNames(as.data.frame(Z_ialt), paste0("ia", 1:5))
)

m_aux <- gam(
  cbind(damaged_leaves, undamaged_leaves) ~
    wet_c * isol +
    ns1 + ns2 + ns3 + ns4 + ns5 +
    ir1 + ir2 + ir3 + ir4 + ir5 +
    ia1 + ia2 + ia3 + ia4 + ia5 +
    s(replicate, bs = "re"),
  family = binomial(link = "logit"), data = d_aux
)

coef_aux <- coef(m_aux)
idx_param <- match(
  c("(Intercept)", "wet_c", "isolphal_45", "wet_c:isolphal_45"),
  names(coef_aux)
)
idx_ns <- grep("^ns[1-5]$", names(coef_aux))
idx_ir <- grep("^ir", names(coef_aux))
idx_ia <- grep("^ia", names(coef_aux))

# Evita iniciar JAGS con coeficientes ausentes por nombres distintos
stopifnot(!anyNA(idx_param), length(idx_ns) == 5L,
          length(idx_ir) == 5L, length(idx_ia) == 5L)

modelo_jags <- sprintf('
model {
  for (i in 1:N) {
    eta[i] <- inprod(X_param[i, 1:%d], beta[1:%d])
            + inprod(ns_temp[i, 1:%d], alpha_ns[1:%d])
            + inprod(Z_iref[i, 1:%d], gamma_ref[1:%d])
            + inprod(Z_ialt[i, 1:%d], gamma_alt[1:%d])
            + u_rep[rep_idx[i]]

    mu[i] <- exp(eta[i]) / (1 + exp(eta[i]))
    a_bb[i] <- max(mu[i] * phi, 0.001)
    b_bb[i] <- max((1 - mu[i]) * phi, 0.001)

    p[i] ~ dbeta(a_bb[i], b_bb[i])
    y[i] ~ dbin(p[i], n[i])
  }

  beta[1] ~ dnorm(0, 0.01)
  beta[2] ~ dnorm(0, 0.01)
  beta[3] ~ dnorm(0, 0.01)
  beta[4] ~ dnorm(0, 0.01)

  for (j in 1:%d) { alpha_ns[j] ~ dnorm(0, 0.01) }
  for (j in 1:%d) { gamma_ref[j] ~ dnorm(0, 0.01) }
  for (j in 1:%d) { gamma_alt[j] ~ dnorm(0, 0.01) }

  phi ~ dgamma(2, 0.1)
  tau_rep ~ dgamma(1, 0.001)
  sigma_rep <- 1 / sqrt(tau_rep)
  for (r in 1:n_reps) { u_rep[r] ~ dnorm(0, tau_rep) }
}',
  4L, 4L,
  5L, 5L,
  5L, 5L,
  5L, 5L,
  5L, 5L, 5L
)

datos_jags <- list(
  N = N,
  n_reps = n_reps,
  y = datos$damaged_leaves,
  n = datos$total_leaves,
  rep_idx = rep_idx,
  X_param = X_param,
  ns_temp = ns_temp,
  Z_iref = Z_iref,
  Z_ialt = Z_ialt
)

inits_fun <- function() list(
  beta = as.numeric(coef_aux[idx_param]) + rnorm(4, 0, 0.01),
  alpha_ns = as.numeric(coef_aux[idx_ns]) + rnorm(5, 0, 0.01),
  gamma_ref = as.numeric(coef_aux[idx_ir]) + rnorm(5, 0, 0.01),
  gamma_alt = as.numeric(coef_aux[idx_ia]) + rnorm(5, 0, 0.01),
  phi = rgamma(1, 2, 0.1),
  tau_rep = rgamma(1, 1, 0.001)
)

params_monitor <- c(
  "beta", "alpha_ns", "gamma_ref", "gamma_alt", "phi", "sigma_rep", "u_rep"
)

set.seed(123)
m_bb_bayes <- jags(
  data = datos_jags,
  inits = inits_fun,
  parameters.to.save = params_monitor,
  model.file = textConnection(modelo_jags),
  n.chains = 3,
  n.iter = 15000,
  n.burnin = 3000,
  n.thin = 5,
  parallel = FALSE,
  verbose = TRUE
)
print(round(as.data.frame(m_bb_bayes$summary[, c(1, 2, 3, 7, 8, 9)]), 2))
print(m_bb_bayes$DIC)
