package com.easysports.repository;

import com.easysports.model.Court;
import com.easysports.model.Match;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.Optional;

/**
 * Repositorio para la gestión de datos de la entidad Match (Encuentro).
 */
@Repository
public interface MatchRepository extends JpaRepository<Match, Long>, JpaSpecificationExecutor<Match> {

    /**
     * Busca un encuentro por su código único.
     * @param codigo El código del encuentro a buscar.
     * @return Un Optional que contiene el encuentro si se encuentra, o vacío si no.
     */
    Optional<Match> findByCodigo(String codigo);

    /**
     * Verifica si ya existe un partido en la misma cancha y a la misma fecha/hora.
     * @param cancha La cancha objetivo.
     * @param fechaProgramada La fecha y hora objetivo.
     * @return true si existe un partido en esa cancha a esa hora, false en caso contrario.
     */
    boolean existsByCanchaAndFechaProgramada(Court cancha, LocalDateTime fechaProgramada);
}
