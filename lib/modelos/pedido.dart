import 'package:cloud_firestore/cloud_firestore.dart';

class Pedido {
  final String nrosolicitud;
  final DateTime fechasolicitud;

  Pedido({required this.nrosolicitud, required this.fechasolicitud});

  // Método para convertir un documento de la API en un objeto Pedido
  factory Pedido.fromFirestore(Map<String, dynamic> data) {
    return Pedido(
      nrosolicitud: data['nrosolicitud'],
      fechasolicitud: (data['fechasolicitud'] as Timestamp)
          .toDate(), // Asegúrate que la fecha esté en formato ISO 8601
    );
  }
}
