class Team {
  final int id;
  final String nombre;
  final String tipoDeporte;
  final int partidosGanados;
  final int? capitanId;
  final List<TeamMember> miembros; // Mantendremos la lista pero estará vacía por defecto si el back no la envía

  Team({
    required this.id,
    required this.nombre,
    required this.tipoDeporte,
    this.partidosGanados = 0,
    this.capitanId,
    required this.miembros,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      tipoDeporte: json['tipoDeporte'] as String? ?? 'FUTBOL',
      partidosGanados: json['partidosGanados'] as int? ?? 0,
      capitanId: json['capitanId'] as int?,
      miembros: (json['miembros'] as List<dynamic>?)
              ?.map((m) => TeamMember.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [], 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'tipoDeporte': tipoDeporte,
      'partidosGanados': partidosGanados,
      'capitanId': capitanId,
      'miembros': [],
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
