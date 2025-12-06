package com.easysports.dto.match;

import com.easysports.enums.Deporte;
import com.easysports.enums.MatchStatus;
import com.easysports.enums.MatchType;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * DTO para representar un partido en una lista, con información esencial
 * y los nombres de los equipos ya resueltos.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MatchListDTO {

    private Long id;
    private String codigo;
    private Deporte deporte;
    private MatchType tipo;
    private MatchStatus estado;
    private LocalDateTime fechaProgramada;
    
    // Nombres de los equipos (en lugar de solo los IDs)
    private String equipoLocalNombre;
    private String equipoVisitanteNombre;
    
    // IDs para navegación en el frontend
    private Long equipoLocalId;
    private Long equipoVisitanteId;
    
    private String nombreCanchaTexto;
    private Integer maxJugadores;
    private Integer jugadoresActuales;
    
    // Resultado
    private Integer golesLocal;
    private Integer golesVisitante;
}
