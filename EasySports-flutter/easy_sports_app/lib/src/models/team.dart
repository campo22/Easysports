import 'package:flutter/foundation.dart';

class Team {
  final int id;
  final String nombre;
  final String tipoDeporte;
  final int partidosGanados;
  final int partidosPerdidos;
  final int? capitanId;
  final String? rolUsuario; // 'CAPITAN' o 'MIEMBRO'
  final String? estadoMiembro; // 'INVITADO_PENDIENTE', 'ACEPTADO', 'RECHAZADO', 'EXPULSADO'
  final List<TeamMember> miembros; // Mantendremos la lista pero estará vacía por defecto si el back no la envía

  Team({
    required this.id,
    required this.nombre,
    required this.tipoDeporte,
    this.partidosGanados = 0,
    this.partidosPerdidos = 0,
    this.capitanId,
    this.rolUsuario,
    this.estadoMiembro,
    required this.miembros,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    final teamId = json['id'] as int;
    debugPrint('🔄 Parsing Team: id=$teamId, nombre=${json['nombre']}, estadoMiembro=${json['estadoMiembro']}');
    return Team(
      id: teamId,
      nombre: json['nombre'] as String,
      tipoDeporte: json['tipoDeporte'] as String? ?? 'FUTBOL',
      partidosGanados: json['partidosGanados'] as int? ?? 0,
      partidosPerdidos: json['partidosPerdidos'] as int? ?? 0,
      capitanId: json['capitanId'] as int?,
      rolUsuario: json['rolUsuario'] as String?,
      estadoMiembro: json['estadoMiembro'] as String?,
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
      'partidosPerdidos': partidosPerdidos,
      'capitanId': capitanId,
      'rolUsuario': rolUsuario,
      'estadoMiembro': estadoMiembro,
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
