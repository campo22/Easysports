import 'package:flutter/material.dart';

class UserTeamsScreen extends StatefulWidget {
  const UserTeamsScreen({super.key});

  @override
  State<UserTeamsScreen> createState() => _UserTeamsScreenState();
}

class _UserTeamsScreenState extends State<UserTeamsScreen> {
  // Aquí se podría implementar la lógica para cargar los equipos del usuario.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Equipos'),
      ),
      body: ListView.builder(
        itemCount: 5, // Placeholder for now
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ListTile(
              title: Text('Equipo ${index + 1}'),
              subtitle: const Text('Deporte: Fútbol - Capitán: Yo'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Lógica para navegar al detalle del equipo
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Lógica para navegar a la pantalla de crear equipo
        },
        child: const Icon(Icons.group_add),
      ),
    );
  }
}
