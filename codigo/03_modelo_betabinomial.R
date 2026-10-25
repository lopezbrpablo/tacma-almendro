# TACMA Caso 1 — 03: modelo beta-binomial
# Ejecutar desde la raíz del repositorio.

source("codigo/01_preparacion.R")
if (!requireNamespace("glmmTMB", quietly = TRUE)) stop("Instala 'glmmTMB'.")
if (!requireNamespace("splines", quietly = TRUE)) stop("Falta 'splines'.")
if (!requireNamespace("DHARMa", quietly = TRUE)) stop("Instala 'DHARMa'.")
library(glmmTMB)
library(splines)
library(DHARMa)

mbb <- glmmTMB(
  cbind(damaged_leaves, undamaged_leaves) ~
    wet_c * isol +
    ns(temp, df = 5) +
    ns(temp, df = 5):wet_c:isol +
    (1 | replicate),
  family = betabinomial(link = "logit"),
  data = datos
)
print(summary(mbb))
print(AIC(mbb))

res_bb <- simulateResiduals(mbb)
print(testDispersion(res_bb))
print(testZeroInflation(res_bb))
print(testUniformity(res_bb))
