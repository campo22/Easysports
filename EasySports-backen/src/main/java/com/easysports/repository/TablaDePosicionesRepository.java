package com.easysports.repository;

import com.easysports.model.Liga;
import com.easysports.model.TablaDePosiciones;
import com.easysports.model.Team;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/**
 * Repositorio para la entidad {@link TablaDePosiciones}.
 * Proporciona métodos CRUD y de consulta para las tablas de posiciones.
 */
@Repository
public interface TablaDePosicionesRepository extends JpaRepository<TablaDePosiciones, Long> {

    /**
     * Busca una entrada de {@link TablaDePosiciones} por la liga y el equipo asociados.
     *
     * @param liga La liga a la que pertenece la entrada.
     * @param equipo El equipo asociado a la entrada.
     * @return Un {@link Optional} que contiene la entrada de la tabla de posiciones si se encuentra, o vacío si no.
     */
    Optional<TablaDePosiciones> findByLigaAndEquipo(Liga liga, Team equipo);

    /**
     * Busca todas las entradas de {@link TablaDePosiciones} para una liga específica.
     *
     * @param liga La liga de la que se desean obtener las entradas de la tabla de posiciones.
     * @return Una lista de {@link TablaDePosiciones} para la liga especificada.
     */
    List<TablaDePosiciones> findByLiga(Liga liga);
}
