package com.easysports.service;

import com.easysports.dto.auth.LoginRequest;
import com.easysports.dto.auth.RegisterRequest;
import com.easysports.dto.user.UpdateUserRequest; // Importar el nuevo DTO
import com.easysports.dto.user.PerfilUsuarioResponse; // Importar el DTO de respuesta
import org.springframework.security.core.Authentication; // Importar Authentication

/**
 * Interfaz para el servicio de autenticación.
 * Define los métodos para el registro, login y gestión del perfil de usuarios.
 */
public interface AuthService {

    /**
     * Registra un nuevo usuario en la aplicación.
     *
     * @param request Datos de registro del usuario.
     * @return El token JWT generado para el nuevo usuario.
     */
    String register(RegisterRequest request);

    /**
     * Autentica a un usuario y genera un token JWT.
     *
     * @param request Credenciales del usuario.
     * @return El token JWT generado.
     */
    String login(LoginRequest request);

    /**
     * Actualiza el perfil de un usuario autenticado.
     *
     * @param request Datos para la actualización del perfil.
     * @param authentication Contexto de autenticación del usuario.
     */
    void updateProfile(UpdateUserRequest request, Authentication authentication); // Nuevo método

    /**
     * Obtiene el perfil completo del usuario autenticado.
     *
     * @param authentication Contexto de autenticación del usuario.
     * @return Perfil de usuario con información completa.
     */
    PerfilUsuarioResponse getPerfilActual(Authentication authentication);
}
