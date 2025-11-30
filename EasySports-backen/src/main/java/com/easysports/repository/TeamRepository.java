package com.easysports.repository;

import com.easysports.model.Team;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

/**
 * Repositorio para la gestión de datos de la entidad Team (Equipo).
 */
@Repository
public interface TeamRepository extends JpaRepository<Team, Long> {
    // Se pueden añadir métodos personalizados si es necesario
}