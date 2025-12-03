package com.easysports.controller;

import com.easysports.dto.match.MatchRequest;
import com.easysports.dto.match.MatchResponse;
import com.easysports.enums.Deporte;
import com.easysports.enums.MatchStatus;
import com.easysports.service.MatchService;
import jakarta.validation.Valid;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;

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
     * Busca y devuelve una lista paginada de encuentros aplicando criterios de filtro.
     * Solo usuarios autenticados pueden acceder.
     *
     * @param deporte Filtro por deporte (ej: "FUTBOL").
     * @param estado Filtro por estado del encuentro (ej: "ABIERTO").
     * @param fechaDesde Filtro por fecha de inicio (formato ISO: "2025-12-01T10:00:00").
     * @param fechaHasta Filtro por fecha de fin (formato ISO: "2025-12-31T23:59:59").
     * @param pageable Objeto de paginación y ordenamiento (ej: "?page=0&size=10&sort=fechaProgramada,desc").
     * @return ResponseEntity con una página de encuentros y estado HTTP 200.
     */
    @GetMapping
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<Page<MatchResponse>> findAllMatches(
            @RequestParam(required = false) Deporte deporte,
            @RequestParam(required = false) MatchStatus estado,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime fechaDesde,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime fechaHasta,
            Pageable pageable) {

        Page<MatchResponse> matches = matchService.findAll(deporte, estado, fechaDesde, fechaHasta, pageable);
        return ResponseEntity.ok(matches);
    }

    /**
     * Busca un encuentro por su código único y devuelve sus detalles.
     * Solo usuarios autenticados pueden acceder.
     *
     * @param codigo El código único del encuentro.
     * @return ResponseEntity con los detalles del encuentro y estado HTTP 200.
     */
    @GetMapping("/{codigo}")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<MatchResponse> findMatchByCodigo(@PathVariable String codigo) {
        MatchResponse response = matchService.findByCodigo(codigo);
        return ResponseEntity.ok(response);
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