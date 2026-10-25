# TACMA Caso 1 — 05: formulación bayesiana binomial (JAGS)
# Exige instalación independiente de JAGS y el paquete R2jags.

source("codigo/02_modelos_binomiales.R")
if (!requireNamespace("R2jags", quietly = TRUE)) stop("Instala 'R2jags' y JAGS.")
library(R2jags)

# Matriz de diseño obtenida del GAM frecuentista
datos <- na.omit(datos)
N <- nrow(datos)
n_reps <- length(levels(datos$replicate))
isol_niveles <- levels(datos$isol)
isol_ref <- isol_niveles[1]
isol_alt <- isol_niveles[2]
rep_idx <- as.integer(datos$replicate)

X_full <- predict(m1c, type = "lpmatrix")
col_names <- colnames(X_full)
idx_param <- which(col_names %in% c(
  "(Intercept)", "wet_c", paste0("isol", isol_alt),
  paste0("wet_c:isol", isol_alt)
))
idx_sref <- grep(paste0("s\\(temp\\):isol", isol_ref, "\\."), col_names)
idx_salt <- grep(paste0("s\\(temp\\):isol", isol_alt, "\\."), col_names)
idx_tiref <- grep(paste0("ti\\(temp,wet_c\\):isol", isol_ref, "\\."), col_names)
idx_tialt <- grep(paste0("ti\\(temp,wet_c\\):isol", isol_alt, "\\."), col_names)

X_param <- unname(X_full[, idx_param, drop = FALSE])
Z_sref <- unname(X_full[, idx_sref, drop = FALSE])
Z_salt <- unname(X_full[, idx_salt, drop = FALSE])
Z_tiref <- unname(X_full[, idx_tiref, drop = FALSE])
Z_tialt <- unname(X_full[, idx_tialt, drop = FALSE])

k_sref <- ncol(Z_sref)
k_salt <- ncol(Z_salt)
k_tiref <- ncol(Z_tiref)
k_tialt <- ncol(Z_tialt)

stopifnot(ncol(X_param) == 4L)
stopifnot(all(c(nrow(X_param), nrow(Z_sref), nrow(Z_salt),
                nrow(Z_tiref), nrow(Z_tialt)) == N))

modelo_jags <- sprintf('
model {
  for (i in 1:N) {
    eta[i] <- inprod(X_param[i, 1:%d], beta[1:%d])
            + inprod(Z_sref[i, 1:%d], gamma_sref[1:%d])
            + inprod(Z_salt[i, 1:%d], gamma_salt[1:%d])
            + inprod(Z_tiref[i, 1:%d], gamma_tiref[1:%d])
            + inprod(Z_tialt[i, 1:%d], gamma_tialt[1:%d])
            + u_rep[rep_idx[i]]

    mu[i] <- exp(eta[i]) / (1 + exp(eta[i]))
    y[i] ~ dbin(mu[i], n[i])
  }

  beta[1] ~ dnorm(0, 0.01)
  beta[2] ~ dnorm(0, 0.01)
  beta[3] ~ dnorm(0, 0.01)
  beta[4] ~ dnorm(0, 0.01)

  tau_sref ~ dgamma(1, 0.005)
  for (j in 1:%d) { gamma_sref[j] ~ dnorm(0, tau_sref) }

  tau_salt ~ dgamma(1, 0.005)
  for (j in 1:%d) { gamma_salt[j] ~ dnorm(0, tau_salt) }

  tau_tiref ~ dgamma(1, 0.005)
  for (j in 1:%d) { gamma_tiref[j] ~ dnorm(0, tau_tiref) }

  tau_tialt ~ dgamma(1, 0.005)
  for (j in 1:%d) { gamma_tialt[j] ~ dnorm(0, tau_tialt) }

  tau_rep ~ dgamma(1, 0.001)
  sigma_rep <- 1 / sqrt(tau_rep)
  for (r in 1:n_reps) { u_rep[r] ~ dnorm(0, tau_rep) }
}',
  4L, 4L,
  k_sref, k_sref,
  k_salt, k_salt,
  k_tiref, k_tiref,
  k_tialt, k_tialt,
  k_sref, k_salt, k_tiref, k_tialt
)

coef_aux <- coef(m1c)
datos_jags <- list(
  N = N,
  n_reps = n_reps,
  y = datos$damaged_leaves,
  n = datos$total_leaves,
  rep_idx = rep_idx,
  X_param = X_param,
  Z_sref = Z_sref,
  Z_salt = Z_salt,
  Z_tiref = Z_tiref,
  Z_tialt = Z_tialt
)

inits_fun <- function() list(
  beta = as.numeric(coef_aux[idx_param]) + rnorm(4, 0, 0.05),
  gamma_sref = as.numeric(coef_aux[idx_sref]) + rnorm(k_sref, 0, 0.05),
  gamma_salt = as.numeric(coef_aux[idx_salt]) + rnorm(k_salt, 0, 0.05),
  gamma_tiref = as.numeric(coef_aux[idx_tiref]) + rnorm(k_tiref, 0, 0.05),
  gamma_tialt = as.numeric(coef_aux[idx_tialt]) + rnorm(k_tialt, 0, 0.05),
  tau_rep = rgamma(1, 1, 0.001),
  tau_sref = rgamma(1, 1, 0.005),
  tau_salt = rgamma(1, 1, 0.005),
  tau_tiref = rgamma(1, 1, 0.005),
  tau_tialt = rgamma(1, 1, 0.005)
)

params_monitor <- c(
  "beta", "gamma_sref", "gamma_salt", "gamma_tiref", "gamma_tialt",
  "sigma_rep", "tau_sref", "tau_salt", "tau_tiref", "tau_tialt",
  "u_rep", "mu"
)

set.seed(123)
m1c_bayes <- jags(
  data = datos_jags,
  inits = inits_fun,
  parameters.to.save = params_monitor,
  model.file = textConnection(modelo_jags),
  n.chains = 3,
  n.iter = 30000,
  n.burnin = 3000,
  n.thin = 5,
  parallel = FALSE,
  verbose = TRUE
)

print(round(as.data.frame(m1c_bayes$summary[1:55, c(1, 2, 3, 7, 8, 9)]), 2))
print(m1c_bayes$DIC)
