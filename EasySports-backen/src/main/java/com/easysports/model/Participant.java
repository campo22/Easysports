package com.easysports.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * Entidad que representa la participación de un usuario en un encuentro.
 * Es la tabla pivote para la relación muchos a muchos entre User y Match.
 * Permite registrar cuándo se unió un usuario al partido.
 */
@Entity
@Table(name = "participantes_encuentro") // Asegúrate de que coincida con el nombre en tu base de datos
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Participant {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "encuentro_id", nullable = false) // Asegúrate de que el nombre de la columna coincida
    private Match match;

    @Column(name = "joined_at", nullable = false)
    private LocalDateTime joinedAt;
}