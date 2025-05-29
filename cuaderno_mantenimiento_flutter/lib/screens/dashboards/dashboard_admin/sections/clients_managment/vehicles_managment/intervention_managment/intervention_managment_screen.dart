import 'dart:convert';


import 'package:cuaderno_mantenimiento_flutter/infrastructure/dtos/create-intervention-dto.dart';
import 'package:cuaderno_mantenimiento_flutter/infrastructure/models/intervention.dart';
import 'package:cuaderno_mantenimiento_flutter/providers/intervention_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class InterventionManagementScreen extends StatefulWidget {
  final String carId;  // <-- Parámetro requerido

  const InterventionManagementScreen({super.key, required this.carId});

  @override
  State<InterventionManagementScreen> createState() =>
      _InterventionManagementScreenState();
}

class _InterventionManagementScreenState
    extends State<InterventionManagementScreen> {

  
  final primaryColor = const Color(0xFF904A42);
  final secondaryColor = const Color.fromARGB(255, 182, 75, 63);
  final List<String> tiposIntervencion = [
    'Revision',
    'Cambio de pieza',
    'Reparacion',
  ];

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Intervention> interventions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInterventions();
  }

  void _loadInterventions() async {
    try {
      final provider = InterventionProvider();
      final loaded = await provider.fetchInterventions(widget.carId);
      setState(() {
        interventions = loaded;
        isLoading = false;
      });
    } catch (e) {
      print('Error cargando intervenciones: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = interventions.where((interv) {
      final q = _searchQuery.toLowerCase();
      return interv.tipoIntervencion.toLowerCase().contains(q) ||
          interv.observaciones?.toLowerCase().contains(q) == true ||
          interv.fecha.toLowerCase().contains(q);
    }).toList();

   return Scaffold(
  backgroundColor: Colors.white,
  appBar: AppBar(
    backgroundColor: primaryColor,
    title: const Text(
      'Gestión de Intervenciones',
      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    ),
    centerTitle: true,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.white),
      onPressed: () => context.pop(),
    ),
  ),
 floatingActionButton: FloatingActionButton(
  backgroundColor: secondaryColor,
  onPressed: () async {
    final provider = InterventionProvider();
    final result = await provider.createIntervention(
      CreateInterventionDto(
        fecha: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        kilometraje: 0, // puedes pedirlo con un diálogo o input previo
        tipoIntervencion: 'Revision',
        observaciones: '',
        vehicle_id: widget.carId,
      ),
    );
    print('Resultado de createIntervention:');
    print(jsonEncode(result));

    if (result['success'] == true) {
      final interventionId = result['interventionId'];
      final result2 = await context.push('/intervention-details/${widget.carId}/$interventionId');

    if (result2 == true) {
      // Aquí recarga la página o actualiza el estado para reflejar la nueva intervención
      setState(() {
       _loadInterventions();
      });
    }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al crear intervención: ${result['message'] ?? 'Desconocido'}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  },
  child: const Icon(Icons.add),
),

  body: isLoading
      ? const Center(child: CircularProgressIndicator())
      : Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildSearchBar(),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final interv = filtered[index];
                    return _buildInterventionCard(interv);
                  },
                ),
              )
            ],
          ),
        ),
);

  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      onChanged: (value) => setState(() => _searchQuery = value),
      decoration: InputDecoration(
        hintText: 'Buscar por tipo, observaciones, vehículo o fecha',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.grey[100],
        border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildInterventionCard(Intervention interv) {
    Icon _getIconByTipo(String tipo) {
      switch (tipo.toLowerCase()) {
        case 'reparacion':
          return const Icon(Icons.build, color: Colors.white); // icono de reparación
        case 'cambio de pieza':
          return const Icon(Icons.settings_backup_restore, color: Colors.white); // icono cambio pieza
        case 'revision':
        default:
          return const Icon(Icons.search, color: Colors.white); // icono revisión
      }
  }

  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    color: Colors.grey[100],
    elevation: 4,
    margin: const EdgeInsets.symmetric(vertical: 8),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: secondaryColor.withOpacity(0.8),
            child: _getIconByTipo(interv.tipoIntervencion),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(interv.tipoIntervencion,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Fecha: ${interv.fecha}', style: const TextStyle(color: Colors.black54)),
                Text('Km: ${interv.kilometraje}', style: const TextStyle(color: Colors.black54)),
                if (interv.observaciones != null && interv.observaciones!.isNotEmpty)
                  Text('Obs: ${interv.observaciones}', style: const TextStyle(color: Colors.black54)),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () {
                  _showEditInterventionDialog(interv);
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  print(interv.idIntervencion);
                  _confirmDeleteIntervention(interv);
                },
              ),
            ],
          )
        ],
      ),
    ),
  );
}


  void _confirmDeleteIntervention(Intervention interv) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Intervención'),
        content: Text(
            '¿Estás seguro de que deseas eliminar la intervención del ${interv.fecha}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final provider = InterventionProvider();
                await provider.deleteIntervention(interv.idIntervencion);
                setState(() {
                  _loadInterventions();
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Intervención eliminada con éxito')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error al eliminar: $e')),
                );
              }
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showEditInterventionDialog(Intervention interv) {
    print(const JsonEncoder.withIndent('  ').convert(interv.toJson()));

    final fechaController = TextEditingController(text: interv.fecha);
    final kilometrajeController = TextEditingController(text: interv.kilometraje.toString());
    String tipoIntervencion = interv.tipoIntervencion;
    final observacionesController = TextEditingController(text: interv.observaciones ?? '');

    showDialog(
      context: context,
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        double dialogWidth = screenWidth < 600 ? double.infinity : 500;

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Editar Intervención',
              style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: dialogWidth,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Fecha con DatePicker
                  TextField(
                    controller: fechaController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Fecha (YYYY-MM-DD)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: fechaController.text.isNotEmpty
                            ? DateTime.parse(fechaController.text)
                            : DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        String formattedDate = pickedDate.toIso8601String().split('T')[0];
                        fechaController.text = formattedDate;
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildTextField('Kilometraje', kilometrajeController,
                      keyboardType: TextInputType.number),
                  const SizedBox(height: 12),
                  // Dropdown para tipo intervención
                  DropdownButtonFormField<String>(
                    value: tipoIntervencion,
                    decoration: InputDecoration(
                      labelText: 'Tipo Intervención',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Revision', child: Text('Revisión')),
                      DropdownMenuItem(value: 'Cambio de pieza', child: Text('Cambio de pieza')),
                      DropdownMenuItem(value: 'Reparacion', child: Text('Reparación')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        tipoIntervencion = value;
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildTextField('Observaciones', observacionesController, maxLines: 3),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: secondaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: () async {
                final dto = CreateInterventionDto(
                  fecha: fechaController.text,
                  kilometraje: int.tryParse(kilometrajeController.text) ?? 0,
                  tipoIntervencion: tipoIntervencion,
                  observaciones: observacionesController.text,
                  vehicle_id: widget.carId,
                );
                try {
                  final provider = InterventionProvider();
                  await provider.updateIntervention(dto, interv.idIntervencion);
                  setState(() {
                    int idx = interventions.indexWhere((i) => i.idIntervencion == interv.idIntervencion);
                    if (idx >= 0) {
                      interventions[idx] = Intervention(
                        idIntervencion: interv.idIntervencion,
                        fecha: dto.fecha,
                        kilometraje: dto.kilometraje,
                        tipoIntervencion: dto.tipoIntervencion,
                        observaciones: dto.observaciones,
                      );
                    }
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Intervención actualizada')));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error al actualizar: $e')));
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _showCreateInterventionDialog(String carId) {
  
    final kilometrajeController = TextEditingController();
    final observacionesController = TextEditingController();
    String tipoIntervencion = 'Revision'; // valor por defecto

    showDialog(
      context: context,
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        double dialogWidth = screenWidth < 600 ? double.infinity : 500;

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(
                'Nueva Intervención',
                style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
              ),
              content: SizedBox(
                width: dialogWidth,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                    
                      _buildTextField(
                        'Kilometraje',
                        kilometrajeController,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      // Dropdown para tipo intervención
                      DropdownButtonFormField<String>(
                        value: tipoIntervencion,
                        decoration: InputDecoration(
                          labelText: 'Tipo Intervención',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Revision', child: Text('Revisión')),
                          DropdownMenuItem(value: 'Cambio de pieza', child: Text('Cambio de pieza')),
                          DropdownMenuItem(value: 'Reparacion', child: Text('Reparación')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setStateDialog(() {
                              tipoIntervencion = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildTextField('Observaciones', observacionesController, maxLines: 3),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: secondaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    final dto = CreateInterventionDto(
                    fecha: DateFormat('yyyy-MM-dd').format(DateTime.now()),
                    kilometraje: int.tryParse(kilometrajeController.text) ?? 0,
                    tipoIntervencion: tipoIntervencion,
                    observaciones: observacionesController.text,
                    vehicle_id: carId,
                  );

                   

                    try {
                      final provider = InterventionProvider();
                     await provider.createIntervention(dto);
                  
                      setState(() {
                        _loadInterventions();
                      });

                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Intervención creada con éxito')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error al crear intervención: $e')),
                      );
                    }
                  },
                  child: const Text('Crear'),
                ),
              ],
            );
          },
        );
      },
    );
  }



  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType? keyboardType, int maxLines = 1}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}