package com.easysports.config;

import com.easysports.repository.UserRepository;
import com.easysports.service.impl.UserDetailsServiceImpl;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.AuthenticationProvider;
import org.springframework.security.authentication.dao.DaoAuthenticationProvider;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.password.PasswordEncoder;

/**
 * Clase de configuración para la aplicación, donde se definen beans esenciales
 * para la autenticación y seguridad, como el {@link UserDetailsService},
 * {@link AuthenticationProvider} y {@link AuthenticationManager}.
 */
@Configuration
public class ApplicationConfig {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    /**
     * Constructor para la inyección de dependencias.
     * @param userRepository Repositorio de usuarios.
     * @param passwordEncoder Codificador de contraseñas.
     */
    public ApplicationConfig(UserRepository userRepository, PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }

    /**
     * Define el {@link UserDetailsService} que Spring Security utilizará para cargar
     * los detalles del usuario durante el proceso de autenticación.
     * @return Una implementación de {@link UserDetailsService}.
     */
    @Bean
    public UserDetailsService userDetailsService() {
        return new UserDetailsServiceImpl(userRepository);
    }

    /**
     * Define el {@link AuthenticationProvider} que utiliza el {@link UserDetailsService}
     * y el {@link PasswordEncoder} para autenticar usuarios.
     * @return Una instancia de {@link AuthenticationProvider}.
     */
    @Bean
    public AuthenticationProvider authenticationProvider() {
        DaoAuthenticationProvider authProvider = new DaoAuthenticationProvider();
        authProvider.setUserDetailsService(userDetailsService());
        authProvider.setPasswordEncoder(passwordEncoder);
        return authProvider;
    }

    /**
     * Expone el {@link AuthenticationManager} desde la {@link AuthenticationConfiguration}.
     * Es utilizado para autenticar usuarios en el {@link AuthController}.
     * @param config Configuración de autenticación.
     * @return El {@link AuthenticationManager}.
     * @throws Exception Si ocurre un error al obtener el {@link AuthenticationManager}.
     */
    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration config) throws Exception {
        return config.getAuthenticationManager();
    }
}
