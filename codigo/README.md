# Código estadístico (R y JAGS)

Este directorio contiene el código del **TACMA Caso 1**, cuyo análisis estadístico fue elaborado por **Rafael Casajús, Qihang Chen y Pablo López** (junio de 2026). Los scripts se organizan por fases del estudio y acompañan los resultados recogidos en el informe científico de **Sofía Cerezo y Pablo López** (octubre de 2026).

## Organización

| Archivo | Contenido |
|---|---|
| `01_preparacion.R` | Carga de datos y preparación de las variables. |
| `02_modelos_binomiales.R` | Modelos GAM binomiales (`m1`, `m1c`, `m1d`, `m1f`) y diagnósticos. |
| `03_modelo_betabinomial.R` | Modelo beta-binomial (`mbb`) y diagnósticos con DHARMa. |
| `04_validacion_cruzada.R` | Comparación predictiva mediante validación cruzada de cinco particiones. |
| `05_bayes_binomial.R` | Modelo binomial bayesiano con JAGS. |
| `06_bayes_betabinomial.R` | Modelo beta-binomial bayesiano con JAGS. |

## Datos

El archivo [`caso1.RData`](../datos/caso1.RData), ubicado en `datos/`, contiene las observaciones del experimento. La unidad de observación es la planta, y la incidencia se define como el número de hojas dañadas dividido entre el total de hojas evaluadas.

| Variable | Descripción |
|---|---|
| `damaged_leaves` | Número de hojas dañadas. |
| `undamaged_leaves` | Número de hojas no dañadas. |
| `total_leaves` | Número total de hojas evaluadas. |
| `temp` | Temperatura experimental (°C). |
| `wet` | Periodo de humectación (horas). |
| `isol` | Aislado del patógeno. |
| `replicate` | Réplica experimental. |

## Herramientas y métodos

El análisis está desarrollado en **R** y emplea los paquetes `mgcv`, `glmmTMB`, `DHARMa`, `dplyr`, `splines` y `R2jags`, junto con **JAGS** para los modelos bayesianos.

Se consideran distribuciones binomial y beta-binomial, relaciones no lineales mediante funciones suaves o splines, efectos e interacciones de las condiciones ambientales y efectos asociados a la estructura experimental. La comparación incluye criterios de información, diagnósticos y validación predictiva.

Las figuras correspondientes se encuentran en [`../figuras/`](../figuras/).
