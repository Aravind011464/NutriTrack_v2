import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class WaterIntakeView extends StatefulWidget {
  const WaterIntakeView({super.key});

  @override
  State<WaterIntakeView> createState() => _WaterIntakeViewState();
}

class _WaterIntakeViewState extends State<WaterIntakeView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 1;
  double waterConsumed = 1200; // ml
  double waterGoal = 3000; // ml
  double bottleCapacity = 1000; // ml, updated bottle capacity
  double _tempWaterConsumed = 0; // Temporary water consumed since last refill
  List<Map<String, dynamic>> waterRecords = [];
  Timer? _timer;
  double _data = 0.0; // Current distance data
  double _previousDistance = 0.0; // Previous distance data

  // Bottle dimensions
  final double bottleRadius = 3.258; // cm
  final double bottleHeight = 30.0; // cm

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchData();
    _timer = Timer.periodic(Duration(seconds: 5), (Timer t) => _fetchData());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    final url = "https://nutritrack-af35a-default-rtdb.asia-southeast1.firebasedatabase.app/sensor/distance.json";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final newData = jsonDecode(response.body);
      if (newData is num) {
        setState(() {
          _data = 30 - newData.toDouble(); // Ensure it's a double
          _updateWaterIntake();
        });
        print("Data has changed: $_data");
      } else {
        print("Unexpected data format");
      }
    } else {
      print("Failed to fetch data");
    }
  }

  void _updateWaterIntake() {
    double currentWaterHeight = bottleHeight - _data; // Height of water column
    double currentVolume = pi * bottleRadius * bottleRadius * currentWaterHeight; // Volume in cm³
    double currentVolumeML = currentVolume; // 1 cm³ = 1 ml

    if (currentVolumeML > _tempWaterConsumed) {
      // Water level decreased, calculate water consumed
      int consumedAmount = (currentVolumeML - _tempWaterConsumed).floor();
      setState(() {
        waterConsumed += consumedAmount;
        _tempWaterConsumed = currentVolumeML;
        waterRecords.add({
          'time': DateTime.now(),
          'amount': consumedAmount,
        });
      });
    } else if (currentVolumeML < _tempWaterConsumed) {
      // Water level increased, reset temporary water consumed
      setState(() {
        _tempWaterConsumed = currentVolumeML;
      });
    }
    _previousDistance = _data; // Update previous distance
  }

  void _showRefillAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.local_drink, size: 60, color: Color.fromRGBO(7, 134, 232, 1)),
                const SizedBox(height: 10),
                const Text(
                  "Refill Needed",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                const SizedBox(height: 10),
                const Text(
                  "You do not have sufficient water. Please refill to continue tracking water intake.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _tempWaterConsumed = 0; // Reset temporary water consumed
                    });
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(7, 134, 232, 1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  ),
                  child: const Text("Refill", style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB3E5FC),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(7, 134, 232, 1),
        title: const Text("Water Intake"),
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: "Today"),
              Tab(text: "History"),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                SingleChildScrollView(
                  child: WaterIntakeContent(
                    waterConsumed: waterConsumed,
                    waterGoal: waterGoal,
                    bottleCapacity: bottleCapacity,
                    tempWaterConsumed: _tempWaterConsumed,
                    waterRecords: waterRecords,
                    data: _data, // Pass the data to the content widget
                  ),
                ),
                //const WaterHistoryView(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WaterIntakeContent extends StatelessWidget {
  final double waterConsumed;
  final double waterGoal;
  final double bottleCapacity;
  final double tempWaterConsumed;
  final List<Map<String, dynamic>> waterRecords;
  final double data;

  const WaterIntakeContent({
    super.key,
    required this.waterConsumed,
    required this.waterGoal,
    required this.bottleCapacity,
    required this.tempWaterConsumed,
    required this.waterRecords,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        SizedBox(height: screenWidth * 0.05),
        Stack(
          alignment: Alignment.center,
          children: [
            // Outer Circular Indicator (Bottle Remaining)
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: CircularPercentIndicator(
                radius: 140.0,
                lineWidth: 10.0,
                animation: true,
                percent: ((bottleCapacity - tempWaterConsumed) / bottleCapacity).clamp(0.0, 1.0),
                circularStrokeCap: CircularStrokeCap.round,
                linearGradient: LinearGradient(
                  colors: [Colors.blueAccent.shade400, Colors.blue.shade700],
                ),
                backgroundColor: Colors.transparent,
                center: Container(), // Avoids cluttering the center
              ),
            ),

            // Inner Circular Indicator (Water Intake)
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.greenAccent.withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: CircularPercentIndicator(
                radius: 120.0,
                lineWidth: 20.0,
                animation: true,
                percent: (waterConsumed / waterGoal).clamp(0.0, 1.0),
                circularStrokeCap: CircularStrokeCap.round,
                linearGradient: LinearGradient(
                  colors: [Colors.green.shade400, Colors.greenAccent.shade700],
                ),
                backgroundColor: Colors.grey.shade300,
                center: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Water Intake",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.blueGrey.shade800,
                      ),
                    ),
                    Text(
                      "${waterConsumed.toInt()} ml",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    Text(
                      "Goal: ${waterGoal.toInt()} ml",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.green.shade700, // Goal in green
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildRemainingDisplay(),
        const SizedBox(height: 20),

        // Warning Card when water remaining is below 100ml
        if ((bottleCapacity - tempWaterConsumed) < 100)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [Colors.redAccent.shade200, Colors.redAccent.shade700],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Low Water Alert!",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Your bottle is almost empty. Please refill soon.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        const SizedBox(height: 20),
        _buildTodaysRecord(),
      ],
    );
  }

  Widget _buildWaterInfoCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withOpacity(0.3), // Adjust alpha for a subtle background
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
              ),
              Text(
                value,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRemainingDisplay() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap( // Wrap instead of Row to avoid overflow
        spacing: 10, // Adds space between cards
        runSpacing: 10, // Moves cards to a new line if needed
        alignment: WrapAlignment.center, // Centers items if they wrap
        children: [
          _buildWaterInfoCard(
            "To Target",
            "${(waterGoal - waterConsumed).toInt().clamp(0, waterGoal.toInt())} ml",
            Colors.redAccent,
            Icons.flag,
          ),
          _buildWaterInfoCard(
            "Water Left",
            "${(bottleCapacity - tempWaterConsumed).toInt()} ml",
            Colors.green,
            Icons.local_drink,
          ),
        ],
      ),
    );
  }

  Widget _buildTodaysRecord() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: waterRecords.length,
      itemBuilder: (context, index) {
        final record = waterRecords.reversed.toList()[index]; // Reverse the list
        final time = DateFormat.jm().format(record['time']);
        final amount = record['amount'];

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: ListTile(
            leading: const Icon(Icons.water_drop, color: Colors.blueAccent),
            title: Text("$amount ml"),
            subtitle: Text("at $time"),
            trailing: const Icon(Icons.check_circle, color: Colors.green),
          ),
        );
      },
    );
  }
}
