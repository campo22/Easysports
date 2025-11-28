package com.easysports.service.impl;

import com.easysports.repository.UserRepository;
import com.easysports.security.UserDetailsImpl;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

/**
 * Implementación de {@link UserDetailsService} de Spring Security.
 * Encargada de cargar los datos del usuario por su nombre de usuario (email en nuestro caso).
 */
@Service
public class UserDetailsServiceImpl implements UserDetailsService {

    private final UserRepository userRepository;

    /**
     * Constructor para la inyección de dependencias.
     * @param userRepository Repositorio para acceder a los datos de los usuarios.
     */
    public UserDetailsServiceImpl(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    /**
     * Carga los datos del usuario dado un email (nombre de usuario).
     * @param email El email del usuario.
     * @return Un objeto {@link UserDetails} con la información del usuario.
     * @throws UsernameNotFoundException Si el usuario no es encontrado.
     */
    @Override
    public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {
        return userRepository.findByEmail(email)
                .map(UserDetailsImpl::new)
                .orElseThrow(() -> new UsernameNotFoundException("Usuario no encontrado con email: " + email));
    }
}
