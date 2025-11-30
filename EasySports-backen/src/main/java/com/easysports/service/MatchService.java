package com.easysports.service;

import com.easysports.dto.match.MatchRequest;
import com.easysports.dto.match.MatchResponse;
import com.easysports.dto.match.JoinMatchRequest; // Importar el nuevo DTO
import org.springframework.security.core.Authentication; // Importar Authentication

/**
 * Interfaz para el servicio de gestión de encuentros (partidos).
 * Define los métodos para la lógica de negocio de los partidos.
 */
public interface MatchService {

    /**
     * Crea un nuevo encuentro deportivo.
     *
     * @param request Datos para la creación del encuentro.
     * @param authentication Contexto de autenticación del usuario.
     * @return DTO con la información del encuentro creado.
     */
    MatchResponse createMatch(MatchRequest request, Authentication authentication); // Añadir Authentication

    /**
     * Permite a un usuario autenticado unirse a un encuentro.
     *
     * @param codigo Codigo del encuentro al que se quiere unir.
     * @param authentication Contexto de autenticación del usuario.
     * @return DTO con la información del encuentro actualizado.
     */
    MatchResponse joinMatch(String codigo, Authentication authentication); // Nuevo método
}
