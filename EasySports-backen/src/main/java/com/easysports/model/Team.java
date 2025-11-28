package com.easysports.model;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Entity
@Table(name = "equipos")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Team {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String nombre;

    // TODO: Esto debería ser una entidad separada 'Sport' en el futuro, por ahora un String es aceptable para el MVP.
    @Column(nullable = false)
    private String tipoDeporte;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "capitan_id", referencedColumnName = "id")
    private User capitan;
}
