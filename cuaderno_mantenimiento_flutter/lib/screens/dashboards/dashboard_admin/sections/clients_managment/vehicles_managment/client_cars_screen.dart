import 'package:cuaderno_mantenimiento_flutter/infrastructure/dtos/create-vehicle-dto.dart';
import 'package:cuaderno_mantenimiento_flutter/infrastructure/models/car.dart';
import 'package:cuaderno_mantenimiento_flutter/providers/car_provider.dart';
import 'package:cuaderno_mantenimiento_flutter/providers/vehicle_provider.dart';
import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

class ClientCarsScreen extends StatefulWidget {
  final String clientId;

  const ClientCarsScreen({super.key, required this.clientId});

  @override
  State<ClientCarsScreen> createState() => _ClientCarsScreenState();
}

class _ClientCarsScreenState extends State<ClientCarsScreen> {
  final primaryColor = const Color(0xFF904A42);
  final secondaryColor = const Color(0xFFB64B3F);
  final TextEditingController _searchController = TextEditingController();

  List<Car> cars = [];
  bool isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadCars();
  }

 Future<void> _loadCars() async {
  try {
    final provider = CarProvider();
    final result = await provider.fetchCarsByClientId(widget.clientId);

    for (var car in result) {
      final brand = car.brand;
      final model = car.model;

      if (brand.isNotEmpty && model.isNotEmpty) {
        final imageUrl = await provider.fetchCarImageUrl(brand, model);
        car.imageUrl = imageUrl;
      } else {
        print('❌ No se puede obtener imagen: brand o model vacíos');
      }
    }

    setState(() {
      cars = result; // puede estar vacío, y está bien
      isLoading = false;
    });
  } catch (e) {
    print('Error al cargar coches: $e');

    if (e.toString().contains('No se encontraron coches')) {
      // Si es 404, simplemente mostramos lista vacía
      setState(() {
        cars = [];
        isLoading = false;
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
        await Future.delayed(const Duration(seconds: 2));
        if (context.mounted) context.pop();
      }
    }
  }
}




  @override
  Widget build(BuildContext context) {
    final filteredCars = cars.where((car) {
      final query = _searchQuery.toLowerCase();
      return car.plate.toLowerCase().contains(query) ||
             car.brand.toLowerCase().contains(query) ||
             car.model.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('Coches del Cliente', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: secondaryColor,
        child: const Icon(Icons.add),
        onPressed: () {
          _showCreateCarDialog();
        },
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
                            itemCount: filteredCars.length,
                            itemBuilder: (context, index) {
                              return _buildCarCard(filteredCars[index]);
                            },
                          ),
                  ),
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
        hintText: 'Buscar por matrícula, marca o modelo',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildCarCard(Car car) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            car.imageUrl ?? 'https://via.placeholder.com/100x70?text=Coche',
            width: 100,
            height: 70,
            fit: BoxFit.cover,
          ),
        ),
        title: Text('${car.brand} ${car.model}', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Matrícula: ${car.plate}'),
            Text('Año: ${car.year}'),
          ],
        ),
        trailing: Wrap(
          spacing: 8,
          children: [
            IconButton(
              icon: const Icon(Icons.image, color: Colors.teal),
              tooltip: 'Ver Imagen',
              onPressed: () {
                _showCarImageDialog(car.imageUrl);
              },
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                // Mostrar modal o navegación a editar coche
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                _confirmDeleteCar(car);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCarImageDialog(String? imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: imageUrl == null
            ? const Padding(
                padding: EdgeInsets.all(20),
                child: Text('No hay imagen disponible.'),
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(imageUrl),
              ),
      ),
    );
  }

  void _confirmDeleteCar(Car car) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar coche'),
        content: Text('¿Estás seguro de que deseas eliminar el coche ${car.plate}?'),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
            onPressed: () async {
              Navigator.pop(context);
              try {
                final provider = CarProvider();
                print('id'+car.id);
                await provider.deleteCar(car.id);
                setState(() {
                  cars.removeWhere((c) => c.id == car.id);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Coche eliminado')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error al eliminar coche: $e')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
void _showCreateCarDialog() {
  final brandController = TextEditingController();
  final modelController = TextEditingController();
  final vinController = TextEditingController(); // bastidor
  final engineTypeController = TextEditingController(); // tipo_motor
  final plateController = TextEditingController();
  final nextRevisionDateController = TextEditingController(); // fecha próxima revisión (opcional)
  final estimatedMileageController = TextEditingController(); // kilometraje estimado revisión (opcional)

  showDialog(
    context: context,
    builder: (context) {
      final screenWidth = MediaQuery.of(context).size.width;
      double dialogWidth = screenWidth < 600 ? double.infinity : 500;

      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Crear Vehículo',
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        content: ConstrainedBox(
          constraints: BoxConstraints(minWidth: dialogWidth),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(brandController, 'Marca'),
                _buildTextField(modelController, 'Modelo'),
                _buildTextField(vinController, 'Bastidor'),
                _buildTextField(engineTypeController, 'Tipo de motor'),
                _buildTextField(plateController, 'Matrícula'),
                _buildTextField(nextRevisionDateController, 'Próxima revisión (YYYY-MM-DD)', keyboardType: TextInputType.datetime),
                _buildTextField(estimatedMileageController, 'Kilometraje estimado revisión', keyboardType: TextInputType.number),
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
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            onPressed: () async {
              if (brandController.text.isEmpty ||
                  modelController.text.isEmpty ||
                  vinController.text.isEmpty ||
                  engineTypeController.text.isEmpty ||
                  plateController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Por favor, completa los campos obligatorios')),
                );
                return;
              }

              // Validar formato fecha ISO si hay fecha
              final revisionDate = nextRevisionDateController.text.trim();
              if (revisionDate.isNotEmpty) {
                try {
                  DateTime.parse(revisionDate);
                } catch (_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Formato de fecha no válido (usar YYYY-MM-DD)')),
                  );
                  return;
                }
              }

              // Parsear kilometraje si hay
              int? estimatedMileage;
              if (estimatedMileageController.text.trim().isNotEmpty) {
                estimatedMileage = int.tryParse(estimatedMileageController.text.trim());
                if (estimatedMileage == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Kilometraje estimado debe ser un número')),
                  );
                  return;
                }
              }

            final newVehicleDto = CreateVehicleDto(
              marca: brandController.text.trim(),
              modelo: modelController.text.trim(),
              bastidor: vinController.text.trim(),
              tipoMotor: engineTypeController.text.trim(),
              matricula: plateController.text.trim(),
              proximaRevisionFecha: revisionDate.isNotEmpty ? revisionDate : null,
              kilometrajeEstimadoRevision: estimatedMileage,
              clientId: widget.clientId,
            );


              Navigator.pop(context);
              await handleCreateVehicle(newVehicleDto);
            },
            child: const Text(
              'Crear',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      );
    },
  );
}

Future<void> handleCreateVehicle(CreateVehicleDto newVehicleDto) async {
  try {
    final provider = VehicleProvider(); // sin baseUrl en constructor
    final created = await provider.createVehicle(newVehicleDto);

    if (created) {
      await _loadCars(); // refresca la lista de coches
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vehículo creado con éxito')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo crear el vehículo')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al crear vehículo: $e')),
    );
  }
}

// Ejemplo básico de _buildTextField para que compile
Widget _buildTextField(TextEditingController controller, String label, {TextInputType? keyboardType}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
  );
}
}