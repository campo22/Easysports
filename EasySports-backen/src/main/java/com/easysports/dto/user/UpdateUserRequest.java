package com.easysports.dto.user;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.Size;
import lombok.Data;

/**
 * DTO para la solicitud de actualización del perfil de usuario.
 */
@Data
public class UpdateUserRequest {

    /**
     * El nuevo nombre completo del usuario.
     * Puede tener entre 1 y 100 caracteres.
     */
    @Size(max = 100, message = "El nombre completo no puede exceder los 100 caracteres")
    private String nombreCompleto;

    /**
     * La nueva posición preferida del usuario.
     * Puede tener entre 1 y 50 caracteres.
     */
    @Size(max = 50, message = "La posición preferida no puede exceder los 50 caracteres")
    private String posicionPreferida;

    /**
     * La nueva URL del avatar del usuario.
     * Debe ser una URL válida (opcional).
     */
    @Size(max = 255, message = "La URL del avatar no puede exceder los 255 caracteres")
    private String avatarUrl;
}