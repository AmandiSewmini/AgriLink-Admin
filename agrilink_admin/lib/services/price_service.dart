import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/market_price_model.dart';

class PriceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'market_prices';

  // Add or update market price
  Future<void> setMarketPrice(MarketPriceModel price) async {
    try {
      // Check if document exists to preserve createdAt
      final docRef = _firestore.collection(_collection).doc(price.cropName);
      final doc = await docRef.get();
      
      final priceMap = price.toMap();
      
      if (doc.exists) {
        // Preserve the original createdAt when updating
        final existingData = doc.data();
        if (existingData != null && existingData.containsKey('createdAt')) {
          priceMap['createdAt'] = existingData['createdAt'];
        }
      }
      
      await docRef.set(priceMap);
      print(' Market price set for ${price.cropName}');
    } catch (e) {
      print(' Error setting market price: $e');
      rethrow;
    }
  }

  // Get all market prices
  Future<List<MarketPriceModel>> getAllPrices() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      return snapshot.docs
          .map((doc) => MarketPriceModel.fromMap({...doc.data(), 'cropName': doc.id}))
          .toList();
    } catch (e) {
      print('❌ Error getting prices: $e');
      return [];
    }
  }

  // Get price for specific crop
  Future<MarketPriceModel?> getPriceForCrop(String cropName) async {
    try {
      final doc = await _firestore.collection(_collection).doc(cropName).get();
      if (doc.exists) {
        return MarketPriceModel.fromMap({...doc.data()!, 'cropName': doc.id});
      }
      return null;
    } catch (e) {
      print('❌ Error getting price for $cropName: $e');
      return null;
    }
  }

  // Stream all prices (real-time)
  Stream<List<MarketPriceModel>> streamPrices() {
    return _firestore.collection(_collection).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => MarketPriceModel.fromMap({...doc.data(), 'cropName': doc.id}))
              .toList(),
        );
  }

  // Delete market price
  Future<void> deletePrice(String cropName) async {
    try {
      await _firestore.collection(_collection).doc(cropName).delete();
      print('✅ Deleted price for $cropName');
    } catch (e) {
      print('❌ Error deleting price: $e');
      rethrow;
    }
  }

  // Update specific fields
  Future<void> updatePrice({
    required String cropName,
    double? wholesale,
    double? retail,
    String? market,
  }) async {
    try {
      final updates = <String, dynamic>{};
      
      if (wholesale != null) updates['wholesale_price'] = wholesale;
      if (retail != null) updates['retail_price'] = retail;
      if (market != null) updates['market'] = market;
      
      // Recalculate fair price if wholesale or retail changed
      if (wholesale != null || retail != null) {
        final current = await getPriceForCrop(cropName);
        if (current != null) {
          final newWholesale = wholesale ?? current.wholesalePrice;
          final newRetail = retail ?? current.retailPrice;
          updates['fair_price'] = MarketPriceModel.calculateFairPrice(newWholesale, newRetail);
        }
      }
      
      updates['updatedAt'] = DateTime.now().toIso8601String();
      
      await _firestore.collection(_collection).doc(cropName).update(updates);
      print('✅ Updated price for $cropName');
    } catch (e) {
      print('❌ Error updating price: $e');
      rethrow;
    }
  }
}
