package com.easysports.dto.user;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * DTO para la respuesta de perfil de usuario.
 * Contiene la información completa del perfil de un usuario.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PerfilUsuarioResponse {

    private Long id;
    private String nombreCompleto;
    private String email;
    private String sexo;
    private Integer edadAnios;
    private Integer edadMeses;
    private Boolean esLeagueManager;
    private String posicionPreferida;
    private String avatarUrl;
    private Double puntuacion;
}