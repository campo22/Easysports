package com.easysports.service.impl;

import com.easysports.dto.team.CreateTeamRequest;
import com.easysports.dto.team.InvitarMiembroRequest;
import com.easysports.dto.team.TeamResponse;
import com.easysports.enums.Deporte;
import com.easysports.enums.EstadoMiembro;
import com.easysports.enums.RolMiembro;
import com.easysports.model.MiembroEquipo;
import com.easysports.model.Team;
import com.easysports.model.User;
import com.easysports.repository.MiembroEquipoRepository;
import com.easysports.repository.TeamRepository;
import com.easysports.repository.UserRepository;
import com.easysports.security.UserDetailsImpl;
import com.easysports.service.TeamService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Objects;
import java.util.stream.Collectors;

/**
 * Implementación del servicio de lógica de negocio para la gestión de equipos.
 */
@Service
@RequiredArgsConstructor
public class TeamServiceImpl implements TeamService {

    private final TeamRepository teamRepository;
    private final UserRepository userRepository;
    private final MiembroEquipoRepository miembroEquipoRepository;

    @Override
    @Transactional
    public TeamResponse createTeam(CreateTeamRequest request, Authentication authentication) {
        UserDetailsImpl userDetails = (UserDetailsImpl) authentication.getPrincipal();
        User capitan = userRepository.findById(userDetails.getUser().getId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Capitán no encontrado."));

        Team team = new Team();
        team.setNombre(request.getNombre());
        team.setTipoDeporte(Deporte.valueOf(request.getTipoDeporte().toUpperCase()));
        team.setCapitan(capitan);
        team.setPartidosGanados(0);

        Team savedTeam = teamRepository.save(team);

        MiembroEquipo miembroCapitan = new MiembroEquipo();
        miembroCapitan.setUsuario(capitan);
        miembroCapitan.setEquipo(savedTeam);
        miembroCapitan.setEstado(EstadoMiembro.ACEPTADO);
        miembroCapitan.setRol(RolMiembro.MIEMBRO);
        miembroCapitan.setFechaIngreso(LocalDateTime.now());
        miembroCapitan.setFechaEstado(LocalDateTime.now());

        miembroEquipoRepository.save(miembroCapitan);

        return toResponse(savedTeam);
    }

    @Override
    @Transactional
    public void invitarMiembro(Long equipoId, InvitarMiembroRequest request, Authentication authentication) {
        UserDetailsImpl userDetails = (UserDetailsImpl) authentication.getPrincipal();
        Long capitanId = userDetails.getUser().getId();

        Team equipo = teamRepository.findById(equipoId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Equipo no encontrado."));

        if (!Objects.equals(equipo.getCapitan().getId(), capitanId)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "No tienes autorización para invitar a miembros a este equipo.");
        }

        User usuarioAInvitar = userRepository.findByEmail(request.getEmailUsuario())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Usuario a invitar no encontrado."));

        // Validar si ya es miembro o tiene invitación pendiente
        if (miembroEquipoRepository.findByEquipoIdAndUsuarioId(equipoId, usuarioAInvitar.getId()).isPresent()) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "El usuario ya es miembro o tiene una invitación pendiente para este equipo.");
        }

        MiembroEquipo nuevaInvitacion = MiembroEquipo.builder()
                .equipo(equipo)
                .usuario(usuarioAInvitar)
                .estado(EstadoMiembro.INVITADO_PENDIENTE)
                .rol(RolMiembro.MIEMBRO) // Rol por defecto, puede ser cambiado por el capitán luego
                .fechaEstado(LocalDateTime.now())
                .build();

        miembroEquipoRepository.save(nuevaInvitacion);
    }

    @Override
    @Transactional
    public void aceptarInvitacion(Long equipoId, Authentication authentication) {
        UserDetailsImpl userDetails = (UserDetailsImpl) authentication.getPrincipal();
        Long usuarioId = userDetails.getUser().getId();

        MiembroEquipo invitacion = miembroEquipoRepository.findByUsuarioIdAndEquipoIdAndEstado(usuarioId, equipoId, EstadoMiembro.INVITADO_PENDIENTE)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "No se encontró una invitación pendiente para este equipo para el usuario actual."));

        invitacion.setEstado(EstadoMiembro.ACEPTADO);
        invitacion.setFechaIngreso(LocalDateTime.now());
        invitacion.setFechaEstado(LocalDateTime.now());

        miembroEquipoRepository.save(invitacion);
    }

    @Override
    @Transactional
    public void rechazarInvitacion(Long equipoId, Authentication authentication) {
        UserDetailsImpl userDetails = (UserDetailsImpl) authentication.getPrincipal();
        Long usuarioId = userDetails.getUser().getId();

        MiembroEquipo invitacion = miembroEquipoRepository.findByUsuarioIdAndEquipoIdAndEstado(usuarioId, equipoId, EstadoMiembro.INVITADO_PENDIENTE)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "No se encontró una invitación pendiente para este equipo para el usuario actual."));

        invitacion.setEstado(EstadoMiembro.RECHAZADO);
        invitacion.setFechaEstado(LocalDateTime.now());
        miembroEquipoRepository.save(invitacion);
    }

    @Override
    @Transactional(readOnly = true)
    public TeamResponse findById(Long id) {
        return teamRepository.findById(id)
                .map(this::toResponse)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Equipo no encontrado con ID: " + id));
    }

    @Override
    @Transactional(readOnly = true)
    public List<TeamResponse> getMisEquipos(Authentication authentication) {
        UserDetailsImpl userDetails = (UserDetailsImpl) authentication.getPrincipal();
        Long usuarioId = userDetails.getUser().getId();

        List<MiembroEquipo> relaciones = miembroEquipoRepository.findByUsuarioIdAndEstado(usuarioId, EstadoMiembro.ACEPTADO);
        List<MiembroEquipo> invitacionesPendientes = miembroEquipoRepository.findByUsuarioIdAndEstado(usuarioId, EstadoMiembro.INVITADO_PENDIENTE);

        // Combinar ambas listas y convertir a DTOs, evitando duplicados si fuera el caso
        return relaciones.stream()
                .map(MiembroEquipo::getEquipo)
                .collect(Collectors.toSet()) // Usar Set para eliminar duplicados de equipos
                .stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional
    public void expulsarMiembro(Long equipoId, Long usuarioId, Authentication authentication) {
        UserDetailsImpl userDetails = (UserDetailsImpl) authentication.getPrincipal();
        Long capitanId = userDetails.getUser().getId();

        Team equipo = teamRepository.findById(equipoId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Equipo no encontrado."));

        if (!Objects.equals(equipo.getCapitan().getId(), capitanId)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "No tienes autorización para expulsar miembros de este equipo.");
        }

        MiembroEquipo membresia = miembroEquipoRepository.findByEquipoIdAndUsuarioId(equipoId, usuarioId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "La relación miembro-equipo no existe."));

        // No se puede expulsar al capitán del equipo
        if (Objects.equals(equipo.getCapitan().getId(), usuarioId)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "No se puede expulsar al capitán del equipo.");
        }

        // Cambiamos el estado a EXPULSADO
        membresia.setEstado(EstadoMiembro.EXPULSADO);
        membresia.setFechaEstado(LocalDateTime.now());
        membresia.setFechaIngreso(null);

        miembroEquipoRepository.save(membresia);
    }

    @Override
    @Transactional
    public TeamResponse updateTeam(Long equipoId, com.easysports.dto.team.UpdateTeamRequest request, Authentication authentication) {
        UserDetailsImpl userDetails = (UserDetailsImpl) authentication.getPrincipal();
        Long capitanId = userDetails.getUser().getId();

        Team equipo = teamRepository.findById(equipoId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Equipo no encontrado."));

        if (!Objects.equals(equipo.getCapitan().getId(), capitanId)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "No tienes autorización para editar este equipo.");
        }

        equipo.setNombre(request.getNombre());
        equipo.setTipoDeporte(request.getTipoDeporte());

        Team equipoActualizado = teamRepository.save(equipo);

        return toResponse(equipoActualizado);
    }

    @Override
    @Transactional(readOnly = true)
    public List<TeamResponse> getAllTeams() {
        return teamRepository.findAll().stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    private TeamResponse toResponse(Team team) {
        List<com.easysports.dto.team.MiembroResponse> miembrosResponse = team.getMiembrosEquipo() != null
                ? team.getMiembrosEquipo().stream()
                .filter(m -> m.getEstado() == EstadoMiembro.ACEPTADO)
                .map(m -> com.easysports.dto.team.MiembroResponse.builder()
                        .id(m.getUsuario().getId())
                        .nombreCompleto(m.getUsuario().getNombreCompleto())
                        .email(m.getUsuario().getEmail())
                        .esCapitan(Objects.equals(m.getUsuario().getId(), team.getCapitan().getId()))
                        .build())
                .collect(Collectors.toList())
                : java.util.Collections.emptyList();

        return TeamResponse.builder()
                .id(team.getId())
                .nombre(team.getNombre())
                .tipoDeporte(team.getTipoDeporte())
                .capitanId(team.getCapitan() != null ? team.getCapitan().getId() : null)
                .partidosGanados(team.getPartidosGanados())
                .miembros(miembrosResponse)
                .build();
    }
}
