package com.easysports.repository;

import com.easysports.model.TablaDePosiciones;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

/**
 * Repositorio para la entidad {@link TablaDePosiciones}.
 * Proporciona métodos CRUD y de consulta para las tablas de posiciones.
 */
@Repository
public interface TablaDePosicionesRepository extends JpaRepository<TablaDePosiciones, Long> {
}
