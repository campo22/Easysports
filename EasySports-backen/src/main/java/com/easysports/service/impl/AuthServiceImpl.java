package com.easysports.service.impl;

import com.easysports.dto.auth.LoginRequest;
import com.easysports.dto.auth.RegisterRequest;
import com.easysports.dto.user.UpdateUserRequest;
import com.easysports.dto.user.PerfilUsuarioResponse;
import com.easysports.enums.Sexo;
import com.easysports.model.User;
import com.easysports.repository.UserRepository;
import com.easysports.security.UserDetailsImpl;
import com.easysports.service.AuthService;
import com.easysports.util.JwtUtil;
import org.springframework.http.HttpStatus;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.math.BigDecimal;

/**
 * Implementación del servicio de autenticación.
 * Contiene la lógica de negocio para el registro y login de usuarios.
 */
@Service
public class AuthServiceImpl implements AuthService {

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
    public AuthServiceImpl(UserRepository userRepository, PasswordEncoder passwordEncoder, JwtUtil jwtUtil, AuthenticationManager authenticationManager) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtUtil = jwtUtil;
        this.authenticationManager = authenticationManager;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public String register(RegisterRequest request) {
        if (userRepository.findByEmail(request.getEmail()).isPresent()) {
            throw new IllegalStateException("El email ya está registrado.");
        }

        User user = User.builder()
                .nombreCompleto(request.getNombreCompleto())
                .email(request.getEmail())
                .password(passwordEncoder.encode(request.getPassword()))
                .sexo(Sexo.valueOf(request.getSexo().toUpperCase()))
                .edadAnios(request.getEdadAnios())
                .edadMeses(request.getEdadMeses())
                .esLeagueManager(false) // Valor por defecto según documento maestro
                .puntuacion(new BigDecimal("5.0")) // Valor por defecto según documento maestro
                .build();

        userRepository.save(user);
        
        return jwtUtil.generateToken(new UserDetailsImpl(user));
    }

    /**
     * {@inheritDoc}
     */
    @Override
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

    @Override
    public void updateProfile(UpdateUserRequest request, Authentication authentication) {
        // Obtener el usuario autenticado
        UserDetailsImpl userDetails = (UserDetailsImpl) authentication.getPrincipal();
        User user = userRepository.findById(userDetails.getUser().getId())
                .orElseThrow(() -> new UsernameNotFoundException("Usuario no encontrado."));

        // Actualizar los campos del usuario con los valores del DTO
        // Solo actualizamos si el campo no es nulo en el DTO
        if (request.getNombreCompleto() != null) {
            user.setNombreCompleto(request.getNombreCompleto());
        }
        if (request.getPosicionPreferida() != null) {
            user.setPosicionPreferida(request.getPosicionPreferida());
        }
        if (request.getAvatarUrl() != null) {
            user.setAvatarUrl(request.getAvatarUrl());
        }

        // Guardar los cambios
        userRepository.save(user);
    }

    @Override
    public PerfilUsuarioResponse getPerfilActual(Authentication authentication) {
        // Obtener el usuario autenticado
        UserDetailsImpl userDetails = (UserDetailsImpl) authentication.getPrincipal();
        User user = userRepository.findById(userDetails.getUser().getId())
                .orElseThrow(() -> new UsernameNotFoundException("Usuario no encontrado."));

        // Convertir a DTO de respuesta de perfil
        return PerfilUsuarioResponse.builder()
            .id(user.getId())
            .nombreCompleto(user.getNombreCompleto())
            .email(user.getEmail())
            .sexo(user.getSexo().name())
            .edadAnios(user.getEdadAnios())
            .edadMeses(user.getEdadMeses())
            .esLeagueManager(user.getEsLeagueManager())
            .posicionPreferida(user.getPosicionPreferida())
            .avatarUrl(user.getAvatarUrl())
            .puntuacion(user.getPuntuacion() != null ? user.getPuntuacion().doubleValue() : 0.0)
            .build();
    }
}