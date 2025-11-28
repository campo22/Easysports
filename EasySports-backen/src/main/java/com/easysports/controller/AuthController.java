package com.easysports.controller;

import com.easysports.dto.auth.AuthResponse;
import com.easysports.dto.auth.LoginRequest;
import com.easysports.dto.auth.RegisterRequest;
import com.easysports.service.impl.AuthService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

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
}
