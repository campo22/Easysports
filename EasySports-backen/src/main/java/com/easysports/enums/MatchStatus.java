package com.easysports.enums;

/**
 * Modela el ciclo de vida de un encuentro deportivo.
 */
public enum MatchStatus {
    /**
     * El encuentro ha sido creado y está aceptando jugadores.
     */
    ABIERTO,

    /**
     * El encuentro ha alcanzado su capacidad máxima de jugadores.
     */
    LLENO,

    /**
     * El encuentro está actualmente en progreso.
     */
    EN_JUEGO,

    /**
     * El encuentro ha concluido.
     */
    FINALIZADO,

    /**
     * El encuentro ha sido cancelado por su creador.
     */
    CANCELADO
}
