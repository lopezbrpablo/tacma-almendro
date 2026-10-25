# Modelización de la incidencia de una enfermedad fúngica en almendro

Repositorio de materiales para un informe científico de bioestadística sobre la incidencia de una enfermedad fúngica en hojas de almendro (*Prunus dulcis*) en función de la temperatura, el periodo de humectación y el aislado del patógeno.

## Autoría y procedencia

- **Informe de síntesis (octubre de 2026):** Sofía Cerezo y Pablo López.
- **Trabajo estadístico de referencia (TACMA Caso 1, junio de 2026):** Rafael Casajús, Qihang Chen y Pablo López.

El informe de síntesis se basa en un análisis previo; no supone que los modelos se hayan reajustado durante la elaboración del informe. Se distinguirán siempre los resultados originales de cualquier análisis adicional que se realice posteriormente.

## Datos y enfoque estadístico

La unidad observacional es la planta. Se dispone del número de hojas dañadas (`damaged_leaves`) y del total de hojas evaluadas (`total_leaves`); su cociente define la incidencia observada. Las principales variables explicativas son la temperatura (`temp`), la humectación (`wet`), el aislado (`isol`) y la réplica experimental (`replicate`).

El análisis de referencia compara modelos binomiales y beta-binomiales, contempla relaciones no lineales e interacciones, utiliza diagnósticos de residuos y validación cruzada, e incluye una comparación bayesiana mediante JAGS.

## Organización

```text
tacma-almendro/
├── README.md
├── datos/       # Datos originales
├── codigo/      # Scripts R y modelos JAGS, pendientes de incorporar
├── figuras/     # Figuras generadas a partir del análisis
├── informe/     # Fuente LaTeX e informe final
└── .gitignore
```

## Estado de reproducibilidad

**Repositorio en preparación.** Esta primera versión contiene la estructura y la documentación, pero no incluye todavía el archivo original `caso1.RData`, scripts completos ni resultados reproducidos. No se debe afirmar que el análisis sea reproducible hasta disponer de estos materiales y verificar su ejecución.

Para completar el repositorio:

1. Incorporar los scripts originales de R/JAGS, conservando su autoría y comprobando los derechos de redistribución.
2. Documentar los paquetes y versiones de R usados.
3. Decidir si el fichero de datos se puede distribuir; si no, explicar cómo obtenerlo.
4. Generar y contrastar las figuras y los resultados a partir de una ejecución comprobada.
5. Exportar el `.tex` vigente desde Overleaf e incorporar el PDF definitivo.

## Licencia y uso de materiales

No se incluye una licencia de código o datos en esta versión inicial. Antes de hacer público el repositorio, comprobar los permisos de difusión de datos, scripts, figuras y materiales realizados por otros coautores.
