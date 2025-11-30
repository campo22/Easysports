package com.easysports.dto.match;

import com.easysports.enums.Deporte;
import com.easysports.enums.MatchType;
import jakarta.validation.constraints.*;
import lombok.Data;
import org.springframework.format.annotation.DateTimeFormat;

import java.time.LocalDateTime;

/**
 * DTO para la solicitud de creación de un nuevo encuentro (partido).
 */
@Data
public class MatchRequest {

    /**
     * El tipo de encuentro (CASUAL o FORMAL).
     */
    @NotNull(message = "El tipo de encuentro no puede ser nulo")
    private MatchType tipo;

    /**
     * El deporte del encuentro.
     */
    @NotNull(message = "El deporte no puede ser nulo")
    private Deporte deporte;

    /**
     * Fecha y hora programadas para el encuentro.
     * Debe ser una fecha futura y cumplir con las reglas de negocio (ej. dentro de 3 días, minutos 00, 15, 30, 45).
     */
    @NotNull(message = "La fecha programada no puede ser nula")
    @FutureOrPresent(message = "La fecha programada debe ser en el presente o futuro")
    @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME)
    private LocalDateTime fechaProgramada;

    /**
     * ID de la cancha donde se jugará el encuentro (opcional).
     * Si no se proporciona, se puede especificar un nombre de cancha de texto.
     */
    private Long canchaId;

    /**
     * Nombre de la cancha de texto si no se selecciona una cancha existente (opcional).
     * Requerido si canchaId es nulo.
     */
    @Size(max = 150, message = "El nombre de la cancha no puede exceder los 150 caracteres")
    private String nombreCanchaTexto;

    /**
     * ID del equipo local (opcional, requerido para partidos FORMALES).
     */
    private Long equipoLocalId;

    /**
     * ID del equipo visitante (opcional, requerido para partidos FORMALES).
     */
    private Long equipoVisitanteId;

    /**
     * Número máximo de jugadores permitidos para el encuentro.
     */
    @NotNull(message = "El número máximo de jugadores no puede ser nulo")
    @Min(value = 2, message = "Un encuentro debe tener al menos 2 jugadores")
    private Integer maxJugadores;
}
