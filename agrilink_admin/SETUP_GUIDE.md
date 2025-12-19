# AgriLink Admin Panel - Setup Guide

## Quick Setup Steps

### Step 1: Get Firebase Web Config

1. Open Firebase Console: https://console.firebase.google.com
2. Select your AgriLink project
3. Go to Project Settings (gear icon) → General
4. Scroll to "Your apps" section
5. Click "Web" icon (</>) to add web app or select existing
6. Copy the `firebaseConfig` object

### Step 2: Update main.dart

Replace the Firebase initialization in `lib/main.dart`:

```dart
await Firebase.initializeApp(
  options: const FirebaseOptions(
    apiKey: "AIza...",              // From firebaseConfig
    authDomain: "agrilink-....firebaseapp.com",
    projectId: "agrilink-....",
    storageBucket: "agrilink-....appspot.com",
    messagingSenderId: "123456789",
    appId: "1:123456789:web:...",
  ),
);
```

### Step 3: Create Admin User

```bash
# In Firebase Console
Authentication → Users → Add User
Email: admin@agrilink.com
Password: (your secure password)
```

### Step 4: Run the App

```bash
cd agrilink_admin
flutter run -d chrome
```

### Step 5: Login & Add Prices

1. Login with admin credentials
2. Click "Add Price"
3. Enter crop details
4. Save - prices will sync to farmer app!

## Example Price Entry

- Crop: Beans
- Wholesale: 120
- Retail: 150
- Market: Dambulla
- Unit: kg
- **Fair Price (auto): 138.00**

## Next Steps for Farmer App Integration

See `FARMER_APP_INTEGRATION.md` for instructions on updating the AgriLink farmer app to use these prices.
