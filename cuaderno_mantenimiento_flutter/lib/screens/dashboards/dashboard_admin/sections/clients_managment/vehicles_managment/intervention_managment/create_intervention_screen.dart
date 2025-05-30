import 'package:cuaderno_mantenimiento_flutter/infrastructure/dtos/create-intervention-details-dto.dart';
import 'package:cuaderno_mantenimiento_flutter/infrastructure/dtos/create-intervention-dto.dart';
import 'package:cuaderno_mantenimiento_flutter/infrastructure/models/person.dart';
import 'package:cuaderno_mantenimiento_flutter/providers/car_provider.dart';
import 'package:cuaderno_mantenimiento_flutter/providers/intervention_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';


class CreateInterventionScreen extends StatefulWidget {
  final String carId;
  final String interventionId;
  final String clientId;
  final Person person; // ✅ Añadido
  final bool isEditMode;
  


  const CreateInterventionScreen({
    super.key,
    required this.carId,
    required this.interventionId,
    required this.clientId,
    required this.person,
    this.isEditMode = false,
    
});



  

  @override
  State<CreateInterventionScreen> createState() => _CreateInterventionScreenState();
}

class _CreateInterventionScreenState extends State<CreateInterventionScreen> {
  final kilometrajeController = TextEditingController();
  final observacionesController = TextEditingController();
  String tipoIntervencion = 'Revision';
  final kilometrajeEstimadoController = TextEditingController();
  DateTime? proximaRevisionFecha;

  final List<String> elementos = [
    "Aceite motor", "Filtro aire", "Filtro aceite", "Filtro combustible", "Filtro habitáculo",
    "Aceite", "Cambio", "Diferencial", "Servo", "Líquido de frenos", "Líquido limpiaparabrisas",
    "Batería", "Neumáticos", "Amortiguadores", "Pastilla/mordaza freno", "Discos/tambores del freno",
    "Escape", "Circuito refrigeración", "Frenos delanteros", "Frenos traseros",
    "Limpieza inyectores bujías emisión de gases", "Correa distribución", "Aire acondicionado",
    "Transmisión", "Dirección", "Iluminación"
  ];

  final Map<String, String> estadoPorElemento = {};
  final List<String> estados = ["Bueno", "Regular", "Malo", "Sustituido"];
  final primaryColor = const Color(0xFF904A42);
  final secondaryColor = const Color.fromARGB(255, 182, 75, 63);

  late final String clientId; // ✅ Guardamos clientId aquí

  Map<String, String> detailIdMap = {}; // elemento => id


  @override
  void initState() {
    super.initState();
    for (var elemento in elementos) {
      estadoPorElemento[elemento] = "Bueno";
    }

    if (widget.isEditMode) {
      _loadInterventionData();
      
    }
  }
Future<void> _loadInterventionData() async {
  try {
    final provider = InterventionProvider();
    final data = await provider.fetchFullInterventionInfo(widget.interventionId);

    final vehicle = data['vehicle'];
    final intervention = data['intervention'];
    final detalles = data['detalles'];

    setState(() {
      kilometrajeController.text = intervention['kilometraje'].toString();
      observacionesController.text = intervention['observaciones'] ?? '';
      tipoIntervencion = intervention['tipoIntervencion'];

      kilometrajeEstimadoController.text =
          vehicle['kilometrajeEstimadoRevision'].toString();
      proximaRevisionFecha = DateTime.parse(vehicle['proximaRevisionFecha']);

      for (var detail in detalles) {
        final elemento = detail['elemento'];
        final estado = detail['estado'];
        final id = detail['id_intervention_details']; 

        estadoPorElemento[elemento] = estado;
        detailIdMap[elemento] = id;
      }
    });
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al cargar intervención: $e')),
    );
  }
}



  Future<void> _crearIntervencion() async {
    final dto = CreateInterventionDto(
      fecha: DateFormat('yyyy-MM-dd').format(DateTime.now()),
      kilometraje: int.tryParse(kilometrajeController.text) ?? 0,
      tipoIntervencion: tipoIntervencion,
      observaciones: observacionesController.text,
      vehicle_id: widget.carId,
    );

   if (kilometrajeEstimadoController.text.isEmpty || proximaRevisionFecha == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Debes introducir el kilometraje estimado y la fecha de próxima revisión")),
    );
    return;
  }

  final kilometrajeEstimado = int.tryParse(kilometrajeEstimadoController.text);
  if (kilometrajeEstimado == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("El kilometraje estimado debe ser un número válido")),
    );
    return;
  }

  final fechaFormateada = DateFormat('yyyy-MM-dd').format(proximaRevisionFecha!);

  try {
    final carProvider = CarProvider();
    await carProvider.updateMaintenance(
      widget.carId,
      kilometrajeEstimado: kilometrajeEstimado,
      proximaRevisionFechaYYYYMMDD: fechaFormateada,
    );

      final provider = InterventionProvider();
      await provider.updateIntervention(dto, widget.interventionId);

      for (var entry in estadoPorElemento.entries) {
        final detail = CreateInterventionDetailDto(
          elemento: entry.key,
          estado: entry.value,
          interventionId: widget.interventionId,
        );
        if (widget.isEditMode) {
          await provider.updateInterventionDetail(detail,detailIdMap[entry.key]!);
        } else {
          await provider.createInterventionDetail(detail);
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Intervención y detalles creados con éxito")),
        );
        context.pushNamed(
        'interventionScreen',
        pathParameters: {
          'carId': widget.carId,
        },
        extra: {
          'clientId': widget.clientId,
          'person': widget.person,
        },
      );

      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al crear intervención: $e")),
      );
    }
  }
 Future<void> _deleteIntervention() async {
    try {
      final provider = InterventionProvider();
      // Supongo que tienes un método deleteIntervention en tu provider que recibe la interventionId
      await provider.deleteIntervention(widget.interventionId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Intervención borrada correctamente")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al borrar intervención: $e")),
        );
      }
    }
  }

  Future<bool> _onWillPop() async {
    if (!widget.isEditMode) {
      // Solo borramos si NO estamos en modo edición
      await _deleteIntervention();
    }
    
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
       appBar: AppBar(
        backgroundColor: primaryColor,
        title:  Text(
          widget.isEditMode ? 'Editar Intervención' : 'Crear Intervención',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () async {
            final shouldPop = await _onWillPop();
            if (shouldPop && mounted) {
              context.pushNamed(
              'interventionScreen',
              pathParameters: {
                'carId': widget.carId,
              },
              extra: {
                'clientId': widget.clientId,
                'person': widget.person,
              },
            );

            }
          },
        ),
      ),

        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
            TextField(
              controller: kilometrajeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Kilometraje"),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: tipoIntervencion,
              decoration: const InputDecoration(labelText: "Tipo de intervención"),
              items: const [
                DropdownMenuItem(value: 'Revision', child: Text('Revisión')),
                DropdownMenuItem(value: 'Cambio de pieza', child: Text('Cambio de pieza')),
                DropdownMenuItem(value: 'Reparacion', child: Text('Reparación')),
              ],
              onChanged: (value) {
                if (value != null) setState(() => tipoIntervencion = value);
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: observacionesController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: "Observaciones"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: kilometrajeEstimadoController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Kilometraje estimado para próxima revisión",
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2024),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null) {
                  setState(() {
                    proximaRevisionFecha = pickedDate;
                  });
                }
              },
              child: AbsorbPointer(
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Fecha de próxima revisión',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  controller: TextEditingController(
                    text: proximaRevisionFecha != null
                        ? DateFormat('dd/MM/yyyy').format(proximaRevisionFecha!)
                        : '',
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
            const Text("Estado de los elementos", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: elementos.length,
              itemBuilder: (context, index) {
                final elemento = elementos[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(elemento, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Wrap(
                          spacing: 10,
                          children: estados.map((estado) {
                            return ChoiceChip(
                              label: Text(estado),
                              selected: estadoPorElemento[elemento] == estado,
                              onSelected: (_) {
                                setState(() {
                                  estadoPorElemento[elemento] = estado;
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _crearIntervencion,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: Theme.of(context).primaryColor,
              ),
              child: Text(widget.isEditMode ? 'Actualizar intervención' : 'Nueva intervención',style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
            ),
             ],
          ),
        ),
      ),
    );
  }
}
