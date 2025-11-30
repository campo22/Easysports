package com.easysports.exception;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.server.ResponseStatusException;

import java.util.HashMap;
import java.util.Map;

/**
 * Manejador global de excepciones para la API.
 * Captura y maneja las excepciones lanzadas en los controladores,
 * devolviendo respuestas HTTP adecuadas.
 */
@RestControllerAdvice
public class GlobalExceptionHandler {

    /**
     * Maneja excepciones lanzadas por argumentos no válidos en los métodos del controlador
     * (por ejemplo, validaciones con @Valid).
     *
     * @param ex Excepción de argumento no válido.
     * @return ResponseEntity con un mapa de errores de validación y estado HTTP 400.
     */
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<Map<String, String>> handleValidationExceptions(MethodArgumentNotValidException ex) {
        Map<String, String> errors = new HashMap<>();
        ex.getBindingResult().getFieldErrors().forEach(error ->
                errors.put(error.getField(), error.getDefaultMessage())
        );
        return new ResponseEntity<>(errors, HttpStatus.BAD_REQUEST);
    }

    /**
     * Maneja excepciones generales de estado HTTP (como 400, 404, 409).
     *
     * @param ex Excepción de estado de respuesta.
     * @return ResponseEntity con el mensaje de error y el estado HTTP correspondiente.
     */
    @ExceptionHandler(ResponseStatusException.class)
    public ResponseEntity<String> handleResponseStatusException(ResponseStatusException ex) {
        // Opcional: Puedes devolver un objeto con código y mensaje para mayor estructura
        return new ResponseEntity<>(ex.getReason(), ex.getStatusCode());
    }

    /**
     * Maneja excepciones de credenciales incorrectas de Spring Security.
     *
     * @param ex Excepción de credenciales incorrectas.
     * @return ResponseEntity con un mensaje de error genérico y estado HTTP 401.
     */
    @ExceptionHandler(BadCredentialsException.class)
    public ResponseEntity<String> handleBadCredentialsException(BadCredentialsException ex) {
        return new ResponseEntity<>("Credenciales incorrectas", HttpStatus.UNAUTHORIZED);
    }

    /**
     * Maneja excepciones de usuario no encontrado de Spring Security.
     *
     * @param ex Excepción de usuario no encontrado.
     * @return ResponseEntity con un mensaje de error y estado HTTP 404.
     */
    @ExceptionHandler(UsernameNotFoundException.class)
    public ResponseEntity<String> handleUsernameNotFoundException(UsernameNotFoundException ex) {
        return new ResponseEntity<>(ex.getMessage(), HttpStatus.NOT_FOUND);
    }

    /**
     * Maneja excepciones genéricas no controladas.
     *
     * @param ex Excepción genérica.
     * @return ResponseEntity con un mensaje de error genérico y estado HTTP 500.
     */
    @ExceptionHandler(Exception.class)
    public ResponseEntity<String> handleGenericException(Exception ex) {
        // Es recomendable loggear la excepción aquí para fines de diagnóstico
        ex.printStackTrace(); // O usa un logger (e.g., SLF4J + Logback)
        return new ResponseEntity<>("Error interno del servidor", HttpStatus.INTERNAL_SERVER_ERROR);
    }
}