class MarketPriceModel {
  final String cropName;
  final double wholesalePrice;
  final double retailPrice;
  final double fairPrice;
  final String market;
  final String unit;
  final DateTime createdAt;
  final DateTime updatedAt;

  MarketPriceModel({
    required this.cropName,
    required this.wholesalePrice,
    required this.retailPrice,
    required this.fairPrice,
    required this.market,
    required this.unit,
    required this.createdAt,
    required this.updatedAt,
  });

  // Calculate fair price: (0.4 × Wholesale) + (0.6 × Retail)
  static double calculateFairPrice(double wholesale, double retail) {
    return (0.4 * wholesale) + (0.6 * retail);
  }

  // Convert to Firestore
  Map<String, dynamic> toMap() {
    return {
      'cropName': cropName,
      'wholesale_price': wholesalePrice,
      'retail_price': retailPrice,
      'fair_price': fairPrice,
      'market': market,
      'unit': unit,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create from Firestore
  factory MarketPriceModel.fromMap(Map<String, dynamic> map) {
    final now = DateTime.now();
    return MarketPriceModel(
      cropName: map['cropName'] ?? '',
      wholesalePrice: (map['wholesale_price'] ?? 0).toDouble(),
      retailPrice: (map['retail_price'] ?? 0).toDouble(),
      fairPrice: (map['fair_price'] ?? 0).toDouble(),
      market: map['market'] ?? '',
      unit: map['unit'] ?? 'kg',
      createdAt: DateTime.parse(map['createdAt'] ?? now.toIso8601String()),
      updatedAt: DateTime.parse(map['updatedAt'] ?? now.toIso8601String()),
    );
  }
}
