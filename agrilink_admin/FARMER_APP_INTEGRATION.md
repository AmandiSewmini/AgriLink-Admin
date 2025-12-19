# Farmer App Integration Guide

## How to integrate market prices in the AgriLink farmer app

### Step 1: Add PriceService to Farmer App

Create `lib/services/market_price_service.dart` in the main AgriLink project:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class MarketPriceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<double?> getFairPrice(String cropName) async {
    try {
      final doc = await _firestore.collection('market_prices').doc(cropName).get();
      if (doc.exists) {
        return (doc.data()?['fair_price'] as num?)?.toDouble();
      }
      return null;
    } catch (e) {
      print('Error getting fair price: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getMarketPrice(String cropName) async {
    try {
      final doc = await _firestore.collection('market_prices').doc(cropName).get();
      return doc.data();
    } catch (e) {
      print('Error getting market price: $e');
      return null;
    }
  }
}
```

### Step 2: Update Add Crop View

In `lib/views/farmer/add_crop_view.dart`:

```dart
// Add at the top
final _marketPriceService = MarketPriceService();
double? _fairPrice;

// When user selects/enters crop name:
Future<void> _loadFairPrice() async {
  final cropName = _cropNameController.text.trim();
  if (cropName.isNotEmpty) {
    final fairPrice = await _marketPriceService.getFairPrice(cropName);
    setState(() {
      _fairPrice = fairPrice;
      if (fairPrice != null) {
        _priceController.text = fairPrice.toStringAsFixed(2);
      }
    });
  }
}

// Add validation to price field:
validator: (value) {
  if (value == null || value.isEmpty) return 'Please enter price';
  final price = double.tryParse(value);
  if (price == null) return 'Invalid price';
  
  // Check against fair price
  if (_fairPrice != null && price > _fairPrice!) {
    return 'Price cannot exceed fair price Rs ${_fairPrice!.toStringAsFixed(2)}';
  }
  return null;
}

// Show fair price hint below price field:
if (_fairPrice != null)
  Text(
    'Suggested fair price: Rs ${_fairPrice!.toStringAsFixed(2)}',
    style: TextStyle(color: Colors.green, fontSize: 12),
  ),
```

### Step 3: Test Integration

1. Admin: Add price for "Beans" → Fair price Rs 138.00
2. Farmer: Add crop "Beans"
3. Price field auto-fills with Rs 138.00
4. Try entering Rs 150 → Shows validation error
5. Enter Rs 130 → Accepts (below fair price)

### Step 4: Update Firestore Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Market prices: read by all, write by admin only
    match /market_prices/{cropName} {
      allow read: if request.auth != null;
      allow write: if request.auth.token.admin == true;
    }
  }
}
```

### Step 5: Set Admin Custom Claim (Optional)

```javascript
// In Firebase Console → Cloud Functions or Admin SDK
admin.auth().setCustomUserClaims(adminUid, { admin: true });
```

## Complete Flow

1. **Admin** enters market data → Calculates fair price → Saves to Firestore
2. **Farmer** opens add crop → Selects crop → Fair price loads automatically
3. **Farmer** can set price ≤ fair price → Validation prevents overpricing
4. **Buyers** see fair prices when shopping

## Benefits

- ✅ Prevents farmers from overcharging
- ✅ Provides market reference prices
- ✅ Ensures competitive pricing
- ✅ Real-time price updates from admin
- ✅ Centralized price management
