package com.easysports.service.specification;

import com.easysports.enums.Deporte;
import com.easysports.enums.MatchStatus;
import com.easysports.model.Match;
import jakarta.persistence.criteria.Predicate;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * Clase de utilidad para construir dinámicamente especificaciones de JPA (Criteria API)
 * para la entidad {@link Match}. Esto permite crear consultas complejas y flexibles
 * basadas en múltiples criterios opcionales.
 */
@Component
public class MatchSpecification {

    /**
     * Crea una especificación de JPA combinando múltiples criterios de filtro para los encuentros.
     *
     * @param deporte         El deporte por el cual filtrar (opcional).
     * @param estado          El estado del encuentro por el cual filtrar (opcional).
     * @param fechaDesde      La fecha de inicio para el rango de búsqueda (opcional).
     * @param fechaHasta      La fecha de fin para el rango de búsqueda (opcional).
     * @return Una instancia de {@link Specification<Match>} que puede ser usada en un repositorio.
     */
    public Specification<Match> findByCriteria(Deporte deporte, MatchStatus estado, LocalDateTime fechaDesde, LocalDateTime fechaHasta) {
        return (root, query, criteriaBuilder) -> {
            List<Predicate> predicates = new ArrayList<>();

            if (deporte != null) {
                predicates.add(criteriaBuilder.equal(root.get("deporte"), deporte));
            }
            if (estado != null) {
                predicates.add(criteriaBuilder.equal(root.get("estado"), estado));
            }
            if (fechaDesde != null) {
                predicates.add(criteriaBuilder.greaterThanOrEqualTo(root.get("fechaProgramada"), fechaDesde));
            }
            if (fechaHasta != null) {
                predicates.add(criteriaBuilder.lessThanOrEqualTo(root.get("fechaProgramada"), fechaHasta));
            }

            // Ordena por fecha programada de forma ascendente por defecto
            query.orderBy(criteriaBuilder.asc(root.get("fechaProgramada")));

            return criteriaBuilder.and(predicates.toArray(new Predicate[0]));
        };
    }
}
