import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'views/admin_login_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyDDidNk4kSRnY4imR756JdoQ0a_Fhvi34M",
      authDomain: "agrilink-d21fb.firebaseapp.com",
      projectId: "agrilink-d21fb",
      storageBucket: "agrilink-d21fb.firebasestorage.app",
      messagingSenderId: "1077829562165",
      appId: "1:1077829562165:web:94ab92fcb70e195abb267c",
    ),
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgriLink Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const AdminLoginView(),
    );
  }
}
