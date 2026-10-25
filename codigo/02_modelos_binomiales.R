# TACMA Caso 1 — 02: modelos binomiales GAM
# Transcripción adaptada del anexo A.2.2 (pp. 12-19).
# Ejecutar desde la raíz del repositorio.

source("codigo/01_preparacion.R")
if (!requireNamespace("mgcv", quietly = TRUE)) stop("Instala el paquete 'mgcv'.")
if (!requireNamespace("DHARMa", quietly = TRUE)) stop("Instala el paquete 'DHARMa'.")
library(mgcv)
library(DHARMa)

m1 <- gam(
  cbind(damaged_leaves, undamaged_leaves) ~
    wet * isol +
    s(temp, by = isol, bs = "tp", k = 6) +
    ti(temp, wet, by = isol) +
    s(replicate, bs = "re"),
  family = binomial(link = "logit"),
  method = "REML", data = datos
)
print(summary(m1))
gam.check(m1)
concurvity(m1)
print(AIC(m1))

m1c <- gam(
  cbind(damaged_leaves, undamaged_leaves) ~
    wet_c * isol +
    s(temp, by = isol, bs = "tp", k = 6) +
    ti(temp, wet_c, by = isol) +
    s(replicate, bs = "re"),
  family = binomial(link = "logit"),
  method = "REML", data = datos
)
print(summary(m1c))
concurvity(m1c)
print(AIC(m1c))

m1d <- gam(
  cbind(damaged_leaves, undamaged_leaves) ~
    wet_c * isol +
    s(temp, by = isol, bs = "tp", k = 6) +
    ti(temp, wet_c) +
    s(replicate, bs = "re"),
  family = binomial(link = "logit"),
  method = "REML", data = datos
)
print(summary(m1d))
print(AIC(m1d))

# Las pruebas DHARMa son basadas en simulación; sus p-valores pueden variar.
res_m1c <- simulateResiduals(m1c)
print(testDispersion(res_m1c))
print(testZeroInflation(res_m1c))
print(testUniformity(res_m1c))

# Efecto aleatorio adicional para combinación experimental.
datos$condID <- interaction(
  datos$isol, datos$replicate, datos$temp, datos$wet,
  drop = TRUE
)
m1f <- gam(
  cbind(damaged_leaves, undamaged_leaves) ~
    wet_c * isol +
    s(temp, by = isol, bs = "tp", k = 6) +
    ti(temp, wet_c, by = isol) +
    s(replicate, bs = "re") +
    s(condID, bs = "re"),
  family = binomial(link = "logit"),
  method = "REML", data = datos
)
print(summary(m1f))
print(AIC(m1c, m1f))
concurvity(m1f)

res_m1f <- simulateResiduals(m1f)
print(testDispersion(res_m1f))
print(testZeroInflation(res_m1f))
print(testUniformity(res_m1f))
