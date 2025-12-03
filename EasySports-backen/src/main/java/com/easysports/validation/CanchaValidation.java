package com.easysports.validation;

import jakarta.validation.Constraint;
import jakarta.validation.Payload;
import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * Anotación de validación para asegurar que se especifique una cancha,
 * ya sea por su ID o por un nombre de texto.
 */
@Constraint(validatedBy = CanchaValidator.class)
@Target({ ElementType.TYPE })
@Retention(RetentionPolicy.RUNTIME)
public @interface CanchaValidation {
    String message() default "Debe especificar un ID de cancha (canchaId) o un nombre de cancha (nombreCanchaTexto).";
    Class<?>[] groups() default {};
    Class<? extends Payload>[] payload() default {};
}
