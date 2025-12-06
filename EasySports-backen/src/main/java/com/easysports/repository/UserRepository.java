package com.easysports.repository;

import com.easysports.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {

    Optional<User> findByEmail(String email);

    /**
     * Busca usuarios por nombre completo o email, excluyendo al usuario actual y a los miembros de un equipo específico.
     * @param query El término de búsqueda.
     * @param equipoId El ID del equipo cuyos miembros se excluirán.
     * @param currentUserId El ID del usuario que realiza la búsqueda (para auto-exclusión).
     * @return Una lista de usuarios que coinciden con los criterios.
     */
    @Query("SELECT u FROM User u WHERE u.id <> :currentUserId AND u.id NOT IN (SELECT m.usuario.id FROM MiembroEquipo m WHERE m.equipo.id = :equipoId) AND (LOWER(u.nombreCompleto) LIKE LOWER(CONCAT('%', :query, '%')) OR LOWER(u.email) LIKE LOWER(CONCAT('%', :query, '%')))")
    List<User> searchUsers(@Param("query") String query, @Param("equipoId") Long equipoId, @Param("currentUserId") Long currentUserId);
}
