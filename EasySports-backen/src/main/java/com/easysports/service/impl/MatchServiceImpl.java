package com.easysports.service.impl;

import com.easysports.dto.match.MatchRequest;
import com.easysports.dto.match.MatchResponse;
import com.easysports.enums.MatchStatus;
import com.easysports.enums.MatchType;
import com.easysports.model.Court;
import com.easysports.model.Match;
import com.easysports.model.Participant; // Importar
import com.easysports.model.Team;
import com.easysports.model.User;
import com.easysports.repository.CourtRepository;
import com.easysports.repository.MatchRepository;
import com.easysports.repository.ParticipantRepository; // Importar
import com.easysports.repository.TeamRepository;
import com.easysports.repository.UserRepository;
import com.easysports.security.UserDetailsImpl;
import com.easysports.service.MatchService;
import lombok.RequiredArgsConstructor; // Importar
import org.springframework.dao.DataIntegrityViolationException; // Importar
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional; // Importar
import org.springframework.web.server.ResponseStatusException;

import java.time.LocalDateTime;
import java.util.Objects;
import java.util.Random; // Importar

/**
 * Implementación del servicio de lógica de negocio para la gestión de encuentros deportivos.
 */
@Service
@RequiredArgsConstructor
public class MatchServiceImpl implements MatchService {

    private final MatchRepository matchRepository;
    private final UserRepository userRepository;
    private final TeamRepository teamRepository;
    private final CourtRepository courtRepository;
    private final ParticipantRepository participantRepository;

    // Código alfanumérico
    private static final String ALPHANUM = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    // Longitud del código
    private static final int CODE_LENGTH = 6;
    // Generador de números aleatorios
    private final Random random = new Random();

    /**
     * Crear un encuentro (con todas las validaciones de negocio).
     * @param request DTO de creación
     * @param authentication contexto de seguridad
     * @return MatchResponse con el encuentro creado
     */
    @Override
    @Transactional
    public MatchResponse createMatch(MatchRequest request, Authentication authentication) {

        UserDetailsImpl userDetails = (UserDetailsImpl) authentication.getPrincipal();
        Long creatorId = userDetails.getUser().getId();
        User creador = userRepository.findById(creatorId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Creador no encontrado."));

        // --- 1. Validaciones temporales ---
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime fechaProgramada = request.getFechaProgramada();
        if (fechaProgramada == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "La fecha programada es obligatoria.");
        }
        // No en el pasado
        if (fechaProgramada.isBefore(now)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "La fecha programada no puede estar en el pasado.");
        }
        // Máximo 3 días en el futuro (incluye el día actual)
        if (fechaProgramada.isAfter(now.plusDays(3))) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "La fecha programada no puede ser superior a 3 días en el futuro.");
        }
        // Minutos múltiplos de 15
        int minute = fechaProgramada.getMinute();
        if (minute % 15 != 0) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "La hora del partido solo puede ser a los 00, 15, 30 o 45 minutos.");
        }

        // --- 2. Validar maxJugadores ---
        if (request.getMaxJugadores() == null || request.getMaxJugadores() <= 0) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "maxJugadores debe ser un entero positivo mayor que 0.");
        }

        // --- 3. Manejo de Cancha ---
        Court cancha = null;
        String nombreCanchaTexto = null;
        if (request.getCanchaId() != null) {
            cancha = courtRepository.findById(request.getCanchaId())
                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Cancha no encontrada."));
            // Validar solapamiento de partidos en la misma cancha y misma fecha/hora
            boolean ocupada = matchRepository.existsByCanchaAndFechaProgramada(cancha, fechaProgramada);
            if (ocupada) {
                throw new ResponseStatusException(HttpStatus.CONFLICT, "La cancha ya está ocupada en esa fecha y hora.");
            }
        } else if (request.getNombreCanchaTexto() != null && !request.getNombreCanchaTexto().isBlank()) {
            nombreCanchaTexto = request.getNombreCanchaTexto().trim();
        } else {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Debe especificar una cancha existente o un nombre de cancha.");
        }

        // --- 4. Manejo de Equipos para partidos FORMAL ---
        Team equipoLocal = null;
        Team equipoVisitante = null;
        if (request.getTipo() == MatchType.FORMAL) {
            // Debe tener al menos equipoLocalId (según reglas del proyecto)
            if (request.getEquipoLocalId() == null) {
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Para partidos formales, se debe especificar el equipo local.");
            }
            equipoLocal = teamRepository.findById(request.getEquipoLocalId())
                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Equipo local no encontrado."));
            // Solo el capitán del equipo local puede crear el partido formal
            if (equipoLocal.getCapitan() == null || !Objects.equals(equipoLocal.getCapitan().getId(), creador.getId())) {
                throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Solo el capitán del equipo local puede crear un partido formal.");
            }
            // visitante es opcional; si se proporciona, validar existencia
            if (request.getEquipoVisitanteId() != null) {
                equipoVisitante = teamRepository.findById(request.getEquipoVisitanteId())
                        .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Equipo visitante no encontrado."));
            }
        }

        // --- 5. Generar código único (manejar potencial colisión) ---
        String codigo;
        int attempts = 0;
        do {
            codigo = generateMatchCode();
            attempts++;
            // En teoría matchRepository.findByCodigo(...) es suficiente; para robustez, limitamos intentos
            if (attempts > 5) break;
        } while (matchRepository.findByCodigo(codigo).isPresent());


        Match match = new Match();
        match.setCodigo(codigo);
        match.setTipo(request.getTipo());
        match.setDeporte(request.getDeporte());
        match.setEstado(MatchStatus.ABIERTO);
        match.setFechaProgramada(fechaProgramada);
        match.setCancha(cancha);
        match.setNombreCanchaTexto(nombreCanchaTexto);
        match.setCreador(creador);
        match.setEquipoLocal(equipoLocal);
        match.setEquipoVisitante(equipoVisitante);
        match.setMaxJugadores(request.getMaxJugadores());
        match.setJugadoresActuales(1); // el creador cuenta como jugador

        try {
            matchRepository.save(match);
        } catch (DataIntegrityViolationException ex) {
            // reintentar generar otro código y guardar una vez más (último intento)
            match.setCodigo(generateMatchCode());
            matchRepository.save(match);
        }

        // --- 6. Registrar al creador en participantes (tabla pivote) ---
        Participant creatorParticipant = Participant.builder()
                .match(match)
                .user(creador)
                .joinedAt(LocalDateTime.now())
                .build();
        participantRepository.save(creatorParticipant);


        return toResponse(match);
    }

    /**
     * Unirse a un encuentro ya existente por código.
     * @param codigo código del encuentro
     * @param authentication contexto de seguridad
     * @return MatchResponse actualizado
     */
    @Override
    @Transactional
    public MatchResponse joinMatch(String codigo, Authentication authentication) {
        UserDetailsImpl userDetails = (UserDetailsImpl) authentication.getPrincipal();
        Long usuarioId = userDetails.getUser().getId();
        User usuario = userRepository.findById(usuarioId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Usuario no encontrado."));

        Match match = matchRepository.findByCodigo(codigo)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Encuentro no encontrado."));

        if (match.getEstado() != MatchStatus.ABIERTO) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "No puedes unirte a un encuentro que no está abierto.");
        }

        if (match.getJugadoresActuales() >= match.getMaxJugadores()) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "El encuentro está lleno.");
        }

        // Verificar si ya está inscrito (tabla pivote)
        boolean yaParticipa = participantRepository.existsByMatchAndUser(match, usuario);
        if (yaParticipa) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Ya estás inscrito en este encuentro.");
        }

        // El creador no puede unirse como participante adicional (ya está registrado)
        if (match.getCreador() != null && Objects.equals(match.getCreador().getId(), usuario.getId())) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "El creador del encuentro ya está participando.");
        }

        // Registrar participante
        Participant participant = Participant.builder()
                .match(match)
                .user(usuario)
                .joinedAt(LocalDateTime.now())
                .build();
        participantRepository.save(participant);

        // Actualizar contador de jugadores
        match.setJugadoresActuales(match.getJugadoresActuales() + 1);
        // Si alcanzó max, marcar LLENO
        if (match.getJugadoresActuales() >= match.getMaxJugadores()) {
            match.setEstado(MatchStatus.LLENO);
        }
        matchRepository.save(match);

        return toResponse(match);
    }

    /* --------------------- Helpers --------------------- */

    private MatchResponse toResponse(Match match) {
        return MatchResponse.builder()
                .id(match.getId())
                .codigo(match.getCodigo())
                .tipo(match.getTipo())
                .deporte(match.getDeporte())
                .estado(match.getEstado())
                .fechaProgramada(match.getFechaProgramada())
                .canchaId(match.getCancha() != null ? match.getCancha().getId() : null)
                .nombreCanchaTexto(match.getNombreCanchaTexto())
                .creadorId(match.getCreador() != null ? match.getCreador().getId() : null)
                .equipoLocalId(match.getEquipoLocal() != null ? match.getEquipoLocal().getId() : null)
                .equipoVisitanteId(match.getEquipoVisitante() != null ? match.getEquipoVisitante().getId() : null)
                .maxJugadores(match.getMaxJugadores())
                .jugadoresActuales(match.getJugadoresActuales())
                .build();
    }

    private String generateMatchCode() {
        StringBuilder sb = new StringBuilder(CODE_LENGTH);
        for (int i = 0; i < CODE_LENGTH; i++) {
            sb.append(ALPHANUM.charAt(random.nextInt(ALPHANUM.length())));
        }
        return sb.toString();
    }
}
