package com.easysports.dto.auth;

import jakarta.validation.constraints.*;
import lombok.Data;

/**
 * Data Transfer Object (DTO) para la petición de registro de un nuevo usuario.
 * Contiene los datos requeridos por el sistema para crear una cuenta,
 * según las especificaciones del documento maestro.
 */
@Data
public class RegisterRequest {

    /**
     * El nombre completo del usuario. No puede estar vacío.
     */
    @NotBlank(message = "El nombre completo no puede estar vacío")
    private String nombreCompleto;

    /**
     * La dirección de correo electrónico del usuario. Debe ser un email válido y no puede estar vacío.
     */
    @Email(message = "El formato del email no es válido")
    @NotBlank(message = "El email no puede estar vacío")
    private String email;

    /**
     * La contraseña para la nueva cuenta.
     * Debe tener al menos 6 caracteres.
     */
    @NotBlank(message = "La contraseña no puede estar vacía")
    @Size(min = 6, message = "La contraseña debe tener al menos 6 caracteres")
    private String password;

    /**
     * El sexo del usuario (ej. "HOMBRE", "MUJER"). No puede estar vacío.
     */
    @NotBlank(message = "El sexo no puede estar vacío")
    private String sexo;

    /**
     * Los años de edad del usuario. Debe ser un valor positivo.
     */
    @NotNull(message = "Los años de edad no pueden ser nulos")
    @Min(value = 0, message = "Los años de edad no pueden ser negativos")
    private Integer edadAnios;

    /**
     * Los meses de edad del usuario. Debe ser un valor entre 0 y 11.
     */
    @NotNull(message = "Los meses de edad no pueden ser nulos")
    @Min(value = 0, message = "Los meses no pueden ser negativos")
    @Max(value = 11, message = "Los meses no pueden ser mayores a 11")
    private Integer edadMeses;
}
