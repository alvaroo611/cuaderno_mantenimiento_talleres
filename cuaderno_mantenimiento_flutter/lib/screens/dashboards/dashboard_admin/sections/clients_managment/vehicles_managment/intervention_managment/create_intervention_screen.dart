import 'package:cuaderno_mantenimiento_flutter/infrastructure/dtos/create-intervention-details-dto.dart';
import 'package:cuaderno_mantenimiento_flutter/infrastructure/dtos/create-intervention-dto.dart';
import 'package:cuaderno_mantenimiento_flutter/providers/intervention_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class CreateInterventionScreen extends StatefulWidget {
  final String carId;
  final String interventionId;

  const CreateInterventionScreen({
    super.key,
    required this.carId,
    required this.interventionId,
  });

  

  @override
  State<CreateInterventionScreen> createState() => _CreateInterventionScreenState();
}

class _CreateInterventionScreenState extends State<CreateInterventionScreen> {
  final kilometrajeController = TextEditingController();
  final observacionesController = TextEditingController();
  String tipoIntervencion = 'Revision';

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

  @override
  void initState() {
    super.initState();
    for (var elemento in elementos) {
      estadoPorElemento[elemento] = "Bueno";
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

    try {
      final provider = InterventionProvider();
      await provider.updateIntervention(dto,widget.interventionId); 

      for (var entry in estadoPorElemento.entries) {
        final detail = CreateInterventionDetailDto(
          elemento: entry.key,
          estado: entry.value,
          interventionId: widget.interventionId,
        );
        await provider.createInterventionDetail(detail);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Intervención y detalles creados con éxito")),
        );
        Navigator.pop(context);
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
    // Llamas a borrar la intervención antes de salir
    await _deleteIntervention();
    // Devuelves true para permitir salir de la pantalla
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(title: const Text("Nueva Intervención")),
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
              child: const Text("Crear intervención"),
            ),
             ],
          ),
        ),
      ),
    );
  }
}
