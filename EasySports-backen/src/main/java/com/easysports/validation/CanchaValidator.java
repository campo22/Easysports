package com.easysports.validation;

import com.easysports.dto.match.MatchRequest;
import jakarta.validation.ConstraintValidator;
import jakarta.validation.ConstraintValidatorContext;

/**
 * Validador para la anotación {@link CanchaValidation}.
 * Verifica que en un {@link MatchRequest} se haya proporcionado
 * un `canchaId` o un `nombreCanchaTexto`.
 */
public class CanchaValidator implements ConstraintValidator<CanchaValidation, MatchRequest> {

    @Override
    public void initialize(CanchaValidation constraintAnnotation) {
    }

    @Override
    public boolean isValid(MatchRequest request, ConstraintValidatorContext context) {
        if (request == null) {
            return true; // No validar si el objeto es nulo, otras validaciones se encargarán.
        }

        boolean hasCanchaId = request.getCanchaId() != null;
        boolean hasNombreCancha = request.getNombreCanchaTexto() != null && !request.getNombreCanchaTexto().isBlank();

        return hasCanchaId || hasNombreCancha;
    }
}
