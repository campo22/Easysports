package com.easysports.repository;

import com.easysports.model.Liga;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

/**
 * Repositorio para la entidad {@link Liga}.
 * Proporciona métodos CRUD y de consulta para las ligas.
 */
@Repository
public interface LigaRepository extends JpaRepository<Liga, Long> {
}
