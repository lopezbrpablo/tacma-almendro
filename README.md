# Modelización de la incidencia de una enfermedad fúngica en almendro

Materiales del estudio de la incidencia de una enfermedad fúngica en hojas de almendro (*Prunus dulcis*) en función de la temperatura, el periodo de humectación y el aislado del patógeno.

## Autoría

- **Informe científico (octubre de 2026):** Sofía Cerezo y Pablo López.
- **Análisis estadístico de referencia, TACMA Caso 1 (junio de 2026):** Rafael Casajús, Qihang Chen y Pablo López.

## Estudio

El experimento se desarrolló bajo condiciones controladas de temperatura (5–35 °C) y humectación (6–72 h), con dos aislados del patógeno y distintas réplicas experimentales. La incidencia observada se calcula como la proporción de hojas dañadas respecto al total de hojas evaluadas por planta.

El análisis incluye modelos binomiales y beta-binomiales, efectos no lineales de temperatura, interacciones con el periodo de humectación, diagnósticos de residuos, validación cruzada y una comparación bayesiana.

## Contenido del repositorio

| Directorio | Contenido |
|---|---|
| [`datos/`](datos/) | Conjunto de datos experimental `caso1.RData`. |
| [`codigo/`](codigo/) | Código R y JAGS correspondiente al análisis estadístico. |
| [`figuras/`](figuras/) | Siete figuras del análisis, identificadas según la numeración del TACMA original. |
| [`informe/`](informe/) | Informe científico en LaTeX y su versión PDF, cuando se incorpore la versión definitiva. |

El informe científico se entrega en formato PDF a través del aula virtual. Este repositorio reúne los materiales asociados al estudio y se referencia desde dicho documento.

## Herramientas

El análisis estadístico utiliza R, con paquetes como `mgcv`, `glmmTMB`, `DHARMa`, `dplyr`, `splines` y `R2jags`, además de JAGS para la modelización bayesiana. La documentación del código se encuentra en [`codigo/README.md`](codigo/README.md).

## Uso y atribución

La autoría de los materiales se indica en los apartados anteriores. No se ha incorporado una licencia de reutilización al repositorio.
