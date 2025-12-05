import 'package:easy_sports_app/src/models/liga.dart';
import 'package:easy_sports_app/src/models/tabla_posiciones.dart';
import 'package:easy_sports_app/src/services/liga_service.dart';
import 'package:easy_sports_app/src/theme/app_theme.dart';
import 'package:flutter/material.dart';

// --- Pantalla Principal de Ligas ---
class LigasScreen extends StatefulWidget {
  const LigasScreen({super.key});

  @override
  State<LigasScreen> createState() => _LigasScreenState();
}

class _LigasScreenState extends State<LigasScreen> {
  final LigaService _ligaService = LigaService();
  List<Liga> _ligas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLigas();
  }

  Future<void> _loadLigas() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final ligas = await _ligaService.getLigas();
      if (!mounted) return;
      setState(() => _ligas = ligas);
    } catch (e) {
      if (!mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar las ligas: $e')),
        );
      }
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Ligas Disponibles', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _loadLigas,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: _ligas.length,
                    itemBuilder: (context, index) {
                      final liga = _ligas[index];
                      return Card(
                        color: AppTheme.cardBackground,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          leading: const Icon(Icons.emoji_events, color: AppTheme.primaryColor, size: 40),
                          title: Text(liga.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Deporte: ${liga.deporte}', style: const TextStyle(color: AppTheme.secondaryText)),
                          trailing: const Icon(Icons.arrow_forward_ios, color: AppTheme.secondaryText),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TablaPosicionesScreen(liga: liga),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}

// --- Pantalla de Tabla de Posiciones ---
class TablaPosicionesScreen extends StatefulWidget {
  final Liga liga;

  const TablaPosicionesScreen({super.key, required this.liga});

  @override
  State<TablaPosicionesScreen> createState() => _TablaPosicionesScreenState();
}

class _TablaPosicionesScreenState extends State<TablaPosicionesScreen> {
  final LigaService _ligaService = LigaService();
  List<TablaPosiciones> _tablaPosiciones = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTablaPosiciones();
  }

  Future<void> _loadTablaPosiciones() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final tabla = await _ligaService.getTablaPosiciones(widget.liga.id);
      if (!mounted) return;
      setState(() => _tablaPosiciones = tabla);
    } catch (e) {
      if (!mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar la tabla: $e')),
        );
      }
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.liga.nombre),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadTablaPosiciones,
              child: ListView.builder(
                itemCount: _tablaPosiciones.length,
                itemBuilder: (context, index) {
                  final fila = _tablaPosiciones[index];
                  return Card(
                    color: AppTheme.cardBackground,
                    margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.primaryColor,
                        child: Text((index + 1).toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                      title: Text(fila.nombreEquipo, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Puntos: ${fila.puntos}', style: const TextStyle(color: AppTheme.secondaryText)),
                      trailing: Text('${fila.partidosGanados}G/${fila.partidosEmpatados}E/${fila.partidosPerdidos}P', style: const TextStyle(color: AppTheme.secondaryText, fontSize: 12)),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

// --- Pantalla de Creación de Liga ---
class CreateLigaScreen extends StatefulWidget {
  const CreateLigaScreen({super.key});

  @override
  State<CreateLigaScreen> createState() => _CreateLigaScreenState();
}

class _CreateLigaScreenState extends State<CreateLigaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  String? _selectedDeporte;
  final LigaService _ligaService = LigaService();
  bool _isLoading = false;

  Future<void> _createLiga() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await _ligaService.createLiga({
          'nombre': _nombreController.text,
          'deporte': _selectedDeporte,
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('¡Liga creada con éxito!')),
          );
          Navigator.pop(context, true); // Regresa y señaliza que se recargue la lista
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al crear la liga: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Nueva Liga'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre de la Liga'),
                validator: (v) => (v == null || v.isEmpty) ? 'Introduce un nombre' : null,
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Deporte'),
                value: _selectedDeporte,
                items: ['FUTBOL', 'BALONCESTO', 'VOLEY', 'TENIS', 'OTRO']
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedDeporte = v),
                validator: (v) => v == null ? 'Selecciona un deporte' : null,
              ),
              const SizedBox(height: 24.0),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _createLiga,
                      child: const Text('Crear Liga'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
