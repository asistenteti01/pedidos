class Pedido {
  final String key;
  final String correl;
  final String solicitante;
  final String fecha;
  final String area;
  final String estado;

  Pedido({
    required this.key,
    required this.correl,
    required this.solicitante,
    required this.fecha,
    required this.area,
    required this.estado,
  });

  factory Pedido.fromJson(Map<String, dynamic> json) {
    return Pedido(
      key: json['k11_key'],
      correl: json['k11_correl'],
      solicitante: json['k11_solicitante'],
      fecha: json['k11_fecha'],
      area: json['k11_area'],
      estado: json['k11_estado'],
    );
  }
}
