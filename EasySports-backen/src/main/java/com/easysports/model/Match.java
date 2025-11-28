package com.easysports.model;

import com.easysports.enums.Sport;
import com.easysports.enums.MatchType;
import com.easysports.enums.MatchStatus;
import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import java.time.LocalDateTime;

/**
 * Entidad central que representa un encuentro o partido.
 * Es el corazón de la lógica de negocio de la aplicación.
 */
@Entity
@Table(name = "encuentros")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Match {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /**
     * Código único y fácil de compartir para que otros jugadores se unan.
     * Se genera automáticamente en la capa de servicio.
     */
    @Column(name = "codigo_encuentro", nullable = false, unique = true, length = 10)
    private String codigo;

    /**
     * El tipo de deporte que se jugará en este encuentro.
     */
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Sport deporte;

    /**
     * Define si el partido es una reunión casual o un reto formal entre equipos.
     */
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private MatchType tipo;

    /**
     * El estado actual del ciclo de vida del encuentro.
     */
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private MatchStatus estado;

    /**
     * Fecha y hora programadas para el inicio del encuentro.
     */
    @Column(name = "fecha_programada", nullable = false)
    private LocalDateTime fechaProgramada;

    /**
     * El usuario que creó el encuentro.
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "creador_id", nullable = false)
    private User creador;

    /**
     * El equipo local. Es nulo si el partido es de tipo CASUAL.
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "equipo_local_id")
    private Team equipoLocal;

    /**
     * El equipo visitante. Es nulo si el partido es de tipo CASUAL.
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "equipo_visitante_id")
    private Team equipoVisitante;
    
    /**
     * La cancha donde se jugará el encuentro.
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "cancha_id")
    private Court cancha;

    /**
     * Número máximo de jugadores permitidos. Crucial para partidos casuales.
     */
    @Column(name = "max_jugadores", nullable = false)
    private Integer maxJugadores;

    /**
     * Contador de los jugadores actualmente inscritos.
     */
    @Column(name = "jugadores_actuales", nullable = false)
    private Integer jugadoresActuales = 0;
}
