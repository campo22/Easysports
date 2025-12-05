class Team {
  final int id;
  final String nombre;
  final String deporte;
  final int capitanId;

  Team({
    required this.id,
    required this.nombre,
    required this.deporte,
    required this.capitanId,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'],
      nombre: json['nombre'],
      deporte: json['deporte'],
      capitanId: json['capitanId'],
    );
  }
}
