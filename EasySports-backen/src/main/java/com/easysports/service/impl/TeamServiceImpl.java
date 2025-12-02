package com.easysports.service.impl;

import com.easysports.dto.team.CreateTeamRequest;
import com.easysports.dto.team.InvitarMiembroRequest; // Importar
import com.easysports.dto.team.TeamResponse;
import com.easysports.dto.team.MiembroEquipoResponse; // Importar si se usa en getMisEquipos
import com.easysports.enums.Deporte;
import com.easysports.enums.EstadoMiembro; // Importar
import com.easysports.enums.RolMiembro; // Importar
import com.easysports.model.Team;
import com.easysports.model.User;
import com.easysports.model.MiembroEquipo; // Importar
import com.easysports.repository.TeamRepository;
import com.easysports.repository.UserRepository;
import com.easysports.repository.MiembroEquipoRepository; // Importar
import com.easysports.security.UserDetailsImpl;
import com.easysports.service.TeamService;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;
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
    private final MiembroEquipoRepository miembroEquipoRepository; // Inyectar

    public TeamServiceImpl(TeamRepository teamRepository, UserRepository userRepository, MiembroEquipoRepository miembroEquipoRepository) { // Añadir al constructor
        this.teamRepository = teamRepository;
        this.userRepository = userRepository;
        this.miembroEquipoRepository = miembroEquipoRepository; // Inicializar
    }

    @Override
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

        // Crear la relación MiembroEquipo para el capitán con rol CAPITAN y estado ACEPTADO
        // Nota: El rol CAPITAN ya está implícito en el modelo Team (capitan_id).
        // Podríamos crear una entrada en MiembroEquipo con rol MIEMBRO para el capitán también si es necesario para la lógica de listado.
        // Por ahora, solo lo creamos como miembro ACEPTADO.
        MiembroEquipo miembroCapitan = new MiembroEquipo();
        miembroCapitan.setUsuario(capitan);
        miembroCapitan.setEquipo(team);
        miembroCapitan.setEstado(EstadoMiembro.ACEPTADO);
        miembroCapitan.setRol(RolMiembro.MIEMBRO); // El rol de capitán está en la entidad Team
        miembroCapitan.setFechaIngreso(LocalDateTime.now());
        miembroCapitan.setFechaEstado(LocalDateTime.now());

        miembroEquipoRepository.save(miembroCapitan);

        // Devolver la respuesta
        return TeamResponse.builder()
                .id(team.getId())
                .nombre(team.getNombre())
                .tipoDeporte(team.getTipoDeporte())
                .capitanId(team.getCapitan().getId())
                .partidosGanados(team.getPartidosGanados())
                .build();
    }

    @Override
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
        // Opcional: Verificar si ya es miembro de otro equipo del mismo deporte
        // (esta lógica de exclusión por deporte se puede implementar aquí)

        // Verificar si ya tiene una invitación pendiente o es miembro
        // Opcional: Podríamos permitir múltiples invitaciones pendientes o solo una, y re-enviar la última.
        // En este caso, si ya existe una relación (pendiente o aceptada), no se permite re-invitar.
        // Buscamos por equipoId y usuarioId para ver si hay una entrada previa.
        MiembroEquipo invitacionExistente = miembroEquipoRepository.findByEquipoIdAndUsuarioId(equipoId, usuarioAInvitar.getId()).orElse(null);

        if (invitacionExistente != null) {
            EstadoMiembro estadoExistente = invitacionExistente.getEstado();
            if (estadoExistente == EstadoMiembro.INVITADO_PENDIENTE) {
                throw new ResponseStatusException(HttpStatus.CONFLICT, "Ya existe una invitación pendiente para este usuario en este equipo.");
            } else if (estadoExistente == EstadoMiembro.ACEPTADO) {
                throw new ResponseStatusException(HttpStatus.CONFLICT, "El usuario ya es miembro de este equipo.");
            }
            // Si el estado es RECHAZADO o EXPULSADO, podríamos permitir re-invitar.
            // Por simplicidad inicial, solo permitiremos re-invitar si no hay estado activo o pendiente.
            // En una implementación más compleja, podríamos tener lógica para manejar RECHAZADO/EXPULSADO.
            // Por ahora, si no es PENDIENTE o ACEPTADO, asumiremos que se puede crear una nueva invitación.
            // Para evitar conflictos, eliminamos la entrada anterior si no es ACEPTADO o PENDIENTE.
            // O mejor, solo permitimos crear si no existe una entrada PENDIENTE o ACEPTADA.
            // Revisamos la condición: si `invitacionExistente` no es null y su estado es PENDIENTE o ACEPTADO, lanzamos error.
            // Si no es PENDIENTE o ACEPTADO, significa que es RECHAZADO o EXPULSADO, y permitimos crear una nueva.
            // Pero hay un problema: si es RECHAZADO o EXPULSADO, ¿queremos sobrescribir esa entrada o crear una nueva?
            // Para mantener coherencia y permitir re-invitar a alguien que rechazó, lo ideal es sobrescribir el estado.
            // Pero para simplificar, asumiremos que solo puede haber 1 relación activa (PENDIENTE o ACEPTADA) o ninguna.
            // La lógica siguiente se encarga de eso.
            // Si `invitacionExistente` es null, creamos una nueva.
            // Si `invitacionExistente` no es null y es PENDIENTE -> Error.
            // Si `invitacionExistente` no es null y es ACEPTADO -> Error.
            // Si `invitacionExistente` no es null y es RECHAZADO o EXPULSADO -> Actualizamos el estado y fechas.
            if (estadoExistente == EstadoMiembro.RECHAZADO || estadoExistente == EstadoMiembro.EXPULSADO) {
                // Actualizar la invitación existente para re-activarla
                invitacionExistente.setEstado(EstadoMiembro.INVITADO_PENDIENTE);
                invitacionExistente.setRol(RolMiembro.MIEMBRO); // Rol por defecto
                invitacionExistente.setFechaEstado(LocalDateTime.now());
                miembroEquipoRepository.save(invitacionExistente);
                return; // Terminamos
            }
            // Si llega aquí y no es RECHAZADO o EXPULSADO, es PENDIENTE o ACEPTADO, y ya lanzamos error antes.
        }

        // 4. Crear la nueva relación MiembroEquipo con estado INVITADO_PENDIENTE
        MiembroEquipo nuevaInvitacion = new MiembroEquipo();
        nuevaInvitacion.setUsuario(usuarioAInvitar);
        nuevaInvitacion.setEquipo(equipo);
        nuevaInvitacion.setEstado(EstadoMiembro.INVITADO_PENDIENTE);
        nuevaInvitacion.setRol(RolMiembro.MIEMBRO); // Rol por defecto
        nuevaInvitacion.setFechaEstado(LocalDateTime.now());
        // fechaIngreso se dejará como null hasta que acepte

        miembroEquipoRepository.save(nuevaInvitacion);
    }

    @Override
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
    public List<TeamResponse> getMisEquipos(Authentication authentication) {
        // 1. Obtener el usuario autenticado
        UserDetailsImpl userDetails = (UserDetailsImpl) authentication.getPrincipal();
        Long usuarioId = userDetails.getUser().getId();

        // 2. Buscar todas las relaciones MiembroEquipo para este usuario (pendientes, aceptadas, etc.)
        // Filtramos solo las que están ACEPTADAS o PENDIENTES para mostrarlas como "sus equipos"
        // Opcional: Mostrar también los rechazados/expulsados si se considera relevante
        List<MiembroEquipo> relaciones = miembroEquipoRepository.findByUsuarioIdAndEstado(usuarioId, EstadoMiembro.ACEPTADO);
        List<MiembroEquipo> invitacionesPendientes = miembroEquipoRepository.findByUsuarioIdAndEstado(usuarioId, EstadoMiembro.INVITADO_PENDIENTE);

        // Combinar ambas listas
        relaciones.addAll(invitacionesPendientes);

        // 3. Mapear a TeamResponse
        // Opcional: Incluir el estado de la membresía en el TeamResponse
        return relaciones.stream()
                .map(relacion -> {
                    Team equipo = relacion.getEquipo();
                    return TeamResponse.builder()
                            .id(equipo.getId())
                            .nombre(equipo.getNombre())
                            .tipoDeporte(equipo.getTipoDeporte())
                            .capitanId(equipo.getCapitan().getId())
                            .partidosGanados(equipo.getPartidosGanados())
                            // .estadoMiembro(relacion.getEstado()) // Opcional: agregar estado al DTO
                            .build();
                })
                .collect(Collectors.toList());
    }
}