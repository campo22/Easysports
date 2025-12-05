package com.easysports.repository;

import com.easysports.model.Team;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

/**
 * Repositorio para la gestión de datos de la entidad Team (Equipo).
 */
@Repository
public interface TeamRepository extends JpaRepository<Team, Long> {
    
    Optional<Team> findByNombre(String nombre);
}