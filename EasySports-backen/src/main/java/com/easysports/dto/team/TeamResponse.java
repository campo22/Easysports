package com.easysports.dto.team;

import com.easysports.enums.Deporte;
import com.easysports.enums.EstadoMiembro; // Importar
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

    // Opcional: Incluir el estado de la membresía del usuario autenticado en este equipo
    // Opcional: Incluir el estado de la membresía del usuario autenticado en este equipo
    private EstadoMiembro estadoMiembro;

    private java.util.List<MiembroResponse> miembros;
}