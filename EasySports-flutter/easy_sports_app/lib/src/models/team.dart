class Team {
  final int id;
  final String nombre;
  final String? descripcion;
  final int capitanId;
  final String? capitanNombre;
  final List<TeamMember> miembros;
  final DateTime fechaCreacion;

  Team({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.capitanId,
    this.capitanNombre,
    required this.miembros,
    required this.fechaCreacion,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
      capitanId: json['capitanId'] as int,
      capitanNombre: json['capitanNombre'] as String?,
      miembros: (json['miembros'] as List<dynamic>?)
              ?.map((m) => TeamMember.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
      fechaCreacion: DateTime.parse(json['fechaCreacion'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'capitanId': capitanId,
      'capitanNombre': capitanNombre,
      'miembros': miembros.map((m) => m.toJson()).toList(),
      'fechaCreacion': fechaCreacion.toIso8601String(),
    };
  }
}

class TeamMember {
  final int id;
  final String nombreCompleto;
  final String? email;
  final bool esCapitan;

  TeamMember({
    required this.id,
    required this.nombreCompleto,
    this.email,
    required this.esCapitan,
  });

  factory TeamMember.fromJson(Map<String, dynamic> json) {
    return TeamMember(
      id: json['id'] as int,
      nombreCompleto: json['nombreCompleto'] as String,
      email: json['email'] as String?,
      esCapitan: json['esCapitan'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombreCompleto': nombreCompleto,
      'email': email,
      'esCapitan': esCapitan,
    };
  }
}
