package com.easysports.repository;

import com.easysports.model.Mensaje;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * Repositorio para la entidad {@link Mensaje}.
 * Proporciona métodos CRUD y de consulta para los mensajes.
 */
@Repository
public interface MensajeRepository extends JpaRepository<Mensaje, Long> {

    /**
     * Busca todos los mensajes de un encuentro específico, ordenados por fecha de envío.
     * @param encuentroId El ID del encuentro.
     * @return Una lista de mensajes.
     */
    List<Mensaje> findByEncuentroIdOrderByFechaEnvioAsc(Long encuentroId);
}
