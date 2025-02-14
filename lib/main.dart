import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:nutritrack_v2/views/homepage_view.dart';
import 'package:nutritrack_v2/views/signup_view.dart';
import 'package:nutritrack_v2/views/login_view.dart';
import 'package:nutritrack_v2/viewmodels/auth_viewmodel.dart';
import 'package:nutritrack_v2/viewmodels/user_details_viewmodel.dart';
import 'core/services/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures everything is initialized properly
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Use platform-specific Firebase configuration
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthViewModel()),
        ChangeNotifierProvider(create: (context) => UserDetailsViewModel()), // Added UserDetailsViewModel
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
