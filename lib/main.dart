import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:nutritrack_v2/views/homepage_view.dart';
import 'package:nutritrack_v2/views/signup_view.dart';
import 'package:provider/provider.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'views/login_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures everything is initialized properly
  await Firebase.initializeApp();  // Initialize Firebase
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthViewModel()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeView(),
    );
  }
}
