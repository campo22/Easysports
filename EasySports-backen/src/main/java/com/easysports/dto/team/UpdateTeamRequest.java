package com.easysports.dto.team;

import com.easysports.enums.Deporte;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * DTO para la actualización de la información de un equipo.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UpdateTeamRequest {

    /**
     * El nuevo nombre del equipo.
     * Debe tener entre 1 y 100 caracteres.
     */
    @NotBlank(message = "El nombre del equipo no puede estar vacío.")
    @Size(min = 1, max = 100, message = "El nombre del equipo debe tener entre 1 y 100 caracteres.")
    private String nombre;

    /**
     * El tipo de deporte del equipo.
     * Debe ser uno de los valores definidos en el enum Deporte.
     */
    @NotNull(message = "El tipo de deporte no puede ser nulo.")
    private Deporte tipoDeporte;
}