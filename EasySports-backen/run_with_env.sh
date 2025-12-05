#!/bin/bash
# Script para cargar variables de entorno y ejecutar la aplicación

# Cargar las variables del archivo .env
if [ -f .env ]; then
    export $(cat .env | xargs)
fi

# Construir y ejecutar la aplicación
mvn spring-boot:run