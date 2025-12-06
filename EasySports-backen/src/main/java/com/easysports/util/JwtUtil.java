package com.easysports.util;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Component;

import java.security.Key;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.function.Function;

/**
 * Clase de utilidad para la generación, validación y extracción de información de JSON Web Tokens (JWT).
 * Proporciona métodos para manejar todas las operaciones relacionadas con los JWT.
 */
@Component
public class JwtUtil {

    /**
     * Clave secreta para firmar los JWT.
     * Se inyecta desde las propiedades de la aplicación (ej. application.properties).
     */
    @Value("${jwt.secret}")
    private String SECRET_KEY;

    /**
     * Tiempo de validez del token en milisegundos (10 horas por defecto).
     */
    @Value("${jwt.expiration}")
    private long JWT_EXPIRATION; // 10 horas en milisegundos

    /**
     * Extrae el nombre de usuario del token JWT.
     *
     * @param token El token JWT del cual extraer el nombre de usuario.
     * @return El nombre de usuario (subject) contenido en el token.
     */
    public String extractUsername(String token) {
        return extractClaim(token, Claims::getSubject);
    }

    /**
     * Extrae la fecha de expiración del token JWT.
     *
     * @param token El token JWT del cual extraer la fecha de expiración.
     * @return La fecha de expiración del token.
     */
    public Date extractExpiration(String token) {
        return extractClaim(token, Claims::getExpiration);
    }

    /**
     * Extrae un 'claim' específico del token JWT utilizando una función de resolución.
     *
     * @param token           El token JWT.
     * @param claimsResolver  Función para resolver el 'claim' deseado.
     * @param <T>             El tipo del 'claim' a extraer.
     * @return El 'claim' extraído.
     */
    public <T> T extractClaim(String token, Function<Claims, T> claimsResolver) {
        final Claims claims = extractAllClaims(token);
        return claimsResolver.apply(claims);
    }

    /**
     * Extrae todos los 'claims' del token JWT.
     *
     * @param token El token JWT.
     * @return Un objeto Claims que contiene todos los 'claims' del token.
     */
    private Claims extractAllClaims(String token) {
        return Jwts
                .parserBuilder()
                .setSigningKey(getSigningKey())
                .build()
                .parseClaimsJws(token)
                .getBody();
    }

    /**
     * Verifica si el token JWT ha expirado.
     *
     * @param token El token JWT a verificar.
     * @return true si el token ha expirado, false en caso contrario.
     */
    private Boolean isTokenExpired(String token) {
        return extractExpiration(token).before(new Date());
    }

    /**
     * Valida un token JWT.
     *
     * @param token        El token JWT a validar.
     * @param userDetails  Los detalles del usuario contra los cuales validar el token.
     * @return true si el token es válido para el usuario proporcionado, false en caso contrario.
     */
    public Boolean validateToken(String token, UserDetails userDetails) {
        final String username = extractUsername(token);
        return (username.equals(userDetails.getUsername()) && !isTokenExpired(token));
    }

    /**
     * Genera un token JWT para un usuario.
     *
     * @param userDetails Los detalles del usuario para quien se generará el token.
     * @return El token JWT generado.
     */
    public String generateToken(UserDetails userDetails) {
        Map<String, Object> claims = new HashMap<>();
        // Añadir roles
        claims.put("roles", userDetails.getAuthorities().stream().map(Object::toString).toList());

        // Verificar si el userDetails es una instancia de UserDetailsImpl para obtener el ID
        if (userDetails instanceof UserDetailsImpl) {
            UserDetailsImpl userDetailsImpl = (UserDetailsImpl) userDetails;
            // Añadir ID numérico del usuario al token
            claims.put("userId", userDetailsImpl.getUser().getId());
        }

        return createToken(claims, userDetails.getUsername());
    }

    /**
     * Crea el token JWT con los 'claims' y el sujeto especificados.
     *
     * @param claims  Los 'claims' (cuerpo) del token.
     * @param subject El sujeto (generalmente el nombre de usuario) del token.
     * @return El token JWT como una cadena.
     */
    private String createToken(Map<String, Object> claims, String subject) {
        return Jwts.builder()
                .setClaims(claims)
                .setSubject(subject)
                .setIssuedAt(new Date(System.currentTimeMillis()))
                .setExpiration(new Date(System.currentTimeMillis() + JWT_EXPIRATION))
                .signWith(getSigningKey(), SignatureAlgorithm.HS256)
                .compact();
    }

    /**
     * Obtiene la clave de firma decodificada a partir de la clave secreta.
     *
     * @return La clave de firma.
     */
    private Key getSigningKey() {
        byte[] keyBytes = Decoders.BASE64.decode(SECRET_KEY);
        return Keys.hmacShaKeyFor(keyBytes);
    }
}
