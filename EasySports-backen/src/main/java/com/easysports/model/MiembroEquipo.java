package com.easysports.model;

import com.easysports.enums.EstadoMiembro;
import com.easysports.enums.RolMiembro;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * Entidad que representa la relación entre un usuario y un equipo,
 * incluyendo el estado de la membresía (invitado, aceptado, etc.)
 * y el rol (miembro, capitán - aunque el capitán se define en la entidad Team).
 */
@Entity
@Table(name = "miembros_equipos")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MiembroEquipo {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "miembro_equipo_seq")
    @SequenceGenerator(name = "miembro_equipo_seq", sequenceName = "miembros_equipos_id_seq", allocationSize = 1)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "usuario_id", nullable = false)
    private User usuario;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "equipo_id", nullable = false)
    private Team equipo;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private EstadoMiembro estado;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private RolMiembro rol;

    @Column(name = "fecha_ingreso")
    private LocalDateTime fechaIngreso;

    @Column(name = "fecha_estado")
    private LocalDateTime fechaEstado;
}
