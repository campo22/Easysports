package com.easysports.config;

import com.easysports.security.JwtAuthenticationFilter;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationProvider;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

/**
 * Configuración principal de seguridad para la aplicación Spring Boot.
 * Habilita la seguridad web y la seguridad a nivel de métodos.
 */
@Configuration
@EnableWebSecurity
@EnableMethodSecurity(prePostEnabled = true) // Habilita anotaciones como @PreAuthorize
public class SecurityConfig {

    private final JwtAuthenticationFilter jwtAuthFilter;
    private final AuthenticationProvider authenticationProvider;

    /**
     * Constructor para inyección de dependencias.
     * @param jwtAuthFilter Filtro para la autenticación JWT.
     * @param authenticationProvider Proveedor de autenticación.
     */
    public SecurityConfig(JwtAuthenticationFilter jwtAuthFilter, AuthenticationProvider authenticationProvider) {
        this.jwtAuthFilter = jwtAuthFilter;
        this.authenticationProvider = authenticationProvider;
    }

    /**
     * Define la cadena de filtros de seguridad.
     * @param http Objeto HttpSecurity para configurar la seguridad HTTP.
     * @return La cadena de filtros de seguridad configurada.
     * @throws Exception Si ocurre un error durante la configuración.
     */
    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
                .csrf(AbstractHttpConfigurer::disable) // Deshabilita CSRF ya que usamos JWT (stateless)
                .authorizeHttpRequests(authorize -> authorize
                        // Rutas públicas que no requieren autenticación
                        .requestMatchers("/api/auth/**").permitAll()
                        // Todas las demás peticiones requieren autenticación
                        .anyRequest().authenticated()
                )
                .sessionManagement(session -> session
                        .sessionCreationPolicy(SessionCreationPolicy.STATELESS) // Sesiones sin estado para JWT
                )
                .authenticationProvider(authenticationProvider)
                .addFilterBefore(jwtAuthFilter, UsernamePasswordAuthenticationFilter.class); // Añade el filtro JWT

        return http.build();
    }
}
