package com.easysports.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

/**
 * Configuración de CORS (Cross-Origin Resource Sharing) para la aplicación.
 * Permite definir qué orígenes, métodos y cabeceras están permitidos para acceder a la API.
 */
@Configuration
public class CorsConfig {

    /**
     * Configura el comportamiento de CORS para la aplicación.
     * En un entorno de desarrollo, se permite acceso desde cualquier origen para facilitar las pruebas.
     * En producción, esta configuración debería ser más restrictiva.
     * @return Una instancia de {@link WebMvcConfigurer} con las reglas de CORS.
     */
    @Bean
    public WebMvcConfigurer corsConfigurer() {
        return new WebMvcConfigurer() {
            @Override
            public void addCorsMappings(CorsRegistry registry) {
                registry.addMapping("/**") // Aplica la configuración a todas las rutas de la API
                        .allowedOrigins("*") // Permite acceso desde cualquier origen (AJUSTAR PARA PRODUCCIÓN)
                        .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS") // Métodos HTTP permitidos
                        .allowedHeaders("*"); // Cabeceras HTTP permitidas
            }
        };
    }
}
