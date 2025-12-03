package com.easysports.service;

import com.easysports.dto.team.CreateTeamRequest;
import com.easysports.dto.team.InvitarMiembroRequest;
import com.easysports.dto.team.TeamResponse;
import org.springframework.security.core.Authentication;

import java.util.List;

/**
 * Interfaz para el servicio de gestión de equipos.
 * Define los métodos para la lógica de negocio relacionada con los equipos.
 */
public interface TeamService {

    /**
     * Crea un nuevo equipo.
     *
     * @param request Datos para la creación del equipo.
     * @param authentication Contexto de autenticación del usuario.
     * @return DTO con la información del equipo creado.
     */
    TeamResponse createTeam(CreateTeamRequest request, Authentication authentication);

    /**
     * Invita a un usuario a unirse a un equipo.
     *
     * @param equipoId ID del equipo al que se invita.
     * @param request DTO con el email del usuario a invitar.
     * @param authentication Contexto de autenticación del capitán.
     */
    void invitarMiembro(Long equipoId, InvitarMiembroRequest request, Authentication authentication);

    /**
     * Acepta una invitación a unirse a un equipo.
     *
     * @param equipoId ID del equipo al que se acepta la invitación.
     * @param authentication Contexto de autenticación del usuario que acepta.
     */
    void aceptarInvitacion(Long equipoId, Authentication authentication);

    /**
     * Rechaza una invitación a unirse a un equipo.
     *
     * @param equipoId ID del equipo al que se rechaza la invitación.
     * @param authentication Contexto de autenticación del usuario que rechaza.
     */
    void rechazarInvitacion(Long equipoId, Authentication authentication);

    /**
     * Busca un equipo por su ID único y devuelve sus detalles.
     *
     * @param id El ID único del equipo.
     * @return DTO con la información del equipo.
     */
    TeamResponse findById(Long id);

    /**
     * Obtiene una lista de todos los equipos en los que el usuario autenticado es miembro.
     *
     * @param authentication Contexto de autenticación del usuario.
     * @return Lista de DTOs con la información de los equipos.
     */
    List<TeamResponse> getMisEquipos(Authentication authentication);
}
