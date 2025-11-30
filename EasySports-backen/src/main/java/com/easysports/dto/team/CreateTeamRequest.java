package com.easysports.dto.team;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;

/**
 * DTO para la solicitud de creación de un nuevo equipo.
 */
@Data
public class CreateTeamRequest {

    /**
     * El nombre del equipo.
     * No puede estar vacío y debe tener entre 1 y 100 caracteres.
     */
    @NotBlank(message = "El nombre del equipo no puede estar vacío")
    @Size(min = 1, max = 100, message = "El nombre del equipo debe tener entre 1 y 100 caracteres")
    private String nombre;

    /**
     * El tipo de deporte del equipo.
     * Debe coincidir con una de las constantes del enum Deporte.
     */
    @NotNull(message = "El tipo de deporte no puede ser nulo")
    private String tipoDeporte; // Se validará contra el enum Deporte en el servicio
}