package com.easysports.service.impl;

import com.easysports.dto.match.MatchResponse;
import com.easysports.enums.Deporte;
import com.easysports.enums.MatchStatus;
import com.easysports.model.Match;
import com.easysports.repository.CourtRepository;
import com.easysports.repository.MatchRepository;
import com.easysports.repository.ParticipantRepository;
import com.easysports.repository.TeamRepository;
import com.easysports.repository.UserRepository;
import com.easysports.service.specification.MatchSpecification;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class MatchServiceImplTest {

    @Mock
    private MatchRepository matchRepository;
    @Mock
    private UserRepository userRepository;
    @Mock
    private TeamRepository teamRepository;
    @Mock
    private CourtRepository courtRepository;
    @Mock
    private ParticipantRepository participantRepository;
    @Mock
    private MatchSpecification matchSpecification;

    @InjectMocks
    private MatchServiceImpl matchService;

    @Test
    void givenFilters_whenFindAll_thenReturnsCorrectPage() {
        // Arrange
        Deporte deporte = Deporte.FUTBOL;
        MatchStatus estado = MatchStatus.ABIERTO;
        LocalDateTime fechaDesde = LocalDateTime.now();
        LocalDateTime fechaHasta = LocalDateTime.now().plusDays(1);
        Pageable pageable = PageRequest.of(0, 10);

        Match match = new Match();
        match.setId(1L);
        match.setDeporte(deporte);
        match.setEstado(estado);

        List<Match> matches = List.of(match);
        Page<Match> matchPage = new PageImpl<>(matches, pageable, matches.size());
        
        Specification<Match> spec = (root, query, criteriaBuilder) -> null;

        when(matchSpecification.findByCriteria(deporte, estado, fechaDesde, fechaHasta)).thenReturn(spec);
        when(matchRepository.findAll(spec, pageable)).thenReturn(matchPage);

        // Act
        Page<MatchResponse> result = matchService.findAll(deporte, estado, fechaDesde, fechaHasta, pageable);

        // Assert
        assertThat(result).isNotNull();
        assertThat(result.getTotalElements()).isEqualTo(1);
        assertThat(result.getContent().get(0).getId()).isEqualTo(match.getId());
        assertThat(result.getContent().get(0).getDeporte()).isEqualTo(deporte);
        assertThat(result.getContent().get(0).getEstado()).isEqualTo(estado);

        verify(matchSpecification).findByCriteria(deporte, estado, fechaDesde, fechaHasta);
        verify(matchRepository).findAll(spec, pageable);
    }

    @Test
    void givenExistingCodigo_whenFindByCodigo_thenReturnsMatch() {
        // Arrange
        String codigo = "ABC123";
        Match match = new Match();
        match.setId(1L);
        match.setCodigo(codigo);
        match.setDeporte(Deporte.VOLEY);

        when(matchRepository.findByCodigo(codigo)).thenReturn(Optional.of(match));

        // Act
        MatchResponse result = matchService.findByCodigo(codigo);

        // Assert
        assertThat(result).isNotNull();
        assertThat(result.getId()).isEqualTo(match.getId());
        assertThat(result.getCodigo()).isEqualTo(codigo);
        assertThat(result.getDeporte()).isEqualTo(Deporte.VOLEY);

        verify(matchRepository).findByCodigo(codigo);
    }

    @Test
    void givenNonExistingCodigo_whenFindByCodigo_thenThrowsNotFound() {
        // Arrange
        String codigo = "XYZ789";
        when(matchRepository.findByCodigo(codigo)).thenReturn(Optional.empty());

        // Act & Assert
        ResponseStatusException exception = assertThrows(ResponseStatusException.class, () -> {
            matchService.findByCodigo(codigo);
        });

        assertThat(exception.getStatusCode()).isEqualTo(HttpStatus.NOT_FOUND);
        verify(matchRepository).findByCodigo(codigo);
    }
}