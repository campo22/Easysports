package com.easysports.repository;

import com.easysports.model.Court;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

/**
 * Repositorio para la gestión de datos de la entidad Court (Cancha).
 */
@Repository
public interface CourtRepository extends JpaRepository<Court, Long> {
}
