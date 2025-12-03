package com.easysports.service;

import com.easysports.dto.team.CreateTeamRequest;
import com.easysports.dto.team.InvitarMiembroRequest;
import com.easysports.dto.team.TeamResponse;
import org.springframework.security.core.Authentication;

import java.util.List;

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

    /**
     * Invita a un usuario a unirse a un equipo.
     * Solo el capitán del equipo puede invitar.
     *
     * @param equipoId ID del equipo al que se invita.
     * @param request DTO con el email del usuario a invitar.
     * @param authentication Contexto de autenticación del capitán.
     */
    void invitarMiembro(Long equipoId, InvitarMiembroRequest request, Authentication authentication);

    /**
     * Acepta una invitación a unirse a un equipo.
     * Solo el usuario destinatario de la invitación puede aceptarla.
     *
     * @param equipoId ID del equipo al que se acepta la invitación.
     * @param authentication Contexto de autenticación del usuario que acepta.
     */
    void aceptarInvitacion(Long equipoId, Authentication authentication);

    /**
     * Rechaza una invitación a unirse a un equipo.
     * Solo el usuario destinatario de la invitación puede rechazarla.
     *
     * @param equipoId ID del equipo al que se rechaza la invitación.
     * @param authentication Contexto de autenticación del usuario que rechaza.
     */
    void rechazarInvitacion(Long equipoId, Authentication authentication);

    /**
     * Obtiene los equipos a los que pertenece o ha sido invitado un usuario autenticado.
     * @param authentication Contexto de autenticación del usuario.
     * @return Lista de equipos del usuario.
     */
    List<TeamResponse> getMisEquipos(Authentication authentication);

    /**
     * Busca un equipo por su ID y devuelve sus detalles.
     *
     * @param id El ID único del equipo.
     * @return DTO con la información del equipo.
     */
    TeamResponse findById(Long id);

    /**
     * Expulsa a un miembro de un equipo.
     * Solo el capitán del equipo puede expulsar miembros.
     *
     * @param equipoId ID del equipo del que se expulsará al miembro.
     * @param usuarioId ID del usuario que será expulsado.
     * @param authentication Contexto de autenticación del capitán.
     */
    void expulsarMiembro(Long equipoId, Long usuarioId, Authentication authentication);

    /**
     * Actualiza el perfil de un equipo.
     * Solo el capitán del equipo puede realizar esta acción.
     *
     * @param equipoId ID del equipo a actualizar.
     * @param request DTO con la nueva información del equipo.
     * @param authentication Contexto de autenticación del capitán.
     * @return DTO con la información del equipo actualizada.
     */
    TeamResponse updateTeam(Long equipoId, com.easysports.dto.team.UpdateTeamRequest request, Authentication authentication);
}