class SaleItem {
  final String productId;
  final String productName;
  final String productBarcode;
  final double priceAtSale;
  final int quantity;

  SaleItem({
    required this.productId,
    required this.productName,
    required this.productBarcode,
    required this.priceAtSale,
    required this.quantity,
  });

  // Constructor fromJson
  factory SaleItem.fromJson(Map<String, dynamic> json) {
    return SaleItem(
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      productBarcode: json['productBarcode'] as String,
      priceAtSale: (json['priceAtSale'] as num).toDouble(),
      quantity: json['quantity'] as int,
    );
  }

  // Método toJson
  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'productBarcode': productBarcode,
      'priceAtSale': priceAtSale,
      'quantity': quantity,
    };
  }

  SaleItem copyWith({
    String? productId,
    String? productName,
    String? productBarcode,
    double? priceAtSale,
    int? quantity,
  }) {
    return SaleItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productBarcode: productBarcode ?? this.productBarcode,
      priceAtSale: priceAtSale ?? this.priceAtSale,
      quantity: quantity ?? this.quantity,
    );
  }
}

class Sale {
  final String id;
  final DateTime saleDate;
  final List<SaleItem> items;
  final double totalAmount;
  final double receivedAmount;
  final double changeAmount;

  Sale({
    required this.id,
    required this.saleDate,
    required this.items,
    required this.totalAmount,
    required this.receivedAmount,
    required this.changeAmount,
  });

  // Constructor fromJson
  factory Sale.fromJson(Map<String, dynamic> json) {
    return Sale(
      id: json['id'] as String,
      saleDate: DateTime.parse(json['saleDate'] as String), // Parsear String a DateTime
      items: (json['items'] as List)
          .map((itemJson) => SaleItem.fromJson(itemJson as Map<String, dynamic>))
          .toList(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      receivedAmount: (json['receivedAmount'] as num).toDouble(),
      changeAmount: (json['changeAmount'] as num).toDouble(),
    );
  }

  // Método toJson
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'saleDate': saleDate.toIso8601String(), // Convertir DateTime a String ISO 8601
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'receivedAmount': receivedAmount,
      'changeAmount': changeAmount,
    };
  }
}