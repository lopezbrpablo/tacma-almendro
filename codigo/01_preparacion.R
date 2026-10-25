# TACMA Caso 1 — 01: preparación de datos
# Ejecutar desde la raíz del repositorio: source("codigo/01_preparacion.R")

ruta_datos <- file.path("datos", "caso1.RData")
if (!file.exists(ruta_datos)) {
  stop("No se encuentra datos/caso1.RData. Añade el archivo original antes de ejecutar.")
}

env_datos <- new.env(parent = emptyenv())
load(ruta_datos, envir = env_datos)
if (!exists("caso1", envir = env_datos, inherits = FALSE)) {
  stop("El archivo caso1.RData debe contener un objeto denominado 'caso1'.")
}

datos <- get("caso1", envir = env_datos, inherits = FALSE)

columnas <- c(
  "temp", "wet", "isol", "replicate", "damaged_leaves",
  "undamaged_leaves", "total_leaves"
)
faltantes <- setdiff(columnas, names(datos))
if (length(faltantes) > 0L) {
  stop("Faltan columnas: ", paste(faltantes, collapse = ", "))
}

# Preparación
datos$temp <- as.numeric(as.character(datos$temp))
datos$wet <- as.numeric(as.character(datos$wet))
datos$isol <- factor(datos$isol)
datos$replicate <- factor(datos$replicate)
datos$incidencia <- datos$damaged_leaves / datos$total_leaves
datos$wet_c <- as.numeric(scale(datos$wet, center = TRUE, scale = FALSE))
datos$condID <- interaction(
  datos$isol, datos$replicate, datos$temp, datos$wet,
  drop = TRUE
)

cat("Datos cargados:", nrow(datos), "filas.\n")
cat("Casos completos para las variables principales:",
    sum(stats::complete.cases(datos[, columnas])), "\n")
