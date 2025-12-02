package com.easysports.dto.team;

import com.easysports.enums.EstadoMiembro;
import com.easysports.enums.RolMiembro;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * DTO para la respuesta de datos de un miembro en un equipo.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MiembroEquipoResponse {

    private Long id;
    private Long usuarioId;
    private String nombreUsuario; // Opcional: nombre para mostrar
    private Long equipoId;
    private String nombreEquipo; // Opcional: nombre para mostrar
    private EstadoMiembro estado;
    private RolMiembro rol;
    private LocalDateTime fechaIngreso;
    private LocalDateTime fechaEstado;
}