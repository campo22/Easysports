package com.easysports.dto.auth;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Data Transfer Object (DTO) para la respuesta de autenticación.
 * Contiene el token JWT generado tras un login o registro exitoso.
 */
@Data
@AllArgsConstructor
@NoArgsConstructor
public class AuthResponse {
    /**
     * El token JWT que debe ser incluido en las cabeceras de autorización
     * de las futuras peticiones para acceder a recursos protegidos.
     */
    private String token;
}
