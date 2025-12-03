package com.easysports.service.impl;

import com.easysports.dto.team.TeamResponse;
import com.easysports.enums.Deporte;
import com.easysports.model.Team;
import com.easysports.model.User;
import com.easysports.repository.MiembroEquipoRepository;
import com.easysports.repository.TeamRepository;
import com.easysports.repository.UserRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;

import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class TeamServiceImplTest {

    @Mock
    private TeamRepository teamRepository;
    @Mock
    private UserRepository userRepository;
    @Mock
    private MiembroEquipoRepository miembroEquipoRepository;

    @InjectMocks
    private TeamServiceImpl teamService;

    @Test
    void givenExistingId_whenFindById_thenReturnsTeam() {
        // Arrange
        Long teamId = 1L;
        User capitan = new User();
        capitan.setId(10L); // Asignar un ID al capitán

        Team team = new Team();
        team.setId(teamId);
        team.setNombre("Los Campeones");
        team.setTipoDeporte(Deporte.FUTBOL);
        team.setCapitan(capitan);
        team.setPartidosGanados(5);

        when(teamRepository.findById(anyLong())).thenReturn(Optional.of(team));

        // Act
        TeamResponse result = teamService.findById(teamId);

        // Assert
        assertThat(result).isNotNull();
        assertThat(result.getId()).isEqualTo(teamId);
        assertThat(result.getNombre()).isEqualTo("Los Campeones");
        assertThat(result.getTipoDeporte()).isEqualTo(Deporte.FUTBOL);
        assertThat(result.getCapitanId()).isEqualTo(capitan.getId());
        assertThat(result.getPartidosGanados()).isEqualTo(5);

        verify(teamRepository).findById(teamId);
    }

    @Test
    void givenNonExistingId_whenFindById_thenThrowsNotFound() {
        // Arrange
        Long teamId = 99L;
        when(teamRepository.findById(anyLong())).thenReturn(Optional.empty());

        // Act & Assert
        ResponseStatusException exception = assertThrows(ResponseStatusException.class, () -> {
            teamService.findById(teamId);
        });

        assertThat(exception.getStatusCode()).isEqualTo(HttpStatus.NOT_FOUND);
        assertThat(exception.getReason()).contains("Equipo no encontrado con ID: " + teamId);

        verify(teamRepository).findById(teamId);
    }
}
