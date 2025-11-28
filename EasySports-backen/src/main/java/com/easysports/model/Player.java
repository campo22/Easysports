package com.easysports.model;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import java.time.LocalDateTime;

@Entity
@Table(name = "miembros_equipos")
@IdClass(PlayerId.class)
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Player {

    @Id
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "usuario_id")
    private User usuario;

    @Id
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "equipo_id")
    private Team equipo;

    @Column(name = "posicion_preferida")
    private String posicion;

    @Column(name = "fecha_ingreso", updatable = false)
    private LocalDateTime fechaIngreso;

    @PrePersist
    protected void onCreate() {
        fechaIngreso = LocalDateTime.now();
    }
}
