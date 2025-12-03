package com.easysports.service.impl;

import com.easysports.dto.liga.TablaPosicionesResponse;
import com.easysports.model.Liga;
import com.easysports.model.TablaDePosiciones;
import com.easysports.repository.LigaRepository;
import com.easysports.repository.TablaDePosicionesRepository;
import com.easysports.service.LigaService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

/**
 * Implementación del servicio de lógica de negocio para la gestión de ligas.
 */
@Service
@RequiredArgsConstructor
public class LigaServiceImpl implements LigaService {

    private final LigaRepository ligaRepository;
    private final TablaDePosicionesRepository tablaDePosicionesRepository;

    @Override
    @Transactional(readOnly = true)
    public List<TablaPosicionesResponse> getClasificacion(Long ligaId) {
        Liga liga = ligaRepository.findById(ligaId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Liga no encontrada con ID: " + ligaId));

        List<TablaDePosiciones> clasificacion = tablaDePosicionesRepository.findByLiga(liga);

        // Ordenar por puntos (descendente) y luego por partidos ganados (descendente)
        clasificacion.sort(Comparator
                .comparing(TablaDePosiciones::getPuntos, Comparator.reverseOrder())
                .thenComparing(TablaDePosiciones::getPartidosGanados, Comparator.reverseOrder())
                .thenComparing(TablaDePosiciones::getPartidosEmpatados, Comparator.reverseOrder())
        );

        return clasificacion.stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    /**
     * Convierte una entidad TablaDePosiciones a un DTO TablaPosicionesResponse.
     *
     * @param tablaDePosiciones La entidad TablaDePosiciones a convertir.
     * @return El DTO TablaDePosicionesResponse.
     */
    private TablaPosicionesResponse toResponse(TablaDePosiciones tablaDePosiciones) {
        return TablaPosicionesResponse.builder()
                .equipoId(tablaDePosiciones.getEquipo().getId())
                .nombreEquipo(tablaDePosiciones.getEquipo().getNombre())
                .ligaId(tablaDePosiciones.getLiga().getId())
                .nombreLiga(tablaDePosiciones.getLiga().getNombre())
                .deporteLiga(tablaDePosiciones.getLiga().getDeporte())
                .puntos(tablaDePosiciones.getPuntos())
                .partidosJugados(tablaDePosiciones.getPartidosJugados())
                .partidosGanados(tablaDePosiciones.getPartidosGanados())
                .partidosPerdidos(tablaDePosiciones.getPartidosPerdidos())
                .partidosEmpatados(tablaDePosiciones.getPartidosEmpatados())
                .build();
    }
}