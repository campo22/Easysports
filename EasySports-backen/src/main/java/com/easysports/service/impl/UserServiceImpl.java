package com.easysports.service.impl;

import com.easysports.dto.UserSearchDTO;
import com.easysports.model.User;
import com.easysports.repository.UserRepository;
import com.easysports.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class UserServiceImpl implements UserService {

    @Autowired
    private UserRepository userRepository;

    @Override
    public List<UserSearchDTO> searchUsers(String query, Long equipoId) {
        // Obtener el email del usuario autenticado
        String currentUserEmail = SecurityContextHolder.getContext().getAuthentication().getName();
        User currentUser = userRepository.findByEmail(currentUserEmail)
                .orElseThrow(() -> new RuntimeException("Usuario autenticado no encontrado"));
        Long currentUserId = currentUser.getId();

        // Realizar la búsqueda
        List<User> users = userRepository.searchUsers(query, equipoId, currentUserId);

        // Mapear a DTO
        return users.stream()
                .map(this::convertToDto)
                .collect(Collectors.toList());
    }

    private UserSearchDTO convertToDto(User user) {
        return UserSearchDTO.builder()
                .id(user.getId())
                .nombreCompleto(user.getNombreCompleto())
                .email(user.getEmail())
                .avatarUrl(user.getAvatarUrl())
                .build();
    }
}
