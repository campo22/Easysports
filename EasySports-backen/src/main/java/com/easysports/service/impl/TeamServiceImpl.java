package com.easysports.service.impl;

import com.easysports.dto.team.CreateTeamRequest;
import com.easysports.dto.team.TeamResponse;
import com.easysports.enums.Deporte;
import com.easysports.model.Team;
import com.easysports.model.User;
import com.easysports.repository.TeamRepository;
import com.easysports.repository.UserRepository;
import com.easysports.security.UserDetailsImpl;
import com.easysports.service.TeamService;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

/**
 * Implementación del servicio de lógica de negocio para la gestión de equipos.
 */
@Service
public class TeamServiceImpl implements TeamService {

    private final TeamRepository teamRepository;
    private final UserRepository userRepository;

    public TeamServiceImpl(TeamRepository teamRepository, UserRepository userRepository) {
        this.teamRepository = teamRepository;
        this.userRepository = userRepository;
    }

    @Override
    public TeamResponse createTeam(CreateTeamRequest request, Authentication authentication) {
        // Obtener el usuario autenticado (el capitán)
        UserDetailsImpl userDetails = (UserDetailsImpl) authentication.getPrincipal();
        User capitan = userRepository.findById(userDetails.getUser().getId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Capitán no encontrado."));

        // Verificar si ya existe un equipo con el mismo nombre
        // (Esto es opcional dependiendo de las reglas de negocio)
        // Team existingTeam = teamRepository.findByNombre(request.getNombre());
        // if (existingTeam != null) {
        //     throw new ResponseStatusException(HttpStatus.CONFLICT, "Ya existe un equipo con ese nombre.");
        // }

        // Crear el equipo
        Team team = new Team();
        team.setNombre(request.getNombre());
        team.setTipoDeporte(Deporte.valueOf(request.getTipoDeporte().toUpperCase())); // Validar el enum
        team.setCapitan(capitan);
        team.setPartidosGanados(0);

        // Asignar al capitán como primer miembro del equipo
        // (Esto también puede ser opcional, dependiendo de las reglas de negocio)
        // team.getMiembros().add(capitan); // Requiere inicializar la lista en el constructor o builder

        teamRepository.save(team);

        // Devolver la respuesta
        return TeamResponse.builder()
                .id(team.getId())
                .nombre(team.getNombre())
                .tipoDeporte(team.getTipoDeporte())
                .capitanId(team.getCapitan().getId())
                .partidosGanados(team.getPartidosGanados())
                .build();
    }
}