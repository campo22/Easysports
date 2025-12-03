package com.easysports.service.impl;

import com.easysports.dto.team.CreateTeamRequest;
import com.easysports.dto.team.InvitarMiembroRequest;
import com.easysports.dto.team.TeamResponse;
import com.easysports.enums.Deporte;
import com.easysports.enums.EstadoMiembro;
import com.easysports.enums.RolMiembro;
import com.easysports.model.Team;
import com.easysports.model.User;
import com.easysports.model.MiembroEquipo;
import com.easysports.repository.MiembroEquipoRepository;
import com.easysports.repository.TeamRepository;
import com.easysports.repository.UserRepository;
import com.easysports.security.UserDetailsImpl;
import com.easysports.service.TeamService;
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
public class TeamServiceImpl implements TeamService {

    private final TeamRepository teamRepository;
    private final UserRepository userRepository;
    private final MiembroEquipoRepository miembroEquipoRepository;

    public TeamServiceImpl(TeamRepository teamRepository, UserRepository userRepository, MiembroEquipoRepository miembroEquipoRepository) {
        this.teamRepository = teamRepository;
        this.userRepository = userRepository;
        this.miembroEquipoRepository = miembroEquipoRepository;
    }

    @Override
    @Transactional
    public TeamResponse createTeam(CreateTeamRequest request, Authentication authentication) {
        // Obtener el usuario autenticado (el capitán)
        UserDetailsImpl userDetails = (UserDetailsImpl) authentication.getPrincipal();
        User capitan = userRepository.findById(userDetails.getUser().getId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Capitán no encontrado."));

        // Crear el equipo
        Team team = new Team();
        team.setNombre(request.getNombre());
        team.setTipoDeporte(Deporte.valueOf(request.getTipoDeporte().toUpperCase()));
        team.setCapitan(capitan);
        team.setPartidosGanados(0);

        teamRepository.save(team);

        // Crear la relación MiembroEquipo para el capitán con rol MIEMBRO y estado ACEPTADO
        MiembroEquipo miembroCapitan = new MiembroEquipo();
        miembroCapitan.setUsuario(capitan);
        miembroCapitan.setEquipo(team);
        miembroCapitan.setEstado(EstadoMiembro.ACEPTADO);
        miembroCapitan.setRol(RolMiembro.MIEMBRO);
        miembroCapitan.setFechaIngreso(LocalDateTime.now());
        miembroCapitan.setFechaEstado(LocalDateTime.now());

        miembroEquipoRepository.save(miembroCapitan);

        // Devolver la respuesta usando el helper
        return toResponse(team);
    }

    @Override
    @Transactional
    public void invitarMiembro(Long equipoId, InvitarMiembroRequest request, Authentication authentication) {
        // 1. Obtener el equipo y verificar que el usuario autenticado es el capitán
        UserDetailsImpl userDetails = (UserDetailsImpl) authentication.getPrincipal();
        Long capitánId = userDetails.getUser().getId();

        Team equipo = teamRepository.findById(equipoId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Equipo no encontrado."));

        if (!equipo.getCapitan().getId().equals(capitánId)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "No tienes autorización para invitar a miembros a este equipo.");
        }

        // 2. Buscar el usuario a invitar por email
        User usuarioAInvitar = userRepository.findByEmail(request.getEmailUsuario())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Usuario a invitar no encontrado."));

        // 3. Verificar si ya existe una relación (invitación pendiente o membresía aceptada)
        MiembroEquipo invitacionExistente = miembroEquipoRepository.findByEquipoIdAndUsuarioId(equipoId, usuarioAInvitar.getId()).orElse(null);

        if (invitacionExistente != null) {
            EstadoMiembro estadoExistente = invitacionExistente.getEstado();
            if (estadoExistente == EstadoMiembro.INVITADO_PENDIENTE) {
                throw new ResponseStatusException(HttpStatus.CONFLICT, "Ya existe una invitación pendiente para este usuario en este equipo.");
            } else if (estadoExistente == EstadoMiembro.ACEPTADO) {
                throw new ResponseStatusException(HttpStatus.CONFLICT, "El usuario ya es miembro de este equipo.");
            }
            if (estadoExistente == EstadoMiembro.RECHAZADO || estadoExistente == EstadoMiembro.EXPULSADO) {
                // Actualizar la invitación existente para re-activarla
                invitacionExistente.setEstado(EstadoMiembro.INVITADO_PENDIENTE);
                invitacionExistente.setRol(RolMiembro.MIEMBRO); // Rol por defecto
                invitacionExistente.setFechaEstado(LocalDateTime.now());
                miembroEquipoRepository.save(invitacionExistente);
                return;
            }
        }

        // 4. Crear la nueva relación MiembroEquipo con estado INVITADO_PENDIENTE
        MiembroEquipo nuevaInvitacion = new MiembroEquipo();
        nuevaInvitacion.setUsuario(usuarioAInvitar);
        nuevaInvitacion.setEquipo(equipo);
        nuevaInvitacion.setEstado(EstadoMiembro.INVITADO_PENDIENTE);
        nuevaInvitacion.setRol(RolMiembro.MIEMBRO); // Rol por defecto
        nuevaInvitacion.setFechaEstado(LocalDateTime.now());

        miembroEquipoRepository.save(nuevaInvitacion);
    }

    @Override
    @Transactional
    public void aceptarInvitacion(Long equipoId, Authentication authentication) {
        // 1. Obtener el usuario autenticado
        UserDetailsImpl userDetails = (UserDetailsImpl) authentication.getPrincipal();
        Long usuarioId = userDetails.getUser().getId();

        // 2. Buscar la invitación pendiente específica para este usuario y equipo
        MiembroEquipo invitacion = miembroEquipoRepository.findByUsuarioIdAndEquipoIdAndEstado(usuarioId, equipoId, EstadoMiembro.INVITADO_PENDIENTE)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "No se encontró una invitación pendiente para este equipo."));

        // 3. Actualizar el estado a ACEPTADO y la fecha de ingreso
        invitacion.setEstado(EstadoMiembro.ACEPTADO);
        invitacion.setFechaIngreso(LocalDateTime.now());
        invitacion.setFechaEstado(LocalDateTime.now());

        miembroEquipoRepository.save(invitacion);
    }

    @Override
    @Transactional
    public void rechazarInvitacion(Long equipoId, Authentication authentication) {
        // 1. Obtener el usuario autenticado
        UserDetailsImpl userDetails = (UserDetailsImpl) authentication.getPrincipal();
        Long usuarioId = userDetails.getUser().getId();

        // 2. Buscar la invitación pendiente específica para este usuario y equipo
        MiembroEquipo invitacion = miembroEquipoRepository.findByUsuarioIdAndEquipoIdAndEstado(usuarioId, equipoId, EstadoMiembro.INVITADO_PENDIENTE)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "No se encontró una invitación pendiente para este equipo."));

        // 3. Actualizar el estado a RECHAZADO
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
        // 1. Obtener el usuario autenticado
        UserDetailsImpl userDetails = (UserDetailsImpl) authentication.getPrincipal();
        Long usuarioId = userDetails.getUser().getId();

        // 2. Buscar todas las relaciones MiembroEquipo para este usuario (pendientes, aceptadas, etc.)
        List<MiembroEquipo> relaciones = miembroEquipoRepository.findByUsuarioIdAndEstado(usuarioId, EstadoMiembro.ACEPTADO);
        List<MiembroEquipo> invitacionesPendientes = miembroEquipoRepository.findByUsuarioIdAndEstado(usuarioId, EstadoMiembro.INVITADO_PENDIENTE);

        // Combinar ambas listas
        relaciones.addAll(invitacionesPendientes);

        // 3. Mapear a TeamResponse usando el helper
        return relaciones.stream()
                .map(relacion -> toResponse(relacion.getEquipo()))
                .collect(Collectors.toList());
    }

    /**
     * Convierte una entidad Team a un DTO TeamResponse.
     *
     * @param team La entidad Team a convertir.
     * @return El DTO TeamResponse.
     */
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
