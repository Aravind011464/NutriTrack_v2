import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/user_details_viewmodel.dart';
import 'dashboard_view.dart';
import 'update_view.dart';

class UserDetailsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userDetailsViewModel = Provider.of<UserDetailsViewModel>(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF0DF),
      appBar: AppBar(
        title: const Text(
          "User Details",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color.fromRGBO(247, 186, 106, 1),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              userDetailsViewModel.saveUserDetails();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User details saved!')),
              );
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => DashboardView()),
              );
            },
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: screenHeight * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Ensure elements are spaced correctly
              children: [
                if (!keyboardVisible) ...[
                  Text(
                    "Tell Us About Yourself!",
                    style: TextStyle(
                      fontSize: screenHeight * 0.05,
                      color: Color.fromRGBO(232, 134, 7, 1),
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.start,
                  ),
                  SizedBox(height: screenHeight * 0.02),
                ],

                TextField(
                  decoration: const InputDecoration(labelText: 'Height (cm)'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => userDetailsViewModel.height = double.tryParse(value) ?? 0,
                ),
                SizedBox(height: screenHeight * 0.02),

                TextField(
                  decoration: const InputDecoration(labelText: 'Weight (kg)'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => userDetailsViewModel.weight = double.tryParse(value) ?? 0,
                ),
                SizedBox(height: screenHeight * 0.02),

                InkWell(
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: userDetailsViewModel.dateOfBirth ?? DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      userDetailsViewModel.dateOfBirth = picked;
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Date of Birth'),
                    child: Text(
                      userDetailsViewModel.dateOfBirth != null
                          ? "${userDetailsViewModel.dateOfBirth!.toLocal()}".split(' ')[0]
                          : 'Select date', // Ensures no default value is shown
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),

                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Blood Group'),
                  value: userDetailsViewModel.bloodGroup,
                  items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    userDetailsViewModel.bloodGroup = newValue;
                  },
                ),
                SizedBox(height: screenHeight * 0.02),

                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Activity Level'),
                  value: userDetailsViewModel.activityLevel,
                  items: ['Sedentary', 'Lightly Active', 'Moderately Active', 'Very Active', 'Extra Active']
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    userDetailsViewModel.activityLevel = newValue;
                  },
                ),
                SizedBox(height: screenHeight * 0.05),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Gender'),
                  value: userDetailsViewModel.gender,
                  items: ['Male', 'Female'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    userDetailsViewModel.gender = newValue;
                  },
                ),
                SizedBox(height: screenHeight * 0.02),
                Center(
                  child: SizedBox(
                    width: 150,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        userDetailsViewModel.saveUserDetails();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('User details saved!')),
                        );
                        Navigator.pushReplacementNamed(context, '/mainApp');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromRGBO(255, 209, 150, 1),
                      ),
                      child: Text(
                        "Continue",
                        style: TextStyle(
                          color: Color.fromRGBO(232, 134, 7, 1),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}