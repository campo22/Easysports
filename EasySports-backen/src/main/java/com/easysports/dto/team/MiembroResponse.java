package com.easysports.dto.team;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MiembroResponse {
    private Long id;
    private String nombreCompleto;
    private String email;
    private boolean esCapitan;
}
