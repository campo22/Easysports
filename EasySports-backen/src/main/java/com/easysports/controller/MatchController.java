package com.easysports.controller;

import com.easysports.dto.match.MatchRequest;
import com.easysports.dto.match.MatchResponse;
import com.easysports.dto.match.SubmitResultRequest;
import com.easysports.enums.Deporte;
import com.easysports.enums.MatchStatus;
import com.easysports.service.MatchService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
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
@Tag(name = "Encuentros", description = "Endpoints para la gestión de encuentros deportivos")
public class MatchController {

    private final MatchService matchService;

    /**
     * Constructor para la inyección de dependencias.
     * @param matchService Servicio de lógica de negocio para encuentros.
     */
    public MatchController(MatchService matchService) {
        this.matchService = matchService;
    }

    @Operation(summary = "Listar todos los encuentros", description = "Busca y devuelve una lista paginada de encuentros, con opción de filtrar por deporte, estado y rango de fechas.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Lista de encuentros obtenida exitosamente"),
            @ApiResponse(responseCode = "401", description = "No autenticado")
    })
    @GetMapping
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<Page<MatchResponse>> findAllMatches(
            @Parameter(description = "Filtrar por deporte") @RequestParam(required = false) Deporte deporte,
            @Parameter(description = "Filtrar por estado del encuentro") @RequestParam(required = false) MatchStatus estado,
            @Parameter(description = "Filtrar por fecha de inicio (formato ISO)") @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime fechaDesde,
            @Parameter(description = "Filtrar por fecha de fin (formato ISO)") @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime fechaHasta,
            @Parameter(hidden = true) Pageable pageable) {

        Page<MatchResponse> matches = matchService.findAll(deporte, estado, fechaDesde, fechaHasta, pageable);
        return ResponseEntity.ok(matches);
    }

    @Operation(summary = "Obtener detalles de un encuentro", description = "Busca un encuentro por su código único y devuelve sus detalles.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Encuentro encontrado"),
            @ApiResponse(responseCode = "401", description = "No autenticado"),
            @ApiResponse(responseCode = "404", description = "Encuentro no encontrado")
    })
    @GetMapping("/{codigo}")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<MatchResponse> findMatchByCodigo(@Parameter(description = "Código único del encuentro") @PathVariable String codigo) {
        MatchResponse response = matchService.findByCodigo(codigo);
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "Crear un nuevo encuentro", description = "Crea un nuevo encuentro deportivo. El usuario que lo crea se une automáticamente.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "201", description = "Encuentro creado exitosamente"),
            @ApiResponse(responseCode = "400", description = "Datos de solicitud inválidos"),
            @ApiResponse(responseCode = "401", description = "No autenticado")
    })
    @PostMapping
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<MatchResponse> createMatch(@Valid @RequestBody MatchRequest request, Authentication authentication) {
        MatchResponse response = matchService.createMatch(request, authentication);
        return new ResponseEntity<>(response, HttpStatus.CREATED);
    }

    @Operation(summary = "Unirse a un encuentro", description = "Permite a un usuario autenticado unirse a un encuentro existente.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Usuario unido al encuentro exitosamente"),
            @ApiResponse(responseCode = "401", description = "No autenticado"),
            @ApiResponse(responseCode = "404", description = "Encuentro no encontrado"),
            @ApiResponse(responseCode = "409", description = "Conflicto de estado (ej. el partido está lleno o no está abierto)")
    })
    @PostMapping("/{codigo}/unirse")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<MatchResponse> joinMatch(@Parameter(description = "Código único del encuentro") @PathVariable String codigo, Authentication authentication) {
        MatchResponse response = matchService.joinMatch(codigo, authentication);
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "Registrar resultado de un encuentro", description = "Registra el resultado de un encuentro. Solo el creador puede hacerlo.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Resultado registrado exitosamente"),
            @ApiResponse(responseCode = "400", description = "Datos de solicitud inválidos"),
            @ApiResponse(responseCode = "401", description = "No autenticado"),
            @ApiResponse(responseCode = "403", description = "No autorizado para registrar el resultado"),
            @ApiResponse(responseCode = "404", description = "Encuentro no encontrado"),
            @ApiResponse(responseCode = "409", description = "Conflicto de estado (ej. el partido ya ha finalizado)")
    })
    @PostMapping("/{codigo}/resultados")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<MatchResponse> submitResult(@Parameter(description = "Código único del encuentro") @PathVariable String codigo, @Valid @RequestBody SubmitResultRequest request, Authentication authentication) {
        MatchResponse response = matchService.submitResult(codigo, request, authentication);
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "Cancelar un encuentro", description = "Cancela un encuentro. Solo el creador puede hacerlo.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Encuentro cancelado exitosamente"),
            @ApiResponse(responseCode = "401", description = "No autenticado"),
            @ApiResponse(responseCode = "403", description = "No autorizado para cancelar el encuentro"),
            @ApiResponse(responseCode = "404", description = "Encuentro no encontrado"),
            @ApiResponse(responseCode = "409", description = "Conflicto de estado (ej. el partido ya ha finalizado o está en juego)")
    })
    @PutMapping("/{codigo}/cancelar")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<MatchResponse> cancelMatch(@Parameter(description = "Código único del encuentro") @PathVariable String codigo, Authentication authentication) {
        MatchResponse response = matchService.cancelMatch(codigo, authentication);
        return ResponseEntity.ok(response);
    }
}
