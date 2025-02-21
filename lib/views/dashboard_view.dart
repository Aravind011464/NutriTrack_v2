import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'water_intake_view.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  int _selectedIndex = 0;

  final double caloriesConsumed = 1122;
  final double calorieGoal = 2245;
  final double proteinConsumed = 28;
  final double proteinGoal = 60;
  final double carbConsumed = 100;
  final double carbGoal = 225;
  final double fatConsumed = 83;
  final double fatGoal = 77;

  List<String> breakfastItems = [];
  List<String> lunchItems = [];
  List<String> dinnerItems = [];

  void _showFoodSearchDialog(String mealType) {
    showModalBottomSheet(
      backgroundColor: Color.fromRGBO(250, 236, 217, 1),
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return FoodSearchDialog(
          onFoodSelected: (food, servings) {
            setState(() {
              final foodWithServings = "$food (x$servings)";
              if (mealType == "Breakfast") {
                breakfastItems.add(foodWithServings);
              } else if (mealType == "Lunch") {
                lunchItems.add(foodWithServings);
              } else {
                dinnerItems.add(foodWithServings);
              }
            });
          },
        );
      },
    );
  }

  /*void _onTabTapped(int index) {
    if (_selectedIndex == index) return; // Prevent unnecessary navigation

    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => WaterIntakeView()),
      );
    } else if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DashboardView()),
      );
    }
  }*/

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final authViewModel = Provider.of<AuthViewModel>(context, listen: true);

    return Scaffold(
      backgroundColor: Color.fromRGBO(250, 236, 217, 1),
      appBar: AppBar(
        title: Text("Dashboard"),
        backgroundColor: Color.fromRGBO(247, 186, 106, 1),
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
          ],
        ),
      ),
      /*bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Food"),
          BottomNavigationBarItem(icon: Icon(Icons.local_drink), label: "Water"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromRGBO(232, 134, 7, 1),
        onTap: _onTabTapped,
      ),*/
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
          ...items.map((food) => ListTile(
            title: Text(food),
            leading: Icon(Icons.fastfood, color: Colors.orange),
          )),
        ],
      ),
    );
  }
}

class FoodSearchDialog extends StatefulWidget {
  final Function(String, int) onFoodSelected;

  FoodSearchDialog({required this.onFoodSelected});

  @override
  _FoodSearchDialogState createState() => _FoodSearchDialogState();
}

class _FoodSearchDialogState extends State<FoodSearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _servingsController = TextEditingController();
  List<String> foodList = [
    "Apple", "Banana", "Chicken", "Rice", "Broccoli", "Salmon", "Egg", "Milk", "Oatmeal", "Avocado"
  ];
  List<String> filteredFoods = [];
  String? _selectedFood;

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

  void _addFood() {
    final servings = int.tryParse(_servingsController.text) ?? 1; // Default to 1 if not valid
    if (_selectedFood != null) {
      widget.onFoodSelected(_selectedFood!, servings);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
          SizedBox(height: 10),
          SizedBox(
            height: screenHeight * 0.3, // Restricting to one-third of the screen height
            child: Scrollbar( // Adds a scrollbar for better UX
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: filteredFoods.length,
                itemBuilder: (context, index) {
                  final isSelected = filteredFoods[index] == _selectedFood;
                  return ListTile(
                    title: Text(
                      filteredFoods[index],
                      style: TextStyle(
                        color: isSelected ? Colors.white : Color.fromRGBO(201, 111, 0, 1),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    tileColor: isSelected ? Color.fromRGBO(232, 134, 7, 1) : Colors.white, // Change background color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    onTap: () {
                      setState(() {
                        _selectedFood = filteredFoods[index]; // Set the selected food
                      });
                    },
                  );
                },
              ),
            ),
          ),
          SizedBox(height: 10),
          TextField(
            controller: _servingsController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: "Enter Servings",
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
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: _addFood,
            child: Text(
              "Add Food",
              style: TextStyle(
                color: Color.fromRGBO(250, 236, 217, 1),
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromRGBO(232, 134, 7, 1), // Orange color
            ),
          ),
        ],
      ),
    );
  }
}