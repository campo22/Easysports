class Liga {
  final int id;
  final String nombre;
  final String deporte;
  final int adminId;

  Liga({
    required this.id,
    required this.nombre,
    required this.deporte,
    required this.adminId,
  });

  factory Liga.fromJson(Map<String, dynamic> json) {
    return Liga(
      id: json['id'],
      nombre: json['nombre'],
      deporte: json['deporte'],
      adminId: json['adminId'],
    );
  }
}