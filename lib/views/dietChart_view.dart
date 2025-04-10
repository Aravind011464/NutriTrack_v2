import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'recipe_view.dart';

class DietChartPage extends StatefulWidget {
  final double weight;
  final double height;
  final int age;
  final double bmr;
  final String gender;
  final double weightToLose;
  final double weeksNeeded;
  final double activityLevel;
  final double calories;

  const DietChartPage({
    Key? key,
    required this.weight,
    required this.height,
    required this.age,
    required this.bmr,
    required this.gender,
    required this.weightToLose,
    required this.weeksNeeded,
    required this.activityLevel,
    required this.calories,
  }) : super(key: key);

  @override
  _DietChartPageState createState() => _DietChartPageState();
}

class _DietChartPageState extends State<DietChartPage> {
  Map<String, dynamic>? recommendation;

  @override
  void initState() {
    super.initState();
    fetchRecommendation();
  }

  String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  Future<void> fetchRecommendation() async {
    final url = Uri.parse('http://10.0.2.2:5050/recommend');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "attributes": {
            "age": widget.age,
            "weight": widget.weight,
            "height": widget.height / 100,
            "BMI": widget.weight / ((widget.height / 100) * (widget.height / 100)),
            "BMR": widget.bmr,
            "activity_level": widget.activityLevel,
            "gender_F": widget.gender.toLowerCase() == 'female' ? 1 : 0,
            "gender_M": widget.gender.toLowerCase() == 'male' ? 1 : 0
          },
          "weight_goal_kg": widget.weightToLose,
          "weeks": widget.weeksNeeded
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          recommendation = jsonDecode(response.body);
        });
      } else {
        print('Failed to get recommendation. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching recommendation: $e');
    }
  }

  List<String> _parseList(dynamic input) {
    if (input is String) {
      input = input.replaceAll('[', '').replaceAll(']', '').replaceAll("'", '').trim();
      return input.isNotEmpty ? input.split(',').map((e) => e.trim()).toList() : [];
    } else if (input is List) {
      return List<String>.from(input);
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(250, 236, 217, 1),
      appBar: AppBar(
        title: const Text('Personalized Diet Plan'),
        backgroundColor: Color.fromRGBO(247, 186, 106, 1),
      ),
      body: recommendation == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Calories Information',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('Adjusted Calories: ${recommendation!['adjusted_calories']?.toStringAsFixed(2) ?? 'N/A'}'),
                    Text('Base Calories: ${recommendation!['base_calories']?.toStringAsFixed(2) ?? 'N/A'}'),
                  ],
                ),
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Macronutrient Targets',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ...?recommendation?['macronutrient_targets']?.entries.map((entry) {
                      return Text('${capitalize(entry.key)}: ${entry.value?.toStringAsFixed(2) ?? 'N/A'}');
                    }),
                  ],
                ),
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Recommended Foods',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ...?recommendation?['recommended_foods']?.map<Widget>((mealData) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${mealData['meal'] ?? 'Meal'}',
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          ...?mealData['foods']?.map<Widget>((food) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ERecipePage(
                                      foodName: food['name'] ?? 'Unknown',
                                      description: food['description'] ?? 'No description available',
                                      steps: _parseList(food['steps']),
                                      ingredients: _parseList(food['ingredients']),
                                    ),
                                  ),
                                );
                              },
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(food['name'] ?? 'Unknown Food',
                                          style: const TextStyle(fontWeight: FontWeight.bold)),
                                      Text('Calories: ${food['nutrition']?['calories'] ?? 'N/A'}'),
                                      Text('Protein: ${food['nutrition']?['protein'] ?? 'N/A'}g'),
                                      Text('Saturated Fat: ${food['nutrition']?['saturated_fat'] ?? 'N/A'}g'),
                                      Text('Carbs: ${food['nutrition']?['carbohydrates'] ?? 'N/A'}g'),
                                      Text('Fat: ${food['nutrition']?['total_fat'] ?? 'N/A'}g'),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}