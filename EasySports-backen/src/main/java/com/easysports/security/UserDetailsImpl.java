package com.easysports.security;

import com.easysports.model.User;
import lombok.AllArgsConstructor;
import lombok.Getter;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

/**
 * Implementación de {@link UserDetails} de Spring Security para nuestro modelo de usuario.
 * Permite que Spring Security trabaje con nuestra entidad {@link User}.
 */
@Getter
@AllArgsConstructor
public class UserDetailsImpl implements UserDetails {

    private final User user;

    /**
     * Retorna las autoridades (roles) otorgadas al usuario.
     * @return Una colección de {@link GrantedAuthority} representando los roles del usuario.
     */
    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        List<GrantedAuthority> authorities = new ArrayList<>();
        authorities.add(new SimpleGrantedAuthority("ROLE_USER")); // Rol base para todos

        if (Boolean.TRUE.equals(user.getEsLeagueManager())) {
            authorities.add(new SimpleGrantedAuthority("ROLE_LEAGUE_MANAGER"));
        }

        return authorities;
    }

    /**
     * Retorna la contraseña utilizada para autenticar al usuario.
     * @return La contraseña del usuario.
     */
    @Override
    public String getPassword() {
        return user.getPassword();
    }

    /**
     * Retorna el nombre de usuario utilizado para autenticar al usuario.
     * En nuestro caso, el email del usuario.
     * @return El email del usuario.
     */
    @Override
    public String getUsername() {
        return user.getEmail();
    }

    /**
     * Indica si la cuenta del usuario ha expirado.
     * @return true si la cuenta es válida (no ha expirado), false si no.
     */
    @Override
    public boolean isAccountNonExpired() {
        return true;
    }

    /**
     * Indica si el usuario está bloqueado o desbloqueado.
     * @return true si el usuario no está bloqueado, false si está bloqueado.
     */
    @Override
    public boolean isAccountNonLocked() {
        return true;
    }

    /**
     * Indica si las credenciales del usuario (contraseña) han expirado.
     * @return true si las credenciales son válidas, false si han expirado.
     */
    @Override
    public boolean isCredentialsNonExpired() {
        return true;
    }

    /**
     * Indica si el usuario está habilitado o deshabilitado.
     * @return true si el usuario está habilitado, false si está deshabilitado.
     */
    @Override
    public boolean isEnabled() {
        return true;
    }
}
