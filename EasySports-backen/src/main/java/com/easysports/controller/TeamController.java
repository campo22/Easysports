package com.easysports.controller;

import com.easysports.dto.team.CreateTeamRequest;
import com.easysports.dto.team.TeamResponse;
import com.easysports.service.TeamService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

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
}