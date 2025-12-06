package com.easysports.controller;

import com.easysports.dto.user.PerfilUsuarioResponse;
import com.easysports.dto.user.UpdateUserRequest;
import com.easysports.service.AuthService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

/**
 * Controlador REST para la gestión del perfil de usuario.
 * Proporciona endpoints para obtener y actualizar el perfil del usuario autenticado.
 */
@RestController
@RequestMapping("/api/v1/perfil")
@Tag(name = "Perfil de Usuario", description = "Endpoints para la gestión del perfil de usuario")
public class PerfilController {

    private final AuthService authService;

    /**
     * Constructor para la inyección de dependencias.
     * @param authService Servicio de autenticación que maneja perfiles de usuario.
     */
    public PerfilController(AuthService authService) {
        this.authService = authService;
    }

    @Operation(summary = "Obtener perfil del usuario actual", description = "Retorna la información completa del perfil del usuario autenticado.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Perfil obtenido exitosamente",
                    content = @Content(mediaType = "application/json",
                            schema = @Schema(implementation = PerfilUsuarioResponse.class))),
            @ApiResponse(responseCode = "401", description = "No autenticado"),
            @ApiResponse(responseCode = "403", description = "No autorizado")
    })
    @GetMapping
    public ResponseEntity<PerfilUsuarioResponse> getPerfilActual(Authentication authentication) {
        PerfilUsuarioResponse perfil = authService.getPerfilActual(authentication);
        return ResponseEntity.ok(perfil);
    }

    @Operation(summary = "Actualizar perfil del usuario actual", description = "Actualiza la información del perfil del usuario autenticado.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Perfil actualizado exitosamente"),
            @ApiResponse(responseCode = "400", description = "Datos de solicitud inválidos"),
            @ApiResponse(responseCode = "401", description = "No autenticado"),
            @ApiResponse(responseCode = "403", description = "No autorizado")
    })
    @PutMapping
    public ResponseEntity<PerfilUsuarioResponse> updatePerfilActual(@RequestBody UpdateUserRequest request, Authentication authentication) {
        authService.updateProfile(request, authentication);
        PerfilUsuarioResponse perfil = authService.getPerfilActual(authentication);
        return ResponseEntity.ok(perfil);
    }
}