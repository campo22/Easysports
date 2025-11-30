package com.easysports.controller;

import com.easysports.dto.match.MatchRequest;
import com.easysports.dto.match.MatchResponse;
import com.easysports.dto.match.JoinMatchRequest; // Importar el nuevo DTO
import com.easysports.service.MatchService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication; // Importar Authentication
import org.springframework.web.bind.annotation.*;

/**
 * Controlador REST para la gestión de encuentros (partidos).
 * Permite la creación, consulta y manipulación de partidos deportivos.
 */
@RestController
@RequestMapping("/api/v1/matches")
public class MatchController {

    private final MatchService matchService;

    /**
     * Constructor para la inyección de dependencias.
     * @param matchService Servicio de lógica de negocio para encuentros.
     */
    public MatchController(MatchService matchService) {
        this.matchService = matchService;
    }

    /**
     * Crea un nuevo encuentro deportivo.
     * Solo usuarios autenticados con rol 'USER' pueden crear encuentros.
     * @param request DTO con los datos para crear el encuentro.
     * @param authentication Contexto de autenticación del usuario.
     * @return ResponseEntity con los detalles del encuentro creado y estado HTTP 201.
     */
    @PostMapping
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<MatchResponse> createMatch(@Valid @RequestBody MatchRequest request, Authentication authentication) {
        MatchResponse response = matchService.createMatch(request, authentication);
        return new ResponseEntity<>(response, HttpStatus.CREATED);
    }

    /**
     * Permite a un usuario autenticado unirse a un encuentro.
     * Solo usuarios autenticados con rol 'USER' pueden unirse a encuentros.
     * @param codigo Codigo del encuentro al que se quiere unir.
     * @param authentication Contexto de autenticación del usuario.
     * @return ResponseEntity con los detalles del encuentro actualizado y estado HTTP 200.
     */
    @PostMapping("/{codigo}/unirse")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<MatchResponse> joinMatch(@PathVariable String codigo, Authentication authentication) {
        MatchResponse response = matchService.joinMatch(codigo, authentication);
        return ResponseEntity.ok(response);
    }
}
