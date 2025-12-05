class TeamMember {
  final int usuarioId;
  final String nombreCompleto;
  final String email;
  final String estado; // ej. ACEPTADO, INVITADO_PENDIENTE
  final String rol;    // ej. CAPITAN, MIEMBRO

  TeamMember({
    required this.usuarioId,
    required this.nombreCompleto,
    required this.email,
    required this.estado,
    required this.rol,
  });

  factory TeamMember.fromJson(Map<String, dynamic> json) {
    // Esta estructura depende de la respuesta real de tu API.
    // Asumo que la respuesta para un miembro incluye un objeto de usuario anidado.
    return TeamMember(
      usuarioId: json['usuario']?['id'] ?? 0,
      nombreCompleto: json['usuario']?['nombreCompleto'] ?? 'Nombre no disponible',
      email: json['usuario']?['email'] ?? 'Email no disponible',
      estado: json['estado'] ?? 'DESCONOCIDO',
      rol: json['rol'] ?? 'MIEMBRO',
    );
  }
}
