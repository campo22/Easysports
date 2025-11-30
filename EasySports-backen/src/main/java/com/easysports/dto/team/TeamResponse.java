package com.easysports.dto.team;

import com.easysports.enums.Deporte;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * DTO para la respuesta de datos de un equipo.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TeamResponse {

    private Long id;
    private String nombre;
    private Deporte tipoDeporte;
    private Long capitanId;
    private Integer partidosGanados;
}