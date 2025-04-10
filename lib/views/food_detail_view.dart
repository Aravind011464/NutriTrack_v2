import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FoodDetailView extends StatelessWidget {
  final String foodName;

  FoodDetailView({required this.foodName});

  final TextEditingController servingsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Mock nutritional values (replace with real data later)
    final nutrition = {
      'Calories': '100 kcal',
      'Protein': '5 g',
      'Carbs': '20 g',
      'Fat': '2 g',
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(foodName),
        backgroundColor: Color.fromRGBO(247, 186, 106, 1),
      ),
      backgroundColor: Color.fromRGBO(250, 236, 217, 1),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...nutrition.entries.map((entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text("${entry.key}: ${entry.value}", style: TextStyle(fontSize: 16)),
            )),
            SizedBox(height: 20),
            TextField(
              controller: servingsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Enter number of servings",
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final servings = int.tryParse(servingsController.text) ?? 1;
                Navigator.pop(context, servings);
              },
              child: Text("Add Food"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(232, 134, 7, 1),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
