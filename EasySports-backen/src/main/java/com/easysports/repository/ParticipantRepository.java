package com.easysports.repository;

import com.easysports.model.Match;
import com.easysports.model.Participant;
import com.easysports.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

/**
 * Repositorio para la gestión de la relación Participant (Usuario - Encuentro).
 */
@Repository
public interface ParticipantRepository extends JpaRepository<Participant, Long> {

    /**
     * Verifica si un usuario ya está registrado como participante en un encuentro específico.
     *
     * @param match  El encuentro objetivo.
     * @param user   El usuario objetivo.
     * @return true si existe una relación (participación), false en caso contrario.
     */
    boolean existsByMatchAndUser(Match match, User user);

    /**
     * Busca una participación específica de un usuario en un encuentro.
     *
     * @param match  El encuentro objetivo.
     * @param user   El usuario objetivo.
     * @return Optional con la participación si existe, vacío en caso contrario.
     */
    Optional<Participant> findByMatchAndUser(Match match, User user);
}