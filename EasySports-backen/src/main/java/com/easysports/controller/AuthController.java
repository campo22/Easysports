package com.easysports.controller;

import com.easysports.dto.auth.AuthResponse;
import com.easysports.dto.auth.LoginRequest;
import com.easysports.dto.auth.RegisterRequest;
import com.easysports.dto.user.UpdateUserRequest; // Importar el nuevo DTO
import com.easysports.service.AuthService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication; // Importar Authentication
import org.springframework.web.bind.annotation.*;

/**
 * Controlador REST para la gestión de la autenticación de usuarios.
 * Proporciona endpoints para el registro y login de usuarios, devolviendo un token JWT.
 */
@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final AuthService authService;

    /**
     * Constructor para la inyección de dependencias.
     * @param authService Servicio de autenticación.
     */
    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    /**
     * Endpoint para registrar un nuevo usuario en el sistema.
     *
     * @param request Datos de registro del usuario (nombre, email, password).
     * @return {@link ResponseEntity} con el token JWT si el registro es exitoso.
     */
    @PostMapping("/registro")
    public ResponseEntity<AuthResponse> register(@Valid @RequestBody RegisterRequest request) {
        String jwt = authService.register(request);
        return new ResponseEntity<>(new AuthResponse(jwt), HttpStatus.CREATED);
    }

    /**
     * Endpoint para que un usuario existente inicie sesión.
     *
     * @param request Credenciales del usuario (email, password).
     * @return {@link ResponseEntity} con el token JWT si el login es exitoso.
     */
    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@Valid @RequestBody LoginRequest request) {
        String jwt = authService.login(request);
        return ResponseEntity.ok(new AuthResponse(jwt));
    }

    /**
     * Endpoint para actualizar el perfil de un usuario autenticado.
     * Solo usuarios autenticados con rol 'USER' pueden actualizar su perfil.
     *
     * @param request Datos para la actualización del perfil.
     * @param authentication Contexto de autenticación del usuario.
     * @return {@link ResponseEntity} con estado HTTP 200 si la actualización es exitosa.
     */
    @PutMapping("/profile")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<Void> updateProfile(@Valid @RequestBody UpdateUserRequest request, Authentication authentication) {
        authService.updateProfile(request, authentication);
        return ResponseEntity.ok().build();
    }
}
