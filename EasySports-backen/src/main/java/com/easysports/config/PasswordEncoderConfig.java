package com.easysports.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;

/**
 * Clase de configuración para la gestión de codificación de contraseñas.
 * Provee un bean {@link BCryptPasswordEncoder} para ser utilizado en toda la aplicación.
 */
@Configuration
public class PasswordEncoderConfig {

    /**
     * Define y provee una instancia de {@link BCryptPasswordEncoder} como un bean de Spring.
     * Este codificador se utiliza para hashear y verificar contraseñas de forma segura.
     * @return Una instancia de {@link BCryptPasswordEncoder}.
     */
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}
