package com.easysports.repository;

import com.easysports.model.MiembroEquipo;
import com.easysports.enums.EstadoMiembro;
import com.easysports.model.Team;
import com.easysports.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/**
 * Repositorio para la gestión de la relación MiembroEquipo.
 */
@Repository
public interface MiembroEquipoRepository extends JpaRepository<MiembroEquipo, Long> {

    /**
     * Busca una relación MiembroEquipo específica por equipo y usuario.
     * @param equipo Equipo objetivo.
     * @param usuario Usuario objetivo.
     * @return Optional con la relación encontrada o vacío.
     */
    Optional<MiembroEquipo> findByEquipoAndUsuario(Team equipo, User usuario);

    /**
     * Busca relaciones MiembroEquipo por ID del equipo y estado.
     * @param equipoId ID del equipo.
     * @param estado Estado de los miembros a buscar.
     * @return Lista de MiembroEquipo que cumplen las condiciones.
     */
    List<MiembroEquipo> findByEquipoIdAndEstado(Long equipoId, EstadoMiembro estado);

    /**
     * Busca relaciones MiembroEquipo por ID del usuario y estado.
     * @param usuarioId ID del usuario.
     * @param estado Estado de las invitaciones/membresías a buscar.
     * @return Lista de MiembroEquipo que cumplen las condiciones.
     */
    List<MiembroEquipo> findByUsuarioIdAndEstado(Long usuarioId, EstadoMiembro estado);

    /**
     * Verifica si un usuario ya es miembro (ACEPTADO) de un equipo específico.
     * @param usuarioId ID del usuario.
     * @param equipoId ID del equipo.
     * @return Optional con la relación si existe y está ACEPTADA, vacío en caso contrario.
     */
    Optional<MiembroEquipo> findByUsuarioIdAndEquipoIdAndEstado(Long usuarioId, Long equipoId, EstadoMiembro estado);

    // Opcional: Método para buscar por equipoId y usuarioId (sin estado específico)
    Optional<MiembroEquipo> findByEquipoIdAndUsuarioId(Long equipoId, Long usuarioId);
}