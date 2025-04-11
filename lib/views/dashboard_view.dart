import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nutritrack_v2/views/bmr_view.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/user_details_viewmodel.dart';
import 'food_detail_view.dart';
import 'package:http/http.dart' as http;

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {

  int _selectedIndex = 0;

  late double caloriesConsumed = 0;
  late double calorieGoal = 2245;
  late double proteinConsumed = 0;
  final double proteinGoal = 60;
  late double carbConsumed = 0;
  final double carbGoal = 225;
  late double fatConsumed = 0;
  final double fatGoal = 77;

  List<String> breakfastItems = [];
  List<String> lunchItems = [];
  List<String> dinnerItems = [];

  void _showFoodSearchDialog(String mealType) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FoodSearchDialog(),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        final foodMap = result['food'] as Map<String, dynamic>;
        print("Food MAP : " + foodMap['Name']);
        print(foodMap['Calories']);
        final food = foodMap['Name'];
        final servings = result['servings'] as int;
        final foodWithServings = "$food (x$servings)";

        caloriesConsumed += (foodMap["Calories"] * servings);
        proteinConsumed += (foodMap["ProteinContent"] * servings);
        carbConsumed += (foodMap["CarbohydrateContent"] * servings);
        fatConsumed += (foodMap["FatContent"] * servings);

        if (mealType == "Breakfast") {
          breakfastItems.add(foodWithServings);
        } else if (mealType == "Lunch") {
          lunchItems.add(foodWithServings);
        } else {
          dinnerItems.add(foodWithServings);
        }
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final authViewModel = Provider.of<AuthViewModel>(context, listen: true);
    final userDetailsViewModel = Provider.of<UserDetailsViewModel>(context);
    final prediction = userDetailsViewModel.predictionResponse;

    calorieGoal = prediction?["adjusted_calories"];

    return Scaffold(
      backgroundColor: Color.fromRGBO(250, 236, 217, 1),
      appBar: AppBar(
        title: Text("Dashboard"),
        backgroundColor: Color.fromRGBO(247, 186, 106, 1),
        automaticallyImplyLeading: false, // This removes the back button
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: screenWidth * 0.05),
            Container(
              width: screenWidth,
              height: screenWidth * 0.15,
              alignment: Alignment.center,
              child: Text(
                "Hey ${authViewModel.user?.email ?? ''}",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color.fromRGBO(232, 134, 7, 1)),
              ),
            ),
            Container(
              width: screenWidth,
              height: screenWidth * 0.15,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Today's Intake",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                ),
              ),
            ),
            CircularPercentIndicator(
              radius: 100.0,
              lineWidth: 20.0,
              animation: true,
              percent: (caloriesConsumed / calorieGoal).clamp(0.0, 1.0),
              center: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Calories",
                    style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    caloriesConsumed.toInt().toString(),
                    style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Goal ${calorieGoal.toInt()}",
                    style: TextStyle(fontSize: 14.0, color: Colors.grey),
                  ),
                ],
              ),
              circularStrokeCap: CircularStrokeCap.round,
              progressColor: Color.fromRGBO(232, 134, 7, 1),
              backgroundColor: Colors.grey.shade300,
            ),
            SizedBox(height: screenWidth * 0.05),
            _buildNutrientBar("Protein", proteinConsumed, proteinGoal, Color.fromRGBO(232, 134, 7, 1)),
            _buildNutrientBar("Carb", carbConsumed, carbGoal, Color.fromRGBO(232, 134, 7, 1)),
            _buildNutrientBar("Fat", fatConsumed, fatGoal, Color.fromRGBO(232, 134, 7, 1)),
            SizedBox(height: screenWidth * 0.05),
            _buildMealSection("Breakfast", breakfastItems),
            _buildMealSection("Lunch", lunchItems),
            _buildMealSection("Dinner", dinnerItems),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BMRCalculator()),
                );
              },
              child: Text(
                "Get Food Recommendation",
                style: TextStyle(color: Color.fromRGBO(250, 236, 217, 1)),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(232, 134, 7, 1),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 20,)
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientBar(String label, double consumed, double goal, Color color) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 6, offset: Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ${consumed.toInt()}g / ${goal.toInt()}g",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[800]),
          ),
          SizedBox(height: 10),
          LinearPercentIndicator(
            animation: true,
            lineHeight: 14.0,
            percent: (consumed / goal).clamp(0.0, 1.0),
            backgroundColor: Colors.grey.shade300,
            progressColor: color,
            barRadius: Radius.circular(10),
          ),
        ],
      ),
    );
  }


  Widget _buildMealSection(String mealType, List<String> items) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 6, offset: Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                mealType,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange.shade800),
              ),
              IconButton(
                icon: Icon(Icons.add_circle, color: Colors.orange.shade700),
                onPressed: () => _showFoodSearchDialog(mealType),
              ),
            ],
          ),
          ...items.map((foodEntry) {
            final parts = foodEntry.split(' (x');
            final foodName = parts[0];
            final servings = parts.length > 1 ? parts[1].replaceAll(')', '') : '1';

            return ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.fastfood, color: Colors.orange),
              title: Text(foodEntry, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
              onTap: () async {
                // Existing logic...
              },
            );
          }),
        ],
      ),
    );
  }

}

class FoodSearchDialog extends StatefulWidget {
  @override
  _FoodSearchDialogState createState() => _FoodSearchDialogState();
}

class _FoodSearchDialogState extends State<FoodSearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> searchResults = [];

  void _performSearch(String query) async {
    print("Checking!");
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
      });
      return;
    }

    final response = await http.get(Uri.parse("http://10.0.2.2:5000/search?query=$query"));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> results = data["results"];

      setState(() {
        searchResults = results;
      });

    } else {
      // Handle error
      setState(() {
        searchResults = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Search Food"),
        backgroundColor: Color.fromRGBO(247, 186, 106, 1),
      ),
      backgroundColor: Color.fromRGBO(250, 236, 217, 1),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: Colors.orange),
                hintText: "Search for food...",
                hintStyle: TextStyle(color: Colors.orange.shade300),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.orange.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.orange, width: 2),
                ),
              ),
              onChanged: _performSearch,
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  final food = searchResults[index] as Map<String, dynamic>;
                  return ListTile(
                    title: Text(
                      food["Name"],
                      style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromRGBO(232, 134, 7, 1)),
                    ),
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FoodDetailView(foodName: food["Name"], foodData: food,),
                        ),
                      );

                      if (result != null && result is int) {
                        Navigator.pop(context, {
                          'food': food,
                          'servings': result,
                        });
                      }
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}





