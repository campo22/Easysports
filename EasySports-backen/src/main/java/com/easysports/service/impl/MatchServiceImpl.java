package com.easysports.service.impl;

import com.easysports.dto.match.MatchRequest;
import com.easysports.dto.match.MatchResponse;
// No es necesario importar JoinMatchRequest aquí si no se usa en la firma del método
import com.easysports.enums.MatchStatus;
import com.easysports.enums.MatchType; // Importar MatchType
import com.easysports.model.Court;
import com.easysports.model.Match;
import com.easysports.model.Team; // Importar Team
import com.easysports.model.User; // Importar User
import com.easysports.repository.CourtRepository;
import com.easysports.repository.MatchRepository;
import com.easysports.repository.TeamRepository;
import com.easysports.repository.UserRepository;
import com.easysports.security.UserDetailsImpl; // Importar UserDetailsImpl
import com.easysports.service.MatchService;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication; // Importar Authentication
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.time.LocalDateTime;
import java.util.Random;

/**
 * Implementación del servicio de lógica de negocio para la gestión de encuentros deportivos.
 */
@Service
public class MatchServiceImpl implements MatchService {

    private final MatchRepository matchRepository;
    private final UserRepository userRepository;
    private final TeamRepository teamRepository; // Inyectar TeamRepository
    private final CourtRepository courtRepository;

    public MatchServiceImpl(MatchRepository matchRepository, UserRepository userRepository, TeamRepository teamRepository, CourtRepository courtRepository) {
        this.matchRepository = matchRepository;
        this.userRepository = userRepository;
        this.teamRepository = teamRepository; // Inicializar TeamRepository
        this.courtRepository = courtRepository;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public MatchResponse createMatch(MatchRequest request, Authentication authentication) {
        // Obtener el usuario autenticado
        UserDetailsImpl userDetails = (UserDetailsImpl) authentication.getPrincipal();
        User creador = userRepository.findById(userDetails.getUser().getId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Creador no encontrado."));

        // 1. Validar Regla de los 3 Días
        if (request.getFechaProgramada().isAfter(LocalDateTime.now().plusDays(3))) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "La fecha programada no puede ser superior a 3 días en el futuro.");
        }

        // 2. Validar Regla de los 15 Minutos
        int minute = request.getFechaProgramada().getMinute();
        if (minute != 0 && minute != 15 && minute != 30 && minute != 45) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "La hora del partido solo puede ser a los 00, 15, 30 o 45 minutos.");
        }

        // Validar partidos FORMALES
        Team equipoLocal = null;
        Team equipoVisitante = null;
        if (request.getTipo() == MatchType.FORMAL) {
            // Verificar si se proporcionaron IDs de equipos
            if (request.getEquipoLocalId() == null && request.getEquipoVisitanteId() == null) {
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Para partidos formales, se debe especificar al menos un equipo (local o visitante).");
            }

            // Verificar si el usuario es capitán de los equipos involucrados
            if (request.getEquipoLocalId() != null) {
                equipoLocal = teamRepository.findById(request.getEquipoLocalId())
                        .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Equipo local no encontrado."));
                if (!equipoLocal.getCapitan().getId().equals(creador.getId())) {
                    throw new ResponseStatusException(HttpStatus.FORBIDDEN, "No tienes autorización para crear un partido formal con este equipo local.");
                }
            }
            if (request.getEquipoVisitanteId() != null) {
                equipoVisitante = teamRepository.findById(request.getEquipoVisitanteId())
                        .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Equipo visitante no encontrado."));
                if (!equipoVisitante.getCapitan().getId().equals(creador.getId())) {
                    throw new ResponseStatusException(HttpStatus.FORBIDDEN, "No tienes autorización para crear un partido formal con este equipo visitante.");
                }
            }
        }

        // Manejar la cancha
        Court cancha = null;
        String nombreCanchaTexto = null;
        if (request.getCanchaId() != null) {
            cancha = courtRepository.findById(request.getCanchaId())
                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Cancha no encontrada."));
        } else if (request.getNombreCanchaTexto() != null && !request.getNombreCanchaTexto().isEmpty()) {
            nombreCanchaTexto = request.getNombreCanchaTexto();
        } else {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Debe especificar una cancha existente o un nombre de cancha.");
        }

        // Generar código de encuentro único
        String codigoEncuentro = generateUniqueMatchCode();

        Match match = new Match();
        match.setCodigo(codigoEncuentro);
        match.setTipo(request.getTipo());
        match.setDeporte(request.getDeporte());
        match.setEstado(MatchStatus.ABIERTO); // Por defecto
        match.setFechaProgramada(request.getFechaProgramada());
        match.setCancha(cancha);
        match.setNombreCanchaTexto(nombreCanchaTexto);
        match.setCreador(creador);
        match.setEquipoLocal(equipoLocal);
        match.setEquipoVisitante(equipoVisitante);
        match.setMaxJugadores(request.getMaxJugadores());
        match.setJugadoresActuales(1); // El creador ya cuenta como jugador

        matchRepository.save(match);

        return MatchResponse.builder()
                .id(match.getId())
                .codigo(match.getCodigo())
                .tipo(match.getTipo())
                .deporte(match.getDeporte())
                .estado(match.getEstado())
                .fechaProgramada(match.getFechaProgramada())
                .canchaId(match.getCancha() != null ? match.getCancha().getId() : null)
                .nombreCanchaTexto(match.getNombreCanchaTexto())
                .creadorId(match.getCreador().getId())
                .equipoLocalId(match.getEquipoLocal() != null ? match.getEquipoLocal().getId() : null)
                .equipoVisitanteId(match.getEquipoVisitante() != null ? match.getEquipoVisitante().getId() : null)
                .maxJugadores(match.getMaxJugadores())
                .jugadoresActuales(match.getJugadoresActuales())
                .build();
    }

    @Override
    public MatchResponse joinMatch(String codigo, Authentication authentication) {
        // Obtener el usuario autenticado
        UserDetailsImpl userDetails = (UserDetailsImpl) authentication.getPrincipal();
        User usuario = userRepository.findById(userDetails.getUser().getId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Usuario no encontrado."));

        // Buscar el encuentro por código
        Match match = matchRepository.findByCodigo(codigo)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Encuentro no encontrado."));

        // Validar estado del encuentro
        if (match.getEstado() != MatchStatus.ABIERTO) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "No puedes unirte a un encuentro que no está abierto.");
        }

        // Validar cupos
        if (match.getJugadoresActuales() >= match.getMaxJugadores()) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "El encuentro está lleno.");
        }

        // Asegurarse de que el usuario no esté ya inscrito (esto podría requerir una tabla pivote si no existe)
        // Por ahora, asumimos que no hay una tabla pivote y verificamos si el usuario es el creador
        // o si se va a implementar una tabla pivote en el futuro.
        // Si ya hay participantes en la tabla pivote, aquí se debería verificar si el usuario ya está inscrito.
        // Si el usuario es el creador, no puede unirse de nuevo
        if (match.getCreador().getId().equals(usuario.getId())) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "El creador del encuentro no puede unirse como participante adicional.");
        }

        // Actualizar el contador de jugadores actuales
        match.setJugadoresActuales(match.getJugadoresActuales() + 1);
        matchRepository.save(match);

        // Devolver la respuesta actualizada
        return MatchResponse.builder()
                .id(match.getId())
                .codigo(match.getCodigo())
                .tipo(match.getTipo())
                .deporte(match.getDeporte())
                .estado(match.getEstado())
                .fechaProgramada(match.getFechaProgramada())
                .canchaId(match.getCancha() != null ? match.getCancha().getId() : null)
                .nombreCanchaTexto(match.getNombreCanchaTexto())
                .creadorId(match.getCreador().getId())
                .equipoLocalId(match.getEquipoLocal() != null ? match.getEquipoLocal().getId() : null)
                .equipoVisitanteId(match.getEquipoVisitante() != null ? match.getEquipoVisitante().getId() : null)
                .maxJugadores(match.getMaxJugadores())
                .jugadoresActuales(match.getJugadoresActuales())
                .build();
    }

    /**
     * Genera un código alfanumérico único para un encuentro.
     * @return Código único.
     */
    private String generateUniqueMatchCode() {
        String CHARACTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
        int CODE_LENGTH = 6;
        Random random = new Random();
        String code;
        do {
            StringBuilder sb = new StringBuilder(CODE_LENGTH);
            for (int i = 0; i < CODE_LENGTH; i++) {
                sb.append(CHARACTERS.charAt(random.nextInt(CHARACTERS.length())));
            }
            code = sb.toString();
        } while (matchRepository.findByCodigo(code).isPresent()); // Verificar unicidad
        return code;
    }
}
