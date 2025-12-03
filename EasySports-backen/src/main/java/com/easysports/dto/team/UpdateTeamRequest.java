package com.easysports.dto.team;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

/**
 * DTO para la solicitud de actualización de un equipo.
 */
@Data
public class UpdateTeamRequest {

    /**
     * El nuevo nombre del equipo.
     */
    @NotBlank(message = "El nombre del equipo no puede estar vacío.")
    @Size(max = 100, message = "El nombre del equipo no puede exceder los 100 caracteres.")
    private String nombre;
}
