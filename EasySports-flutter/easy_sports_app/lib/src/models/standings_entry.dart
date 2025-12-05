class StandingsEntry {
  final int equipoId;
  final String nombreEquipo;
  final int puntos;
  final int partidosJugados;
  final int partidosGanados;
  final int partidosEmpatados;
  final int partidosPerdidos;

  StandingsEntry({
    required this.equipoId,
    required this.nombreEquipo,
    required this.puntos,
    required this.partidosJugados,
    required this.partidosGanados,
    required this.partidosEmpatados,
    required this.partidosPerdidos,
  });

  factory StandingsEntry.fromJson(Map<String, dynamic> json) {
    return StandingsEntry(
      equipoId: json['equipoId'] ?? 0,
      nombreEquipo: json['nombreEquipo'] ?? '',
      puntos: json['puntos'] ?? 0,
      partidosJugados: json['partidosJugados'] ?? 0,
      partidosGanados: json['partidosGanados'] ?? 0,
      partidosEmpatados: json['partidosEmpatados'] ?? 0,
      partidosPerdidos: json['partidosPerdidos'] ?? 0,
    );
  }
}