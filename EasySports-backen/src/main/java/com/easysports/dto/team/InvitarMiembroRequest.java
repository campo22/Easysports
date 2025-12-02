package com.easysports.dto.team;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

/**
 * DTO para la solicitud de invitación de un nuevo miembro a un equipo.
 */
@Data
public class InvitarMiembroRequest {

    /**
     * El email del usuario a invitar.
     * Debe ser un formato de email válido y no puede estar vacío.
     */
    @Email(message = "El formato del email no es válido")
    @NotBlank(message = "El email no puede estar vacío")
    private String emailUsuario;
}