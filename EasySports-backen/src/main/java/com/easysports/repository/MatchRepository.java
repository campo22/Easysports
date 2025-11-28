package com.easysports.repository;

import com.easysports.model.Match;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

/**
 * Repositorio para la gestión de datos de la entidad Match (Encuentro).
 */
@Repository
public interface MatchRepository extends JpaRepository<Match, Long> {

    /**
     * Busca un encuentro por su código único.
     * @param codigo El código del encuentro a buscar.
     * @return Un Optional que contiene el encuentro si se encuentra, o vacío si no.
     */
    Optional<Match> findByCodigo(String codigo);
}
