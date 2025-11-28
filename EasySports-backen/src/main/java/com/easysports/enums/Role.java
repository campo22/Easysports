package com.easysports.enums;

/**
 * Enum para definir los roles de usuario en el sistema.
 * Se utiliza el prefijo "ROLE_" por convención con Spring Security.
 */
public enum Role {
    ROLE_USER,      // Usuario estándar de la aplicación
    ROLE_ADMIN,     // Administrador del sistema
    ROLE_COACH      // Entrenador (rol premium)
}
