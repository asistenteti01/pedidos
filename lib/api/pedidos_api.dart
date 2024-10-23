import 'dart:convert';
import 'package:http/http.dart' as http;
import '../modelos/pedido_modelo.dart';

class PedidosApi {
  static const String apiUrl =
      'https://gestion.grupoeilcorp.com/API/almacen/lista_pedidos.php';

  Future<List<Pedido>> fetchPedidos() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      List<dynamic> data = jsonResponse['data'];

      return data.map((pedidoJson) => Pedido.fromJson(pedidoJson)).toList();
    } else {
      throw Exception('Error al cargar los pedidos');
    }
  }
}
