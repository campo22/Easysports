package com.easysports.dto.match;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Min;

/**
 * DTO para la solicitud de registro de resultados de un encuentro.
 */
public class SubmitResultRequest {

    @NotNull(message = "El ID del equipo local es obligatorio")
    @Min(value = 1, message = "El ID del equipo local debe ser positivo")
    private Long equipoLocalId;

    @NotNull(message = "El ID del equipo visitante es obligatorio")
    @Min(value = 1, message = "El ID del equipo visitante debe ser positivo")
    private Long equipoVisitanteId;

    @NotNull(message = "El resultado del equipo local es obligatorio")
    @Min(value = 0, message = "El resultado debe ser cero o positivo")
    private Integer resultadoLocal;

    @NotNull(message = "El resultado del equipo visitante es obligatorio")
    @Min(value = 0, message = "El resultado debe ser cero o positivo")
    private Integer resultadoVisitante;

    // Constructores
    public SubmitResultRequest() {}

    public SubmitResultRequest(Long equipoLocalId, Long equipoVisitanteId, Integer resultadoLocal, Integer resultadoVisitante) {
        this.equipoLocalId = equipoLocalId;
        this.equipoVisitanteId = equipoVisitanteId;
        this.resultadoLocal = resultadoLocal;
        this.resultadoVisitante = resultadoVisitante;
    }

    // Getters y Setters
    public Long getEquipoLocalId() {
        return equipoLocalId;
    }

    public void setEquipoLocalId(Long equipoLocalId) {
        this.equipoLocalId = equipoLocalId;
    }

    public Long getEquipoVisitanteId() {
        return equipoVisitanteId;
    }

    public void setEquipoVisitanteId(Long equipoVisitanteId) {
        this.equipoVisitanteId = equipoVisitanteId;
    }

    public Integer getResultadoLocal() {
        return resultadoLocal;
    }

    public void setResultadoLocal(Integer resultadoLocal) {
        this.resultadoLocal = resultadoLocal;
    }

    public Integer getResultadoVisitante() {
        return resultadoVisitante;
    }

    public void setResultadoVisitante(Integer resultadoVisitante) {
        this.resultadoVisitante = resultadoVisitante;
    }
}