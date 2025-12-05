import 'package:easy_sports_app/src/models/team.dart';

class Invitation {
  final int id;
  final Team team;
  final String estado; // ej. INVITADO_PENDIENTE

  Invitation({
    required this.id,
    required this.team,
    required this.estado,
  });

  factory Invitation.fromJson(Map<String, dynamic> json) {
    return Invitation(
      id: json['id'] ?? 0,
      team: Team.fromJson(json['equipo'] ?? {}),
      estado: json['estado'] ?? 'DESCONOCIDO',
    );
  }
}
