#!/bin/bash
# Cargar variables de entorno desde .env y exportarlas
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
fi

# Ejecutar el backend con Maven Wrapper
./mvnw spring-boot:run
