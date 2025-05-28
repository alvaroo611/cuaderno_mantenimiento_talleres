import 'package:cuaderno_mantenimiento_flutter/infrastructure/dtos/create-client-dto.dart';
import 'package:cuaderno_mantenimiento_flutter/infrastructure/models/client.dart';
import 'package:cuaderno_mantenimiento_flutter/providers/client_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ClientManagementScreen extends StatefulWidget {
  const ClientManagementScreen({super.key});

  @override
  State<ClientManagementScreen> createState() => _ClientManagementScreenState();
}

class _ClientManagementScreenState extends State<ClientManagementScreen> {
  final primaryColor = const Color(0xFF904A42);
  final secondaryColor = const Color.fromARGB(255, 182, 75, 63);

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Client> clients = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  void _loadClients() async {
    try {
      final provider = ClientProvider();
      final loadedClients = await provider.fetchClients();
      setState(() {
        clients = loadedClients;
        isLoading = false;
      });
    } catch (e) {
      print('Error cargando clientes: $e');
    }
  }

  @override
Widget build(BuildContext context) {
  final filteredClients = clients.where((client) {
    final query = _searchQuery.toLowerCase();
    return client.name.toLowerCase().contains(query) ||
           client.email.toLowerCase().contains(query) ||
           client.province.toLowerCase().contains(query) ||
           client.city.toLowerCase().contains(query);
  }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('Gestión de Usuarios', style: TextStyle(color: Colors.white,fontWeight:FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            context.pop();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: secondaryColor,
        onPressed: () {
          _showCreateClientDialog(); // Navegar a pantalla de creación de cliente
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
                      itemCount: filteredClients.length,
                      itemBuilder: (context, index) {
                        final client = filteredClients[index];
                        return _buildClientCard(client);
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
        hintText: 'Buscar por nombre, correo, provincia o localidad',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

 Widget _buildClientCard(Client client) {
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
            child: Text(client.name[0], style: const TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(client.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(client.email, style: const TextStyle(color: Colors.black54)),
                Text('${client.city}, ${client.province}', style: const TextStyle(color: Colors.black54)),
                Text(client.phone, style: const TextStyle(color: Colors.black54)),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
             IconButton(
              icon: const Icon(Icons.directions_car, color: Colors.teal),
              tooltip: 'Ver coches',
              onPressed: () {
                context.push('/admin/clients/${client.id}/cars');
              },
            ),

              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () {
                  _showEditClientDialog(client);
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  _confirmDeleteClient(client);
                },
              ),
            ],
          )
        ],
      ),
    ),
  );
}

void _confirmDeleteClient(Client client) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Eliminar Cliente'),
      content: Text('¿Estás seguro de que deseas eliminar a ${client.name}?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(context);
            try {
              final provider = ClientProvider();
              await provider.deleteClient(client.id);
              setState(() {
                clients.removeWhere((c) => c.id == client.id);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cliente eliminado con éxito')),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error al eliminar cliente: $e')),
              );
            }
          },
          child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}
void _showEditClientDialog(Client client) {
  final nameController = TextEditingController(text: client.name);
  final mailController = TextEditingController(text: client.email);
  final passwordController = TextEditingController(text: client.password);
  final addressController = TextEditingController(text: client.address);
  final cityController = TextEditingController(text: client.city);
  final provinceController = TextEditingController(text: client.province);
  final postalCodeController = TextEditingController(text: client.postalCode);
  final phoneController = TextEditingController(text: client.phone);

  showDialog(
    context: context,
    builder: (context) {
      final screenWidth = MediaQuery.of(context).size.width;
      double dialogWidth = screenWidth < 600 ? double.infinity : 500;

      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Editar Cliente', style: TextStyle(color: primaryColor ,fontWeight: FontWeight.bold)),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: dialogWidth,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(nameController, 'Nombre'),
                _buildTextField(mailController, 'Correo'),
                _buildTextField(passwordController, 'Password'),
                _buildTextField(addressController, 'Dirección'),
                _buildTextField(cityController, 'Localidad'),
                _buildTextField(provinceController, 'Provincia'),
                _buildTextField(postalCodeController, 'Código Postal'),
                _buildTextField(phoneController, 'Teléfono'),
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
              final updatedClient = CreateClientDto(
                nombre: nameController.text,
                correo: mailController.text,
                password: passwordController.text,
                domicilio: addressController.text,
                localidad: cityController.text,
                provincia: provinceController.text,
                codigoPostal: postalCodeController.text,
                telefono: phoneController.text,
              );
              Navigator.pop(context);
              await handleUpdateClient(updatedClient, client.id);
            },
            child: const Text(
              'Guardar',
              style: TextStyle(
                color: Color.fromARGB(255, 255, 255, 255),
                fontWeight: FontWeight.bold
              ),
            ),

          ),
        ],
      );
    },
  );
}

Future<void> handleUpdateClient(CreateClientDto updatedClient, String clientId) async {
  try {
    final provider = ClientProvider();
    await provider.updateClient(updatedClient, clientId);

    setState(() {
      final index = clients.indexWhere((c) => c.id == clientId);
      if (index != -1) {
        clients[index] = Client(
          id: clientId,
          name: updatedClient.nombre,
          email: updatedClient.correo,
          password: updatedClient.password,
          address: updatedClient.domicilio,
          city: updatedClient.localidad,
          province: updatedClient.provincia,
          postalCode: updatedClient.codigoPostal,
          phone: updatedClient.telefono,
        );
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cliente actualizado')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al actualizar: $e')),
    );
  }
}


Widget _buildTextField(TextEditingController controller, String label) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6.0),
    child: TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}

void _showCreateClientDialog() {
  final nameController = TextEditingController();
  final mailController = TextEditingController();
  final passwordController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final provinceController = TextEditingController();
  final postalCodeController = TextEditingController();
  final phoneController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      final screenWidth = MediaQuery.of(context).size.width;
      double dialogWidth = screenWidth < 600 ? double.infinity : 500;

      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Crear Cliente', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
        content: ConstrainedBox(
          constraints: BoxConstraints(minWidth: dialogWidth),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(nameController, 'Nombre'),
                _buildTextField(mailController, 'Correo'),
                _buildTextField(passwordController, 'Password'),
                _buildTextField(addressController, 'Dirección'),
                _buildTextField(cityController, 'Localidad'),
                _buildTextField(provinceController, 'Provincia'),
                _buildTextField(postalCodeController, 'Código Postal'),
                _buildTextField(phoneController, 'Teléfono'),
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
              final newClient = CreateClientDto(
                nombre: nameController.text,
                correo: mailController.text,
                password: passwordController.text,
                domicilio: addressController.text,
                localidad: cityController.text,
                provincia: provinceController.text,
                codigoPostal: postalCodeController.text,
                telefono: phoneController.text,
              );
              Navigator.pop(context);
              await handleCreateClient(newClient);
            },
            child: const Text(
              'Crear',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    },
  );
}

Future<void> handleCreateClient(CreateClientDto newClient) async {
  try {
    final provider = ClientProvider();
    final created = await provider.createClient(newClient);

    if (created) {
      // Refrescar la lista de clientes
      final updatedClients = await provider.fetchClients();

      setState(() {
        clients = updatedClients;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cliente creado con éxito')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo crear el cliente')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al crear cliente: $e')),
    );
  }
}



}