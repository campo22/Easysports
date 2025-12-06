package com.easysports.controller;

import com.easysports.dto.team.CreateTeamRequest;
import com.easysports.dto.team.InvitarMiembroRequest;
import com.easysports.dto.team.TeamResponse;
import com.easysports.dto.team.UpdateTeamRequest;
import com.easysports.service.TeamService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Controlador REST para la gestión de equipos.
 * Permite la creación y consulta de equipos.
 */
@RestController
@RequestMapping("/api/v1/teams")
public class TeamController {

    private final TeamService teamService;

    /**
     * Constructor para la inyección de dependencias.
     * @param teamService Servicio de lógica de negocio para equipos.
     */
    public TeamController(TeamService teamService) {
        this.teamService = teamService;
    }

    /**
     * Crea un nuevo equipo.
     * Solo usuarios autenticados con rol 'USER' pueden crear equipos.
     * @param request DTO con los datos para crear el equipo.
     * @param authentication Contexto de autenticación del usuario (capitán).
     * @return ResponseEntity con los detalles del equipo creado y estado HTTP 201.
     */
    @PostMapping
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<TeamResponse> createTeam(@Valid @RequestBody CreateTeamRequest request, Authentication authentication) {
        TeamResponse response = teamService.createTeam(request, authentication);
        return new ResponseEntity<>(response, HttpStatus.CREATED);
    }

    /**
     * Invita a un usuario a unirse a un equipo.
     * Solo el capitán del equipo puede invitar.
     * @param equipoId ID del equipo al que se invita.
     * @param request DTO con el email del usuario a invitar.
     * @param authentication Contexto de autenticación del capitán.
     * @return ResponseEntity con estado HTTP 200 si la invitación es exitosa.
     */
    @PostMapping("/{equipoId}/invitar")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<Void> invitarMiembro(@PathVariable Long equipoId, @Valid @RequestBody InvitarMiembroRequest request, Authentication authentication) {
        teamService.invitarMiembro(equipoId, request, authentication);
        return ResponseEntity.ok().build();
    }

    /**
     * Acepta una invitación a unirse a un equipo.
     * Solo el usuario destinatario de la invitación puede aceptarla.
     * @param equipoId ID del equipo al que se acepta la invitación.
     * @param authentication Contexto de autenticación del usuario que acepta.
     * @return ResponseEntity con estado HTTP 200 si la aceptación es exitosa.
     */
    @PutMapping("/{equipoId}/invitaciones/aceptar")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<Void> aceptarInvitacion(@PathVariable Long equipoId, Authentication authentication) {
        teamService.aceptarInvitacion(equipoId, authentication);
        return ResponseEntity.ok().build();
    }

    /**
     * Rechaza una invitación a unirse a un equipo.
     * Solo el usuario destinatario de la invitación puede rechazarla.
     * @param equipoId ID del equipo al que se rechaza la invitación.
     * @param authentication Contexto de autenticación del usuario que rechaza.
     * @return ResponseEntity con estado HTTP 200 si el rechazo es exitoso.
     */
    @PutMapping("/{equipoId}/invitaciones/rechazar")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<Void> rechazarInvitacion(@PathVariable Long equipoId, Authentication authentication) {
        teamService.rechazarInvitacion(equipoId, authentication);
        return ResponseEntity.ok().build();
    }

    /**
     * Obtiene los equipos a los que pertenece o ha sido invitado un usuario autenticado.
     * @param authentication Contexto de autenticación del usuario.
     * @return ResponseEntity con una lista de equipos del usuario.
     */
    @GetMapping("/mios")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<List<TeamResponse>> getMisEquipos(Authentication authentication) {
        List<TeamResponse> equipos = teamService.getMisEquipos(authentication);
        return ResponseEntity.ok(equipos);
    }

    /**
     * Busca un equipo por su ID único y devuelve sus detalles.
     * Solo usuarios autenticados pueden acceder.
     *
     * @param id El ID único del equipo.
     * @return ResponseEntity con los detalles del equipo y estado HTTP 200.
     */
    @GetMapping("/{id}")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<TeamResponse> findTeamById(@PathVariable Long id) {
        TeamResponse response = teamService.findById(id);
        return ResponseEntity.ok(response);
    }

    /**
     * Expulsa a un miembro de un equipo.
     * Solo el capitán del equipo puede expulsar miembros.
     *
     * @param equipoId ID del equipo del que se expulsará al miembro.
     * @param usuarioId ID del usuario que será expulsado.
     * @param authentication Contexto de autenticación del capitán.
     * @return ResponseEntity con estado HTTP 204 (No Content) si la expulsión es exitosa.
     */
    @DeleteMapping("/{equipoId}/miembro/{usuarioId}")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<Void> expulsarMiembro(@PathVariable Long equipoId, @PathVariable Long usuarioId, Authentication authentication) {
        teamService.expulsarMiembro(equipoId, usuarioId, authentication);
        return ResponseEntity.noContent().build();
    }

    /**
     * Actualiza el perfil de un equipo.
     * Solo el capitán del equipo puede realizar esta acción.
     *
     * @param equipoId ID del equipo a actualizar.
     * @param request DTO con la nueva información del equipo.
     * @param authentication Contexto de autenticación del capitán.
     * @return ResponseEntity con la información del equipo actualizada y estado HTTP 200.
     */
    @PutMapping("/{equipoId}")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<TeamResponse> updateTeam(@PathVariable Long equipoId, @Valid @RequestBody UpdateTeamRequest request, Authentication authentication) {
        TeamResponse updatedTeam = teamService.updateTeam(equipoId, request, authentication);
        return ResponseEntity.ok(updatedTeam);
    }

    /**
     * Obtiene todos los equipos registrados.
     * Útil para seleccionar rivales.
     * @return ResponseEntity con la lista de todos los equipos.
     */
    @GetMapping
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<List<TeamResponse>> getAllTeams() {
        List<TeamResponse> teams = teamService.getAllTeams();
        return ResponseEntity.ok(teams);
    }
}
