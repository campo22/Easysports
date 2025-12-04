import 'package:easy_sports_app/src/models/liga.dart';
import 'package:easy_sports_app/src/models/tabla_posiciones.dart';
import 'package:easy_sports_app/src/services/liga_service.dart';
import 'package:flutter/material.dart';

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
    setState(() {
      _isLoading = true;
    });
    try {
      final ligas = await _ligaService.getLigas();
      setState(() {
        _ligas = ligas;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar las ligas: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ligas'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _ligas.length,
              itemBuilder: (context, index) {
                final liga = _ligas[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: ListTile(
                    title: Text(liga.nombre),
                    subtitle: Text('Deporte: ${liga.deporte}'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TablaPosicionesScreen(ligaId: liga.id),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateLigaScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TablaPosicionesScreen extends StatefulWidget {
  final int ligaId;

  const TablaPosicionesScreen({super.key, required this.ligaId});

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
    setState(() {
      _isLoading = true;
    });
    try {
      final tabla = await _ligaService.getTablaPosiciones(widget.ligaId);
      setState(() {
        _tablaPosiciones = tabla;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar la tabla de posiciones: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tabla de Posiciones'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _tablaPosiciones.length,
              itemBuilder: (context, index) {
                final fila = _tablaPosiciones[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: ListTile(
                    leading: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: Text(
                          (index + 1).toString(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    title: Text(fila.nombreEquipo),
                    subtitle: Text('Puntos: ${fila.puntos}'),
                    trailing: Text('${fila.partidosGanados}G - ${fila.partidosEmpatados}E - ${fila.partidosPerdidos}P'),
                  ),
                );
              },
            ),
    );
  }
}

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
      setState(() {
        _isLoading = true;
      });

      final data = {
        'nombre': _nombreController.text,
        'deporte': _selectedDeporte,
      };

      try {
        final liga = await _ligaService.createLiga(data);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Liga ${liga.nombre} creada exitosamente!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al crear la liga: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
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
                decoration: const InputDecoration(
                  labelText: 'Nombre de la Liga',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, introduce un nombre para la liga';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Deporte',
                  border: OutlineInputBorder(),
                ),
                value: _selectedDeporte,
                items: ['FUTBOL', 'BALONCESTO', 'VOLEY', 'TENIS', 'OTRO']
                    .map((deporte) => DropdownMenuItem(
                          value: deporte,
                          child: Text(deporte),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDeporte = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, selecciona un deporte';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24.0),
              _isLoading
                  ? const CircularProgressIndicator()
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