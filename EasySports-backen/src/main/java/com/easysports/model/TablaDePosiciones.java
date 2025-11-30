package com.easysports.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Entidad que representa la posición de un equipo en una liga.
 * Mapea a la tabla "tabla_posiciones".
 */
@Entity
@Table(name = "tabla_posiciones")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TablaDePosiciones {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "liga_id")
    private Liga liga;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "equipo_id")
    private Team equipo;

    @Column(columnDefinition = "INT DEFAULT 0")
    private Integer puntos;

    @Column(name = "pj", columnDefinition = "INT DEFAULT 0")
    private Integer partidosJugados;

    @Column(name = "pg", columnDefinition = "INT DEFAULT 0")
    private Integer partidosGanados;

    @Column(name = "pp", columnDefinition = "INT DEFAULT 0")
    private Integer partidosPerdidos;

    @Column(name = "pe", columnDefinition = "INT DEFAULT 0")
    private Integer partidosEmpatados;
}
