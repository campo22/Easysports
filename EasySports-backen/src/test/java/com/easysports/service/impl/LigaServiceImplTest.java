package com.easysports.service.impl;

import com.easysports.dto.liga.TablaPosicionesResponse;
import com.easysports.enums.Deporte;
import com.easysports.model.Liga;
import com.easysports.model.TablaDePosiciones;
import com.easysports.model.Team;
import com.easysports.repository.LigaRepository;
import com.easysports.repository.TablaDePosicionesRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;

import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class LigaServiceImplTest {

    @Mock
    private LigaRepository ligaRepository;
    @Mock
    private TablaDePosicionesRepository tablaDePosicionesRepository;

    @InjectMocks
    private LigaServiceImpl ligaService;

    @Test
    void givenExistingLiga_whenGetClasificacion_thenReturnsSortedStandings() {
        // Arrange
        Long ligaId = 1L;
        Liga liga = Liga.builder().id(ligaId).nombre("Liga Test").deporte(Deporte.FUTBOL).build();

        Team team1 = Team.builder().id(10L).nombre("Equipo A").build();
        Team team2 = Team.builder().id(20L).nombre("Equipo B").build();
        Team team3 = Team.builder().id(30L).nombre("Equipo C").build();

        TablaDePosiciones td1 = TablaDePosiciones.builder().id(100L).liga(liga).equipo(team1)
                .puntos(10).partidosJugados(5).partidosGanados(3).partidosEmpatados(1).partidosPerdidos(1).build();
        TablaDePosiciones td2 = TablaDePosiciones.builder().id(200L).liga(liga).equipo(team2)
                .puntos(7).partidosJugados(5).partidosGanados(2).partidosEmpatados(1).partidosPerdidos(2).build();
        TablaDePosiciones td3 = TablaDePosiciones.builder().id(300L).liga(liga).equipo(team3)
                .puntos(12).partidosJugados(5).partidosGanados(4).partidosEmpatados(0).partidosPerdidos(1).build();

        // Ensure td3 (12 points) is before td1 (10 points) is before td2 (7 points)
        List<TablaDePosiciones> unsortedClasificacion = Arrays.asList(td1, td2, td3);

        when(ligaRepository.findById(ligaId)).thenReturn(Optional.of(liga));
        when(tablaDePosicionesRepository.findByLiga(liga)).thenReturn(unsortedClasificacion);

        // Act
        List<TablaPosicionesResponse> result = ligaService.getClasificacion(ligaId);

        // Assert
        assertThat(result).isNotNull().hasSize(3);
        assertThat(result.get(0).getEquipoId()).isEqualTo(team3.getId()); // Team C - 12 puntos
        assertThat(result.get(1).getEquipoId()).isEqualTo(team1.getId()); // Team A - 10 puntos
        assertThat(result.get(2).getEquipoId()).isEqualTo(team2.getId()); // Team B - 7 puntos
    }

    @Test
    void givenNonExistingLiga_whenGetClasificacion_thenThrowsNotFound() {
        // Arrange
        Long ligaId = 99L;
        when(ligaRepository.findById(ligaId)).thenReturn(Optional.empty());

        // Act & Assert
        ResponseStatusException exception = assertThrows(ResponseStatusException.class, () -> {
            ligaService.getClasificacion(ligaId);
        });

        assertThat(exception.getStatusCode()).isEqualTo(HttpStatus.NOT_FOUND);
        assertThat(exception.getReason()).contains("Liga no encontrada con ID: " + ligaId);
    }
}
