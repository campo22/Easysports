package com.easysports.service;

import com.easysports.dto.match.MatchRequest;
import com.easysports.dto.match.MatchResponse;
import com.easysports.enums.Deporte;
import com.easysports.enums.MatchStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.core.Authentication;

import java.time.LocalDateTime;

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
    MatchResponse createMatch(MatchRequest request, Authentication authentication);

    /**
     * Permite a un usuario autenticado unirse a un encuentro.
     *
     * @param codigo Codigo del encuentro al que se quiere unir.
     * @param authentication Contexto de autenticación del usuario.
     * @return DTO con la información del encuentro actualizado.
     */
    MatchResponse joinMatch(String codigo, Authentication authentication);

    /**
     * Busca y devuelve una lista paginada de encuentros aplicando criterios de filtro.
     *
     * @param deporte Filtro por deporte (opcional).
     * @param estado Filtro por estado del encuentro (opcional).
     * @param fechaDesde Filtro por fecha de inicio (opcional).
     * @param fechaHasta Filtro por fecha de fin (opcional).
     * @param pageable Objeto con la información de paginación y ordenamiento.
     * @return Una página de DTOs con la información de los encuentros encontrados.
     */
    Page<MatchResponse> findAll(Deporte deporte, MatchStatus estado, LocalDateTime fechaDesde, LocalDateTime fechaHasta, Pageable pageable);

    /**
     * Busca un encuentro por su código único y devuelve sus detalles.
     *
     * @param codigo El código único del encuentro.
     * @return DTO con la información del encuentro.
     */
    MatchResponse findByCodigo(String codigo);

    /**
     * Registra el resultado de un encuentro.
     *
     * @param codigo El código único del encuentro.
     * @param request DTO con los datos del resultado.
     * @param authentication Contexto de autenticación del usuario.
     * @return DTO con la información actualizada del encuentro.
     */
    MatchResponse submitResult(String codigo, com.easysports.dto.match.SubmitResultRequest request, Authentication authentication);

    /**
     * Cancela un encuentro.
     *
     * @param codigo El código único del encuentro.
     * @param authentication Contexto de autenticación del usuario.
     * @return DTO con la información actualizada del encuentro.
     */
    MatchResponse cancelMatch(String codigo, Authentication authentication);
}