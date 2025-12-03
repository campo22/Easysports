package com.easysports.controller;

import com.easysports.dto.team.CreateTeamRequest;
import com.easysports.dto.team.InvitarMiembroRequest;
import com.easysports.dto.team.TeamResponse;
import com.easysports.dto.team.UpdateTeamRequest;
import com.easysports.service.TeamService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
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
@Tag(name = "Equipos", description = "Endpoints para la gestión de equipos y membresías")
public class TeamController {

    private final TeamService teamService;

    /**
     * Constructor para la inyección de dependencias.
     * @param teamService Servicio de lógica de negocio para equipos.
     */
    public TeamController(TeamService teamService) {
        this.teamService = teamService;
    }

    @Operation(summary = "Crear un nuevo equipo", description = "Crea un nuevo equipo, asignando al usuario autenticado como capitán.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "201", description = "Equipo creado exitosamente"),
            @ApiResponse(responseCode = "400", description = "Datos de solicitud inválidos"),
            @ApiResponse(responseCode = "401", description = "No autenticado")
    })
    @PostMapping
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<TeamResponse> createTeam(@Valid @RequestBody CreateTeamRequest request, Authentication authentication) {
        TeamResponse response = teamService.createTeam(request, authentication);
        return new ResponseEntity<>(response, HttpStatus.CREATED);
    }

    @Operation(summary = "Obtener los equipos del usuario", description = "Devuelve una lista de los equipos donde el usuario es miembro o tiene una invitación pendiente.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Lista de equipos obtenida"),
            @ApiResponse(responseCode = "401", description = "No autenticado")
    })
    @GetMapping("/mios")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<List<TeamResponse>> getMisEquipos(Authentication authentication) {
        List<TeamResponse> equipos = teamService.getMisEquipos(authentication);
        return ResponseEntity.ok(equipos);
    }

    @Operation(summary = "Obtener detalles de un equipo", description = "Busca un equipo por su ID único y devuelve sus detalles.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Equipo encontrado"),
            @ApiResponse(responseCode = "401", description = "No autenticado"),
            @ApiResponse(responseCode = "404", description = "Equipo no encontrado")
    })
    @GetMapping("/{id}")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<TeamResponse> findTeamById(@Parameter(description = "ID único del equipo") @PathVariable Long id) {
        TeamResponse response = teamService.findById(id);
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "Actualizar perfil de un equipo", description = "Actualiza el nombre de un equipo. Solo el capitán puede hacerlo.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Equipo actualizado exitosamente"),
            @ApiResponse(responseCode = "401", description = "No autenticado"),
            @ApiResponse(responseCode = "403", description = "No autorizado"),
            @ApiResponse(responseCode = "404", description = "Equipo no encontrado")
    })
    @PutMapping("/{teamId}")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<TeamResponse> updateTeam(@Parameter(description = "ID del equipo a actualizar") @PathVariable Long teamId, @Valid @RequestBody UpdateTeamRequest request, Authentication authentication) {
        TeamResponse updatedTeam = teamService.updateTeam(teamId, request, authentication);
        return ResponseEntity.ok(updatedTeam);
    }

    @Operation(summary = "Invitar a un miembro a un equipo", description = "Envía una invitación a un usuario (por email) para unirse a un equipo. Solo el capitán puede invitar.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Invitación enviada exitosamente"),
            @ApiResponse(responseCode = "401", description = "No autenticado"),
            @ApiResponse(responseCode = "403", description = "No autorizado"),
            @ApiResponse(responseCode = "404", description = "Equipo o usuario a invitar no encontrado")
    })
    @PostMapping("/{equipoId}/invitar")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<Void> invitarMiembro(@Parameter(description = "ID del equipo") @PathVariable Long equipoId, @Valid @RequestBody InvitarMiembroRequest request, Authentication authentication) {
        teamService.invitarMiembro(equipoId, request, authentication);
        return ResponseEntity.ok().build();
    }

    @Operation(summary = "Aceptar una invitación de equipo", description = "Acepta una invitación pendiente para unirse a un equipo.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Invitación aceptada"),
            @ApiResponse(responseCode = "401", description = "No autenticado"),
            @ApiResponse(responseCode = "404", description = "Invitación no encontrada")
    })
    @PutMapping("/{equipoId}/invitaciones/aceptar")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<Void> aceptarInvitacion(@Parameter(description = "ID del equipo") @PathVariable Long equipoId, Authentication authentication) {
        teamService.aceptarInvitacion(equipoId, authentication);
        return ResponseEntity.ok().build();
    }

    @Operation(summary = "Rechazar una invitación de equipo", description = "Rechaza una invitación pendiente para unirse a un equipo.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Invitación rechazada"),
            @ApiResponse(responseCode = "401", description = "No autenticado"),
            @ApiResponse(responseCode = "404", description = "Invitación no encontrada")
    })
    @PutMapping("/{equipoId}/invitaciones/rechazar")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<Void> rechazarInvitacion(@Parameter(description = "ID del equipo") @PathVariable Long equipoId, Authentication authentication) {
        teamService.rechazarInvitacion(equipoId, authentication);
        return ResponseEntity.ok().build();
    }

    @Operation(summary = "Expulsar a un miembro del equipo", description = "Expulsa a un miembro de un equipo. Solo el capitán puede hacerlo.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "204", description = "Miembro expulsado exitosamente"),
            @ApiResponse(responseCode = "401", description = "No autenticado"),
            @ApiResponse(responseCode = "403", description = "No autorizado"),
            @ApiResponse(responseCode = "404", description = "Equipo o miembro no encontrado")
    })
    @DeleteMapping("/{teamId}/miembros/{memberId}")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<Void> kickMember(@Parameter(description = "ID del equipo") @PathVariable Long teamId, @Parameter(description = "ID del miembro a expulsar") @PathVariable Long memberId, Authentication authentication) {
        teamService.kickMember(teamId, memberId, authentication);
        return ResponseEntity.noContent().build();
    }
}