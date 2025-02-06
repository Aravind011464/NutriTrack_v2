import 'package:flutter/material.dart';
import 'package:nutritrack_v2/views/signup_view.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'dashboard_view.dart';

class LoginView extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFDF0DF),
      appBar: AppBar(
        title: Text("Login"),
        backgroundColor: Color.fromRGBO(247, 186, 106, 1),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              Expanded(
                flex: 4, // Spacer for top padding
                child: Center(
                  child: Text(
                    "Welcome Back!",
                    style: TextStyle(
                      fontSize: 65,
                      color: Color.fromRGBO(232,134,7,1),
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),
              ),
              Expanded(
                flex: 1, // Spacer for top padding
                child: SizedBox(),
              ),
              Expanded(
                flex: 1, // Email Input
                child: TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Expanded(
                flex: 1, // Password Input
                child: TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                flex: 1, // Login Button
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      bool success = await authViewModel.login(
                        emailController.text,
                        passwordController.text,
                      );
                      if (success) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => DashboardView()),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Login Failed")),
                        );
                      }
                    },
                    child: Text("Login"),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Expanded(
                flex: 1, // Forgot Password Button
                child: TextButton(
                  onPressed: () async {
                    if (emailController.text.isNotEmpty) {
                      bool success = await authViewModel.resetPassword(emailController.text);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(success
                              ? "Password reset link sent to your email"
                              : "Failed to send reset link"),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Enter your email first")),
                      );
                    }
                  },
                  child: Text("Forgot Password?"),
                ),
              ),
              Expanded(
                flex: 1, // Sign Up Button
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignUpView()),
                    );
                  },
                  child: Text("Don't have an account? Sign Up"),
                ),
              ),
              Expanded(
                flex: 1, // Spacer for bottom padding
                child: SizedBox(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
