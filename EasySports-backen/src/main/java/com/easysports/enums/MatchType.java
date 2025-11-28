package com.easysports.enums;

/**
 * Define el tipo de un encuentro.
 * Un encuentro puede ser casual (abierto a todos) or formal (un reto entre dos equipos).
 */
public enum MatchType {
    /**
     * Partido abierto donde los jugadores se pueden unir individualmente.
     */
    CASUAL,

    /**
     * Partido cerrado que representa un reto entre dos equipos establecidos.
     */
    FORMAL
}
