package com.easysports.dto.match;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class ResultRequest {

    @NotNull(message = "El marcador local es obligatorio")
    @Min(value = 0, message = "El marcador no puede ser negativo")
    private Integer golesLocal;

    @NotNull(message = "El marcador visitante es obligatorio")
    @Min(value = 0, message = "El marcador no puede ser negativo")
    private Integer golesVisitante;

    private String comentarios;
}
