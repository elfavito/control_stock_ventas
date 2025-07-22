class Product {
  final String id;
  final String barcode;
  final String name;
  final double price;

  Product({
    required this.id,
    required this.barcode,
    required this.name,
    required this.price,
  });

  // Constructor fromJson para crear un Product desde un mapa (JSON)
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      barcode: json['barcode'] as String,
      name: json['name'] as String,
      // Asegúrate de que el precio se maneje como double
      price: (json['price'] as num).toDouble(),
    );
  }

  // Método toJson para convertir un Product a un mapa (JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'barcode': barcode,
      'name': name,
      'price': price,
    };
  }

  Product copyWith({
    String? id,
    String? barcode,
    String? name,
    double? price,
  }) {
    return Product(
      id: id ?? this.id,
      barcode: barcode ?? this.barcode,
      name: name ?? this.name,
      price: price ?? this.price,
    );
  }
}