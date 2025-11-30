package com.easysports.model;

import com.easysports.enums.Deporte;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * Entidad que representa a un equipo en la base de datos.
 * Mapea a la tabla "equipos".
 */
@Entity
@Table(name = "equipos")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Team {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 100)
    private String nombre;

    @Enumerated(EnumType.STRING)
    @Column(name = "tipo_deporte", nullable = false, length = 20)
    private Deporte tipoDeporte;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "capitan_id", nullable = false)
    private User capitan;

    @Column(name = "partidos_ganados", nullable = false)
    private Integer partidosGanados = 0;

    // Relación muchos a muchos con usuarios (miembros del equipo)
    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
            name = "miembros_equipos",
            joinColumns = @JoinColumn(name = "equipo_id"),
            inverseJoinColumns = @JoinColumn(name = "usuario_id")
    )
    private List<User> miembros;
}