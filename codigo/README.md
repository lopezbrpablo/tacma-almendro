# Código estadístico (R / JAGS)

Este directorio contiene una **transcripción adaptada** del código que aparece en el anexo A.2 (pp. 12–31) de *TACMA Caso 1*, elaborado originalmente por Rafael Casajús, Qihang Chen y Pablo López. Se ha separado en seis scripts para facilitar la lectura y ejecución. **Todavía no se ha comprobado su ejecución**: el archivo original `caso1.RData` no está disponible en esta entrega y no se ha podido instalar/ejecutar R/JAGS en este entorno.

## Orden y procedencia

| Script | Contenido | Páginas del informe original |
|---|---|---|
| `01_preparacion.R` | Carga y preparación de los datos | 12 |
| `02_modelos_binomiales.R` | GAM binomiales `m1`, `m1c`, `m1d`, `m1f`; diagnósticos | 12–19 |
| `03_modelo_betabinomial.R` | Modelo `mbb` y diagnósticos DHARMa | 19–21 |
| `04_validacion_cruzada.R` | Validación cruzada en 5 particiones | 21–23 |
| `05_bayes_binomial.R` | Modelo bayesiano binomial JAGS | 23–27 |
| `06_bayes_betabinomial.R` | Modelo bayesiano beta-binomial JAGS | 27–31 |

## Requisitos

- R con paquetes `mgcv`, `glmmTMB`, `DHARMa`, `dplyr`, `splines` (base/recommended R) y `R2jags` (solo para los modelos bayesianos).
- **JAGS instalado en el sistema**, además del paquete de R `R2jags`, para los scripts 05 y 06.
- Archivo **`datos/caso1.RData`**, con un objeto llamado `caso1` y las columnas `damaged_leaves`, `undamaged_leaves`, `total_leaves`, `temp`, `wet`, `isol`, `replicate`.
- Ejecutar **desde la raíz del repositorio** (cada script hace `source("codigo/01_preparacion.R")` o carga el modelo previo que necesita).

Por ejemplo:

```r
install.packages(c("mgcv", "glmmTMB", "DHARMa", "dplyr", "R2jags"))
source("codigo/02_modelos_binomiales.R")
source("codigo/03_modelo_betabinomial.R")
source("codigo/04_validacion_cruzada.R")
```

Para los modelos JAGS, una vez instalado JAGS en el sistema:

```r
source("codigo/05_bayes_binomial.R")
source("codigo/06_bayes_betabinomial.R")
```

Son ajustes costosos; no deben ejecutarse para una simple consulta del informe.

## Adaptaciones respecto al PDF

- Sustitución de caracteres tipográficos del PDF (`∼` por `~`, comillas curvas por comillas de R, etc.), corrección de saltos de línea y escritura de cadenas JAGS legibles.
- Inclusión de imports y comprobaciones mínimas de archivos y columnas; `R2jags` era una dependencia implícita porque el anexo utiliza la función `jags()` sin cargar explícitamente ese paquete.
- Sustitución del aparente error tipográfico `roundround(...)` por `round(...)` en el modelo bayesiano binomial.
- Los modelos, estructuras de efectos y priors de JAGS se han preservado según figuran en el anexo. Los scripts no se deben considerar **copias literales del código fuente original** ni reproducibilidad demostrada hasta contrastarlos con los originales y ejecutarlos sobre los datos.
- El PDF contiene gráficos pero **no incluye el código completo para generar todas las figuras exploratorias**; esa parte permanece pendiente.

## Comprobaciones pendientes

1. Comparar estos scripts contra los archivos `.R` utilizados en el TACMA original si aún existen.
2. Ejecutar los ajustes sobre `caso1.RData` y verificar AIC, parámetros, resultados de validación cruzada, DIC y estabilidad de cadenas.
3. Registrar versiones de R, paquetes y JAGS (`sessionInfo()`). Las pruebas DHARMa dependen de simulaciones y pueden producir valores diferentes.
4. Verificar la convergencia del modelo beta-binomial bayesiano: la tabla original muestra `Rhat` = 1,15 para `sigma_rep` y hasta 1,19 para algunos `u_rep`, por lo que no debe afirmarse convergencia satisfactoria para **todos** los parámetros.
5. Revisar el valor del DIC binomial citado en la versión abreviada del informe: el anexo original indica **3648,038** (no 3648,6).
6. Comprobar permisos para publicar código y datos originales antes de cambiar el repositorio a público.

## Datos

El archivo `datos/caso1.RData` no se incluye aquí. Además, el `.gitignore` del repositorio inicial excluye `datos/` por precaución. No modificar esa exclusión ni publicar los datos sin confirmar antes el permiso de redistribución.
