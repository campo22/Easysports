class TablaPosiciones {
  final int id;
  final int ligaId;
  final String nombreLiga;
  final String deporteLiga;
  final int equipoId;
  final String nombreEquipo;
  final int puntos;
  final int partidosJugados;
  final int partidosGanados;
  final int partidosPerdidos;
  final int partidosEmpatados;

  TablaPosiciones({
    required this.id,
    required this.ligaId,
    required this.nombreLiga,
    required this.deporteLiga,
    required this.equipoId,
    required this.nombreEquipo,
    required this.puntos,
    required this.partidosJugados,
    required this.partidosGanados,
    required this.partidosPerdidos,
    required this.partidosEmpatados,
  });

  factory TablaPosiciones.fromJson(Map<String, dynamic> json) {
    return TablaPosiciones(
      id: json['id'],
      ligaId: json['ligaId'],
      nombreLiga: json['nombreLiga'],
      deporteLiga: json['deporteLiga'],
      equipoId: json['equipoId'],
      nombreEquipo: json['nombreEquipo'],
      puntos: json['puntos'] ?? 0,
      partidosJugados: json['partidosJugados'] ?? 0,
      partidosGanados: json['partidosGanados'] ?? 0,
      partidosPerdidos: json['partidosPerdidos'] ?? 0,
      partidosEmpatados: json['partidosEmpatados'] ?? 0,
    );
  }
}