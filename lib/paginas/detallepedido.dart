import 'package:flutter/material.dart';
import 'package:flutter_application_3/modelos/pedido_modelo.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Para manejar JSON
import 'package:intl/intl.dart'; // Para formatear fechas

class OrderDetailPage extends StatefulWidget {
  final Pedido pedido; // Pedido seleccionado
  const OrderDetailPage({Key? key, required this.pedido}) : super(key: key);

  @override
  _OrderDetailPageState createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  List<dynamic> detallesPedido =
      []; // Lista para almacenar los detalles del pedido
  bool isLoading = true; // Indicador de carga
  Map<String, bool> checkboxes = {}; // Estado de cada checkbox
  bool selectAll = false; // Estado del checkbox "Seleccionar Todo"

  @override
  void initState() {
    super.initState();
    _fetchDetallesPedido(); // Llamar a la API para obtener los detalles
  }

  // Función para obtener los detalles del pedido
  Future<void> _fetchDetallesPedido() async {
    final String apiUrl =
        'https://gestion.grupoeilcorp.com/API/almacen/detalle_pedido.php?codigo=${widget.pedido.key}';
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          detallesPedido = data['data']; // Guardar los detalles en la lista
          isLoading = false; // Dejar de mostrar el indicador de carga
          // Inicializar el estado de cada checkbox como false
          checkboxes = {}; // Resetear el mapa de checkboxes
          for (var detalle in detallesPedido) {
            checkboxes[detalle['k06_descripcion']] =
                false; // Asegúrate de que cada checkbox tenga un valor inicial
          }
        });
      } else {
        throw Exception('Error al cargar los detalles');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error: $e');
    }
  }

  // Función para actualizar el estado de todos los checkboxes
  void _updateSelectAll(bool? value) {
    setState(() {
      selectAll = value ?? false; // Actualiza el estado de "Seleccionar Todo"
      checkboxes.forEach((key, _) {
        checkboxes[key] =
            selectAll; // Cambia el estado de cada checkbox individual
      });
    });
  }

  // Función para mostrar los productos seleccionados
  void _showSelectedProducts() {
    List<String> selectedProducts = checkboxes.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Productos Seleccionados'),
          content: selectedProducts.isNotEmpty
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children:
                      selectedProducts.map((product) => Text(product)).toList(),
                )
              : const Text('No se ha seleccionado ningún producto.'),
          actions: [
            TextButton(
              child: const Text('Cerrar'),
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'DETALLE DE PEDIDO',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 30, 52, 99),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Imagen de fondo, cubre toda la pantalla
          Positioned.fill(
            child: Image.network(
              'https://firebasestorage.googleapis.com/v0/b/cajaimagnes.appspot.com/o/fondoverdeazul.jpg?alt=media&token=a38923d2-556b-4f13-8611-f69506915d32',
              fit: BoxFit.cover,
            ),
          ),
          // Contenido del detalle del pedido sobre la imagen de fondo
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Imagen del artículo, cargando desde la URL
                      Container(
                        alignment: Alignment.centerLeft,
                        width: 150,
                        height: 120,
                        child: Image.network(
                          'https://firebasestorage.googleapis.com/v0/b/cajaimagnes.appspot.com/o/ecoservicios-original.png?alt=media&token=ed3ee1be-2bdf-43db-b97c-6cbbb74ec41c',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Título "Detalle Solicitud"
                      const Center(
                        child: Text(
                          'Detalle Solicitud',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Información del pedido (correl, solicitante, fecha, área)
                      Text(
                        widget.pedido.correl,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Solicitante: ${widget.pedido.solicitante}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color.fromARGB(230, 0, 0, 0),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Fecha: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(widget.pedido.fecha))}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Área: ${widget.pedido.area}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Detalles del pedido
                      isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : detallesPedido.isNotEmpty
                              ? Expanded(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: DataTable(
                                        columns: [
                                          const DataColumn(
                                            label: Text('producto'),
                                          ),
                                          const DataColumn(
                                            label: Text('Cantidad'),
                                          ),
                                          DataColumn(
                                            label: Checkbox(
                                              value: selectAll,
                                              onChanged: _updateSelectAll,
                                              activeColor: const Color.fromARGB(
                                                  255, 28, 52, 100),
                                            ),
                                          ),
                                        ],
                                        rows: detallesPedido.map((detalle) {
                                          return DataRow(
                                            cells: [
                                              DataCell(Text(
                                                  detalle['k06_descripcion'])),
                                              DataCell(Text(
                                                  detalle['k12_cantidad'])),
                                              DataCell(
                                                Checkbox(
                                                  value: checkboxes[detalle[
                                                          'k06_descripcion']] ??
                                                      false, // Usa un valor predeterminado
                                                  onChanged: (bool? value) {
                                                    setState(() {
                                                      checkboxes[detalle[
                                                              'k06_descripcion']] =
                                                          value ??
                                                              false; // Actualiza el estado
                                                      // Si se desmarca un checkbox individual, desmarcar "Seleccionar Todo"
                                                      selectAll = false;
                                                    });
                                                  },
                                                  activeColor:
                                                      const Color.fromARGB(
                                                          255, 30, 52, 99),
                                                ),
                                              ),
                                            ],
                                          );
                                        }).toList()),
                                  ),
                                )
                              : const Center(
                                  child: Text(
                                    'No hay detalles disponibles',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),

                      // Botones de acción
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context)
                                  .pop(); // Volver a la página anterior
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                  255, 28, 52, 100), // Color del botón
                            ),
                            child: const Text('Cancelar'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _showSelectedProducts(); // Mostrar productos seleccionados
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                  255, 158, 197, 58), // Color del botón
                            ),
                            child: const Text('Procesar'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
