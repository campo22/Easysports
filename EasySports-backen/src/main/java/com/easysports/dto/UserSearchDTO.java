package com.easysports.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * DTO para devolver resultados de búsqueda de usuarios.
 * Contiene información pública y esencial de un usuario.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserSearchDTO {
    private Long id;
    private String nombreCompleto;
    private String email;
    private String avatarUrl;
}
