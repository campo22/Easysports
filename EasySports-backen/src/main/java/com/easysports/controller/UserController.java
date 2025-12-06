package com.easysports.controller;

import com.easysports.dto.UserSearchDTO;
import com.easysports.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/users")
public class UserController {

    @Autowired
    private UserService userService;

    /**
     * Endpoint para buscar usuarios que pueden ser invitados a un equipo.
     * @param query El término de búsqueda (nombre o email).
     * @param equipoId El ID del equipo para excluir a sus miembros.
     * @return Una lista de usuarios que coinciden con la búsqueda.
     */
    @GetMapping("/search")
    public ResponseEntity<List<UserSearchDTO>> searchUsers(
            @RequestParam String query,
            @RequestParam Long equipoId) {
        
        List<UserSearchDTO> users = userService.searchUsers(query, equipoId);
        return ResponseEntity.ok(users);
    }
}
