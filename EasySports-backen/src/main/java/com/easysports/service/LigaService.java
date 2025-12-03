package com.easysports.service;

import com.easysports.dto.liga.TablaPosicionesResponse;

import java.util.List;

/**
 * Interfaz para el servicio de gestión de ligas.
 * Define los métodos para la lógica de negocio relacionada con las ligas y sus clasificaciones.
 */
public interface LigaService {

    /**
     * Obtiene la tabla de clasificación (posiciones) de una liga específica.
     *
     * @param ligaId El ID de la liga de la que se desea obtener la clasificación.
     * @return Una lista de {@link TablaPosicionesResponse} con la clasificación de la liga, ordenada por puntos.
     */
    List<TablaPosicionesResponse> getClasificacion(Long ligaId);
}
