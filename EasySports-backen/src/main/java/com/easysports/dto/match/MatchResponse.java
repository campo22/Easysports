package com.easysports.dto.match;

import com.easysports.enums.Deporte;
import com.easysports.enums.MatchStatus;
import com.easysports.enums.MatchType;
import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * DTO para la respuesta de un encuentro (partido).
 * Contiene la información relevante de un encuentro una vez creado o consultado.
 */
@Data
@Builder
public class MatchResponse {
    private Long id;
    private String codigo;
    private MatchType tipo;
    private Deporte deporte;
    private MatchStatus estado;
    private LocalDateTime fechaProgramada;
    private Long canchaId;
    private String nombreCanchaTexto;
    private Long creadorId;
    private Long equipoLocalId;
    private Long equipoVisitanteId;
    private Integer maxJugadores;
    private Integer jugadoresActuales;
    private Integer golesLocal;
    private Integer golesVisitante;
    private String comentarios;
}
