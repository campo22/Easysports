class Match {
  final int id;
  final String codigo;
  final String tipo;
  final String deporte;
  final String estado;
  final DateTime fechaProgramada;
  final int? canchaId;
  final String? nombreCanchaTexto;
  final int creadorId;
  final int? equipoLocalId;
  final int? equipoVisitanteId;
  final int maxJugadores;
  final int jugadoresActuales;

  Match({
    required this.id,
    required this.codigo,
    required this.tipo,
    required this.deporte,
    required this.estado,
    required this.fechaProgramada,
    this.canchaId,
    this.nombreCanchaTexto,
    required this.creadorId,
    this.equipoLocalId,
    this.equipoVisitanteId,
    required this.maxJugadores,
    required this.jugadoresActuales,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      id: json['id'],
      codigo: json['codigo'],
      tipo: json['tipo'],
      deporte: json['deporte'],
      estado: json['estado'],
      fechaProgramada: DateTime.parse(json['fechaProgramada']),
      canchaId: json['canchaId'],
      nombreCanchaTexto: json['nombreCanchaTexto'],
      creadorId: json['creadorId'],
      equipoLocalId: json['equipoLocalId'],
      equipoVisitanteId: json['equipoVisitanteId'],
      maxJugadores: json['maxJugadores'],
      jugadoresActuales: json['jugadoresActuales'],
    );
  }
}
