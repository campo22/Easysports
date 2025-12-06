package com.easysports.service;

import com.easysports.dto.UserSearchDTO;
import java.util.List;

public interface UserService {
    /**
     * Busca usuarios para invitar a un equipo.
     * @param query El término de búsqueda para nombre o email.
     * @param equipoId El ID del equipo al que se invitará.
     * @return Una lista de DTOs de usuario que coinciden con la búsqueda.
     */
    List<UserSearchDTO> searchUsers(String query, Long equipoId);
}
