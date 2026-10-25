# TACMA Caso 1 — 04: validación cruzada de cinco particiones
# Transcripción adaptada del anexo A.2.4 (pp. 21-23).
# Ejecutar desde la raíz del repositorio.

source("codigo/01_preparacion.R")
if (!requireNamespace("mgcv", quietly = TRUE)) stop("Instala 'mgcv'.")
if (!requireNamespace("glmmTMB", quietly = TRUE)) stop("Instala 'glmmTMB'.")
library(mgcv)
library(glmmTMB)
library(splines)
if (!requireNamespace("dplyr", quietly = TRUE)) stop("Instala 'dplyr'.")

set.seed(123)
K <- 5
datos$fold <- sample(rep(seq_len(K), length.out = nrow(datos)))

logLik_bb <- function(y, n, mu, phi) {
  mu <- pmin(pmax(mu, 1e-8), 1 - 1e-8)
  phi <- as.numeric(phi)
  alpha <- mu * phi
  beta <- (1 - mu) * phi

  lgamma(n + 1) - lgamma(y + 1) - lgamma(n - y + 1) +
    lbeta(y + alpha, n - y + beta) -
    lbeta(alpha, beta)
}

cv_res <- data.frame(
  fold = seq_len(K),
  logLik_binomial = NA_real_,
  logLik_betabinomial = NA_real_
)

for (k in seq_len(K)) {
  train <- datos[datos$fold != k, ]
  test <- datos[datos$fold == k, ]
  test <- dplyr::filter(test,
    !is.na(damaged_leaves), !is.na(undamaged_leaves)
  )

  m_bin <- gam(
    cbind(damaged_leaves, undamaged_leaves) ~
      wet_c * isol +
      s(temp, by = isol, bs = "tp", k = 6) +
      ti(temp, wet_c, by = isol) +
      s(replicate, bs = "re"),
    family = binomial(link = "logit"),
    method = "REML", data = train
  )

  m_bb <- glmmTMB(
    cbind(damaged_leaves, undamaged_leaves) ~
      wet_c * isol +
      ns(temp, df = 5) +
      ns(temp, df = 5):wet_c:isol +
      (1 | replicate),
    family = betabinomial(link = "logit"), data = train
  )

  y <- test$damaged_leaves
  n <- test$damaged_leaves + test$undamaged_leaves

  p_bin <- predict(m_bin, newdata = test, type = "response")
  p_bb <- predict(m_bb, newdata = test, type = "response",
                  allow.new.levels = TRUE)

  p_bin <- pmin(pmax(p_bin, 1e-8), 1 - 1e-8)
  p_bb <- pmin(pmax(p_bb, 1e-8), 1 - 1e-8)

  cv_res$logLik_binomial[k] <- sum(
    dbinom(y, size = n, prob = p_bin, log = TRUE)
  )
  cv_res$logLik_betabinomial[k] <- sum(
    logLik_bb(y, n, p_bb, sigma(m_bb))
  )
}

print(cv_res)
print(colSums(cv_res[, c("logLik_binomial", "logLik_betabinomial")]))
