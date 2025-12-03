package com.easysports.controller;

import com.easysports.dto.liga.TablaPosicionesResponse;
import com.easysports.service.LigaService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/**
 * Controlador REST para la gestión de ligas.
 * Expone endpoints para consultar la clasificación de las ligas.
 */
@RestController
@RequestMapping("/api/v1/ligas")
@RequiredArgsConstructor
@Tag(name = "Ligas", description = "Endpoints para la consulta de ligas y tablas de posiciones")
public class LigaController {

    private final LigaService ligaService;

    @Operation(summary = "Obtener tabla de posiciones de una liga", description = "Devuelve la tabla de clasificación para una liga específica, ordenada por puntos.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Clasificación obtenida exitosamente"),
            @ApiResponse(responseCode = "401", description = "No autenticado"),
            @ApiResponse(responseCode = "404", description = "Liga no encontrada")
    })
    @GetMapping("/{ligaId}/clasificacion")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<List<TablaPosicionesResponse>> getClasificacion(@Parameter(description = "ID de la liga") @PathVariable Long ligaId) {
        List<TablaPosicionesResponse> clasificacion = ligaService.getClasificacion(ligaId);
        return ResponseEntity.ok(clasificacion);
    }
}
