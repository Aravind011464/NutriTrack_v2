import 'package:flutter/material.dart';
import 'package:nutritrack_v2/views/bmr_view.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'food_detail_view.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  int _selectedIndex = 0;

  late double caloriesConsumed = 0;
  final double calorieGoal = 2245;
  late double proteinConsumed = 0;
  final double proteinGoal = 60;
  late double carbConsumed = 0;
  final double carbGoal = 225;
  late double fatConsumed = 0;
  final double fatGoal = 77;

  List<String> breakfastItems = [];
  List<String> lunchItems = [];
  List<String> dinnerItems = [];

  static const Map<String, Map<String, double>> foodNutritionData = {
    "Apple": {"calories": 95, "protein": 0.5, "carbs": 25, "fat": 0.3},
    "Banana": {"calories": 105, "protein": 1.3, "carbs": 27, "fat": 0.3},
    "Chicken": {"calories": 165, "protein": 31, "carbs": 0, "fat": 3.6},
    "Rice": {"calories": 206, "protein": 4.3, "carbs": 45, "fat": 0.4},
    "Broccoli": {"calories": 55, "protein": 3.7, "carbs": 11.2, "fat": 0.6},
    // Add more as needed
  };


  void _showFoodSearchDialog(String mealType) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FoodSearchDialog(),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        final food = result['food'] as String;
        final servings = result['servings'] as int;
        final foodWithServings = "$food (x$servings)";

        final foodData = foodNutritionData[food];
        if (foodData != null) {
          caloriesConsumed += (foodData["calories"]! * servings);
          proteinConsumed += (foodData["protein"]! * servings);
          carbConsumed += (foodData["carbs"]! * servings);
          fatConsumed += (foodData["fat"]! * servings);
        }

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
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                  style: TextStyle(fontSize: 17),
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
      // bottomNavigationBar: BottomNavigationBar(
      //   items: const <BottomNavigationBarItem>[
      //     BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
      //     BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
      //     BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
      //   ],
      //   currentIndex: _selectedIndex,
      //   selectedItemColor: Color.fromRGBO(232, 134, 7, 1),
      //   onTap: (index) {
      //     setState(() {
      //       _selectedIndex = index;
      //     });
      //   },
      // ),
    );
  }

  Widget _buildNutrientBar(String label, double consumed, double goal, Color color) {
    return Container(
      color: Color.fromRGBO(255, 223, 179, 1),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "$label ${consumed.toInt()}g / ${goal.toInt()}g",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            LinearPercentIndicator(
              lineHeight: 16.0,
              percent: (consumed / goal).clamp(0.0, 1.0),
              backgroundColor: Colors.grey.shade300,
              progressColor: color,
              barRadius: Radius.circular(5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealSection(String mealType, List<String> items) {
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                mealType,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: Icon(Icons.add_circle, color: Colors.orange),
                onPressed: () => _showFoodSearchDialog(mealType),
              ),
            ],
          ),
          ...items.map((foodEntry) {
            final parts = foodEntry.split(' (x');
            final foodName = parts[0];
            final servings = parts.length > 1 ? parts[1].replaceAll(')', '') : '1';

            return ListTile(
              title: Text(foodEntry),
              leading: Icon(Icons.fastfood, color: Colors.orange),
              onTap: () async {
                final updatedServings = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FoodDetailView(foodName: foodName),
                  ),
                );

                if (updatedServings != null) {
                  setState(() {
                    items.remove(foodEntry); // Remove old entry
                    items.add('$foodName (x$updatedServings)'); // Add updated entry
                  });
                }
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
  List<String> foodList = [
    "Apple", "Banana", "Chicken", "Rice", "Broccoli", "Salmon", "Egg", "Milk", "Oatmeal", "Avocado"
  ];
  List<String> filteredFoods = [];

  @override
  void initState() {
    super.initState();
    filteredFoods = List.from(foodList);
  }

  void _filterFoodList(String query) {
    setState(() {
      filteredFoods = foodList
          .where((food) => food.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(247, 186, 106, 1),
        title: Text("Select Food"),
      ),
      backgroundColor: Color.fromRGBO(250, 236, 217, 1),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: "Search Food",
                labelStyle: TextStyle(color: Colors.orange),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color.fromRGBO(247, 186, 106, 1), width: 2.0),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color.fromRGBO(232, 134, 7, 1), width: 2.5),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: _filterFoodList,
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: filteredFoods.length,
                itemBuilder: (context, index) {
                  final food = filteredFoods[index];
                  return ListTile(
                    title: Text(
                      food,
                      style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromRGBO(232, 134, 7, 1)),
                    ),
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FoodDetailView(foodName: food),
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
            ),
          ],
        ),
      ),
    );
  }
}




