package com.easysports.model;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

/**
 * Representa una cancha o lugar físico donde se lleva a cabo un encuentro.
 */
@Entity
@Table(name = "canchas")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Court {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /**
     * Nombre descriptivo de la cancha (Ej: "Cancha Municipal N° 5").
     */
    @Column(nullable = false, length = 150)
    private String nombre;

    /**
     * Dirección o enlace a la ubicación en un mapa (Ej: Google Maps, Waze).
     */
    @Column(length = 255)
    private String ubicacion;
}
