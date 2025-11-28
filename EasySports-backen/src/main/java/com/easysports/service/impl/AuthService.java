package com.easysports.service.impl;

import com.easysports.dto.auth.LoginRequest;
import com.easysports.dto.auth.RegisterRequest;
import com.easysports.enums.Role;
import com.easysports.model.User;
import com.easysports.repository.UserRepository;
import com.easysports.security.UserDetailsImpl;
import com.easysports.util.JwtUtil;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

/**
 * Servicio encargado de la lógica de negocio para la autenticación de usuarios (registro y login).
 */
@Service
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;
    private final AuthenticationManager authenticationManager;

    /**
     * Constructor para la inyección de dependencias.
     *
     * @param userRepository      Repositorio para operaciones CRUD de usuarios.
     * @param passwordEncoder     Codificador de contraseñas para seguridad.
     * @param jwtUtil             Utilidad para la generación y validación de JWT.
     * @param authenticationManager Gestor de autenticación de Spring Security.
     */
    public AuthService(UserRepository userRepository, PasswordEncoder passwordEncoder, JwtUtil jwtUtil, AuthenticationManager authenticationManager) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtUtil = jwtUtil;
        this.authenticationManager = authenticationManager;
    }

    /**
     * Registra un nuevo usuario en la aplicación.
     * Hashea la contraseña antes de guardarla.
     * Por defecto, asigna el rol {@code ROLE_USER} al nuevo usuario.
     *
     * @param request Datos de registro del usuario.
     * @return El token JWT generado para el nuevo usuario.
     * @throws IllegalStateException Si el email ya está registrado.
     */
    public String register(RegisterRequest request) {
        if (userRepository.findByEmail(request.getEmail()).isPresent()) {
            throw new IllegalStateException("El email ya está registrado.");
        }

        User user = new User();
        user.setNombre(request.getNombre());
        user.setEmail(request.getEmail());
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user.setRol(Role.ROLE_USER); // Asignar rol por defecto

        userRepository.save(user);

        // Generar token JWT para el usuario recién registrado
        UserDetailsImpl userDetails = new UserDetailsImpl(user);
        return jwtUtil.generateToken(userDetails);
    }

    /**
     * Autentica a un usuario y genera un token JWT si las credenciales son válidas.
     *
     * @param request Credenciales del usuario (email y contraseña).
     * @return El token JWT generado para el usuario autenticado.
     * @throws UsernameNotFoundException Si las credenciales son inválidas.
     */
    public String login(LoginRequest request) {
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        request.getEmail(),
                        request.getPassword()
                )
        );

        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new UsernameNotFoundException("Usuario no encontrado."));

        UserDetailsImpl userDetails = new UserDetailsImpl(user);
        return jwtUtil.generateToken(userDetails);
    }
}
