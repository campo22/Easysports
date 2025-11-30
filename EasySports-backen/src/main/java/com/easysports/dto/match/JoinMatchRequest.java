package com.easysports.dto.match;

import lombok.Data;

/**
 * DTO para la solicitud de unirse a un encuentro (partido).
 */
@Data
public class JoinMatchRequest {
    // Actualmente vacío, ya que la información principal (código del encuentro)
    // se pasará como parámetro en la URL del endpoint.
    // Si se necesita información adicional (como estado de participación),
    // se puede añadir aquí.
}