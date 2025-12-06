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
  final String? equipoLocalNombre;
  final int? equipoVisitanteId;
  final String? equipoVisitanteNombre;
  final int maxJugadores;
  final int jugadoresActuales;
  final int? golesLocal;
  final int? golesVisitante;
  final String? comentarios;

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
    this.equipoLocalNombre,
    this.equipoVisitanteId,
    this.equipoVisitanteNombre,
    required this.maxJugadores,
    required this.jugadoresActuales,
    this.golesLocal,
    this.golesVisitante,
    this.comentarios,
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
      equipoLocalNombre: json['equipoLocalNombre'],
      equipoVisitanteId: json['equipoVisitanteId'],
      equipoVisitanteNombre: json['equipoVisitanteNombre'],
      maxJugadores: json['maxJugadores'],
      jugadoresActuales: json['jugadoresActuales'],
      golesLocal: json['golesLocal'],
      golesVisitante: json['golesVisitante'],
      comentarios: json['comentarios'],
    );
  }
}
