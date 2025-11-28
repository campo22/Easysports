package com.easysports.dto.auth;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

/**
 * Data Transfer Object (DTO) para la petición de registro de usuario.
 * Contiene los datos necesarios para crear una nueva cuenta de usuario.
 */
@Data
public class RegisterRequest {

    /**
     * El nombre completo del usuario.
     */
    @NotBlank(message = "El nombre no puede estar vacío")
    private String nombre;

    /**
     * La dirección de correo electrónico del usuario, utilizada como nombre de usuario.
     * Debe ser un formato de email válido.
     */
    @Email(message = "El formato del email no es válido")
    @NotBlank(message = "El email no puede estar vacío")
    private String email;

    /**
     * La contraseña del usuario.
     * Debe tener al menos 6 caracteres y no puede estar vacía.
     */
    @NotBlank(message = "La contraseña no puede estar vacía")
    @Size(min = 6, message = "La contraseña debe tener al menos 6 caracteres")
    private String password;
}
