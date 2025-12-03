package com.easysports.service.impl;

import com.easysports.dto.team.CreateTeamRequest;
import com.easysports.dto.team.InvitarMiembroRequest;
import com.easysports.dto.team.TeamResponse;
import com.easysports.dto.team.UpdateTeamRequest;
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

        if (!equipo.getCapitan().getId().equals(capitanId)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "No tienes autorización para invitar a miembros a este equipo.");
        }

        User usuarioAInvitar = userRepository.findByEmail(request.getEmailUsuario())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Usuario a invitar no encontrado."));

        // ... (existing logic for checking membership status)

        MiembroEquipo nuevaInvitacion = new MiembroEquipo();
        // ... set fields ...
        nuevaInvitacion.setEquipo(equipo);
        nuevaInvitacion.setUsuario(usuarioAInvitar);


        miembroEquipoRepository.save(nuevaInvitacion);
    }

    @Override
    @Transactional
    public void aceptarInvitacion(Long equipoId, Authentication authentication) {
        UserDetailsImpl userDetails = (UserDetailsImpl) authentication.getPrincipal();
        Long usuarioId = userDetails.getUser().getId();

        MiembroEquipo invitacion = miembroEquipoRepository.findByUsuarioIdAndEquipoIdAndEstado(usuarioId, equipoId, EstadoMiembro.INVITADO_PENDIENTE)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "No se encontró una invitación pendiente para este equipo."));

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
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "No se encontró una invitación pendiente para este equipo."));

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
    @Transactional
    public void kickMember(Long teamId, Long memberId, Authentication authentication) {
        UserDetailsImpl userDetails = (UserDetailsImpl) authentication.getPrincipal();
        Long captainId = userDetails.getUser().getId();

        Team team = teamRepository.findById(teamId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Equipo no encontrado."));

        // ... authorization and validation ...

        MiembroEquipo membership = miembroEquipoRepository.findByEquipoIdAndUsuarioId(teamId, memberId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "El miembro especificado no pertenece a este equipo."));
        
        membership.setEstado(EstadoMiembro.EXPULSADO);
        membership.setFechaEstado(LocalDateTime.now());
        membership.setFechaIngreso(null);

        miembroEquipoRepository.save(membership);
    }

    @Override
    @Transactional
    public TeamResponse updateTeam(Long teamId, UpdateTeamRequest request, Authentication authentication) {
        UserDetailsImpl userDetails = (UserDetailsImpl) authentication.getPrincipal();
        Long captainId = userDetails.getUser().getId();

        Team team = teamRepository.findById(teamId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Equipo no encontrado."));

        if (team.getCapitan() == null || !team.getCapitan().getId().equals(captainId)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "No tienes autorización para editar este equipo.");
        }

        String oldName = team.getNombre();
        team.setNombre(request.getNombre());
        Team updatedTeam = teamRepository.save(team);

        return toResponse(updatedTeam);
    }

    @Override
    @Transactional(readOnly = true)
    public List<TeamResponse> getMisEquipos(Authentication authentication) {
        UserDetailsImpl userDetails = (UserDetailsImpl) authentication.getPrincipal();
        Long usuarioId = userDetails.getUser().getId();

        List<MiembroEquipo> relaciones = miembroEquipoRepository.findByUsuarioIdAndEstado(usuarioId, EstadoMiembro.ACEPTADO);
        List<MiembroEquipo> invitacionesPendientes = miembroEquipoRepository.findByUsuarioIdAndEstado(usuarioId, EstadoMiembro.INVITADO_PENDIENTE);

        relaciones.addAll(invitacionesPendientes);

        return relaciones.stream()
                .map(relacion -> toResponse(relacion.getEquipo()))
                .collect(Collectors.toList());
    }

    private TeamResponse toResponse(Team team) {
        return TeamResponse.builder()
                .id(team.getId())
                .nombre(team.getNombre())
                .tipoDeporte(team.getTipoDeporte())
                .capitanId(team.getCapitan() != null ? team.getCapitan().getId() : null)
                .partidosGanados(team.getPartidosGanados())
                .build();
    }
}