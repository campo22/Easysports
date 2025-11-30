package com.easysports.model;

import com.easysports.enums.Sexo;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Entidad que representa a un usuario en la base de datos.
 * Mapea a la tabla "usuarios".
 */
@Entity
@Table(name = "usuarios")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true, length = 150)
    private String email;

    @Column(name = "password_hash", nullable = false)
    private String password;

    @Column(name = "nombre_completo", nullable = false, length = 100)
    private String nombreCompleto;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 10)
    private Sexo sexo;

    @Column(name = "edad_anios", nullable = false)
    private Integer edadAnios;

    @Column(name = "edad_meses", nullable = false)
    private Integer edadMeses;

    @Column(name = "es_league_manager", columnDefinition = "BOOLEAN DEFAULT FALSE")
    private Boolean esLeagueManager;

    @Column(name = "posicion_preferida", length = 50)
    private String posicionPreferida;

    @Column(columnDefinition = "DECIMAL(3,1) DEFAULT 5.0")
    private BigDecimal puntuacion;

    @Column(name = "avatar_url")
    private String avatarUrl;

    @CreationTimestamp
    @Column(name = "fecha_registro", updatable = false)
    private LocalDateTime fechaRegistro;
}
