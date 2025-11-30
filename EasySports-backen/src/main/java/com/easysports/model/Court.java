package com.easysports.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Entidad que representa una cancha o lugar físico donde se lleva a cabo un encuentro.
 * Mapea a la tabla "canchas".
 */
@Entity
@Table(name = "canchas")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
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
    @Column(length = 255, name = "direccion")
    private String direccion;

    /**
     * Indica si el uso de la cancha tiene un costo asociado.
     */
    @Column(name = "tiene_costo")
    private Boolean tieneCosto;

    /**
     * Tipo de superficie de la cancha (Ej: "Césped Natural", "Parquet", "Asfalto").
     */
    @Column(name = "tipo_superficie", length = 50)
    private String tipoSuperficie;
}
