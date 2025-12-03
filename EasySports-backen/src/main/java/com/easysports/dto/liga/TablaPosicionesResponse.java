package com.easysports.dto.liga;

import com.easysports.enums.Deporte;
import lombok.Builder;
import lombok.Data;

/**
 * DTO para la respuesta de una entrada en la tabla de posiciones de una liga.
 */
@Data
@Builder
public class TablaPosicionesResponse {
    private Long equipoId;
    private String nombreEquipo;
    private Long ligaId;
    private String nombreLiga;
    private Deporte deporteLiga;
    private Integer puntos;
    private Integer partidosJugados;
    private Integer partidosGanados;
    private Integer partidosPerdidos;
    private Integer partidosEmpatados;
}
