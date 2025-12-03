package com.easysports.controller;

import com.easysports.dto.auth.AuthResponse;
import com.easysports.dto.auth.LoginRequest;
import com.easysports.dto.auth.RegisterRequest;
import com.easysports.dto.user.UpdateUserRequest;
import com.easysports.service.AuthService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

/**
 * Controlador REST para la gestión de la autenticación de usuarios.
 * Proporciona endpoints para el registro y login de usuarios, devolviendo un token JWT.
 */
@RestController
@RequestMapping("/api/auth")
@Tag(name = "Autenticación", description = "Endpoints para el registro y login de usuarios")
public class AuthController {

    private final AuthService authService;

    /**
     * Constructor para la inyección de dependencias.
     * @param authService Servicio de autenticación.
     */
    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @Operation(summary = "Registrar un nuevo usuario", description = "Crea una nueva cuenta de usuario y devuelve un token JWT para la sesión.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "201", description = "Usuario registrado exitosamente",
                    content = { @Content(mediaType = "application/json",
                            schema = @Schema(implementation = AuthResponse.class)) }),
            @ApiResponse(responseCode = "400", description = "Datos de solicitud inválidos"),
            @ApiResponse(responseCode = "409", description = "El email ya está en uso")
    })
    @PostMapping("/registro")
    public ResponseEntity<AuthResponse> register(@Valid @RequestBody RegisterRequest request) {
        String jwt = authService.register(request);
        return new ResponseEntity<>(new AuthResponse(jwt), HttpStatus.CREATED);
    }

    @Operation(summary = "Iniciar sesión", description = "Autentica a un usuario con su email y contraseña, y devuelve un token JWT.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Login exitoso",
                    content = { @Content(mediaType = "application/json",
                            schema = @Schema(implementation = AuthResponse.class)) }),
            @ApiResponse(responseCode = "400", description = "Datos de solicitud inválidos"),
            @ApiResponse(responseCode = "401", description = "Credenciales inválidas")
    })
    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@Valid @RequestBody LoginRequest request) {
        String jwt = authService.login(request);
        return ResponseEntity.ok(new AuthResponse(jwt));
    }

    @Operation(summary = "Actualizar perfil de usuario", description = "Actualiza los datos del perfil del usuario autenticado. Requiere autenticación.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Perfil actualizado exitosamente"),
            @ApiResponse(responseCode = "400", description = "Datos de solicitud inválidos"),
            @ApiResponse(responseCode = "401", description = "No autenticado"),
            @ApiResponse(responseCode = "403", description = "No autorizado")
    })
    @PutMapping("/profile")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<Void> updateProfile(@Valid @RequestBody UpdateUserRequest request, Authentication authentication) {
        authService.updateProfile(request, authentication);
        return ResponseEntity.ok().build();
    }
}
