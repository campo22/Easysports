package com.easysports.service;

import com.easysports.dto.team.CreateTeamRequest; // DTO por crear
import com.easysports.dto.team.TeamResponse; // DTO por crear
import org.springframework.security.core.Authentication;

/**
 * Interfaz para el servicio de gestión de equipos.
 * Define los métodos para la lógica de negocio de los equipos.
 */
public interface TeamService {

    /**
     * Crea un nuevo equipo.
     *
     * @param request Datos para la creación del equipo.
     * @param authentication Contexto de autenticación del usuario (capitán).
     * @return DTO con la información del equipo creado.
     */
    TeamResponse createTeam(CreateTeamRequest request, Authentication authentication);
}