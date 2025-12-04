class Team {
  final int id;
  final String nombre;
  final String tipoDeporte;
  final int capitanId;
  final int partidosGanados;

  Team({
    required this.id,
    required this.nombre,
    required this.tipoDeporte,
    required this.capitanId,
    required this.partidosGanados,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'],
      nombre: json['nombre'],
      tipoDeporte: json['tipoDeporte'],
      capitanId: json['capitanId'],
      partidosGanados: json['partidosGanados'],
    );
  }
}