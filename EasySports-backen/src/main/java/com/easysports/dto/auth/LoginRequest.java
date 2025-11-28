package com.easysports.dto.auth;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

/**
 * Data Transfer Object (DTO) para la petición de login de usuario.
 * Contiene las credenciales necesarias para iniciar sesión.
 */
@Data
public class LoginRequest {

    /**
     * La dirección de correo electrónico del usuario.
     * Debe ser un formato de email válido y no puede estar vacío.
     */
    @Email(message = "El formato del email no es válido")
    @NotBlank(message = "El email no puede estar vacío")
    private String email;

    /**
     * La contraseña del usuario.
     * No puede estar vacía.
     */
    @NotBlank(message = "La contraseña no puede estar vacía")
    private String password;
}
