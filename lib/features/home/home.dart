import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kitchen_king/features/Maps/map_screen.dart';
import 'package:kitchen_king/features/daily_consumption/daily_consumption.dart';
import 'package:kitchen_king/features/notificatinos/notification_screen.dart';
import 'package:kitchen_king/features/consumption_graph/total_consumption.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = "/home-screen";
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  String? _error;
  String locationMessage = "Press the button to get location";
  List<GasUsageData> _gasData = [];
  Future<void> _checkAndRequestLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          locationMessage = "Location permission denied!";
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        locationMessage = "Location permission permanently denied!";
      });
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );

    setState(() {
      locationMessage = "Lat: ${position.latitude}, Lng: ${position.longitude}";
    });
  }

  Future<void> _fetchGasData() async {
    try {
      // Reset state
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Get reference to the GasData collection
      final collectionRef = FirebaseFirestore.instance.collection('GasData');

      // Get documents from the collection
      final querySnapshot = await collectionRef.get();
      final List<GasUsageData> loadedData = [];

      for (var doc in querySnapshot.docs) {
        final docData = doc.data();

        // Check if the document has a nested 'data' field
        if (docData.containsKey('data') && docData['data'] is Map) {
          final dataMap = docData['data'] as Map<String, dynamic>;

          // Process each date entry in the nested data
          dataMap.forEach((date, dailyData) {
            if (dailyData is Map<String, dynamic>) {
              loadedData.add(GasUsageData.fromFirestore(date, dailyData));
            }
          });
        } else {
          loadedData.add(GasUsageData.fromFirestore(doc.id, docData));
        }
      }
      // Sort by date
      loadedData.sort((a, b) => a.date.compareTo(b.date));
      setState(() {
        final int length = loadedData.length;
        _gasData = loadedData.sublist(length >= 7 ? length - 7 : 0);
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching gas data: $e');
      setState(() {
        _error = 'Failed to load gas usage data: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchGasData();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    final GasUsageData? latestData = _gasData.isNotEmpty ? _gasData.last : null;
    double percentage = latestData != null
        ? ((latestData.remainingGas / latestData.cylinderSize) * 100).toDouble()
        : 0;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Dashboard'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => Navigator.pushNamed(
                            context,
                            DailyConsumption.routeName,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(
                                  width: 1,
                                ),
                              ),
                              child: SizedBox(
                                height: 180,
                                child: Column(
                                  children: [
                                    const Text(
                                      "Gas Level",
                                      style: TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(30),
                                      child: FancyCircularIndicator(
                                        percentage: percentage,
                                        size: 150,
                                        gradientColors: const [
                                          Colors.black,
                                          Colors.black,
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(
                                width: 1,
                              ),
                            ),
                            child: const SizedBox(
                              height: 180,
                              child: Column(
                                children: [
                                  Text(
                                    "Estimated Days",
                                    style: TextStyle(
                                      fontSize: 25,
                                      fontFamily: "Roboto",
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Center(
                                    child: Text(
                                      "10",
                                      style: TextStyle(
                                        fontSize: 70,
                                        fontFamily: "Roboto",
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    "Days",
                                    style: TextStyle(
                                      fontSize: 25,
                                      fontFamily: "Roboto",
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: () => Navigator.pushNamed(
                        context,
                        TotalConsumption.routeName,
                      ),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Colors.green.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Total Consumption",
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Card(
                        margin: const EdgeInsets.all(10),
                        color: Colors.white,
                        elevation: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                          ),
                          height: height * .25,
                          width: width * .93,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    "Notifications",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                        context,
                                        NotificationScreen.routeName,
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.arrow_forward_ios_sharp,
                                      size: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(
                                thickness: 2.0,
                                color: Colors.black54,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Restart Button
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.redAccent, // Restart button color
                            ),
                            child: IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.restart_alt,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            "Restart",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      // Gas Station Button
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.green, // Gas station button color
                            ),
                            child: IconButton(
                              onPressed: () async {
                                _checkAndRequestLocation();
                                Navigator.pushNamed(
                                    context, MapsScreen.routeName);
                              },
                              icon: const Icon(
                                Icons.gas_meter_outlined,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            "Gas Station",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      // On/Off Button
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue, // On/Off button color
                            ),
                            child: IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.power_settings_new,
                                  color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            "Power",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                ],
              ),
            ),
    );
  }
}

class FancyCircularIndicator extends StatelessWidget {
  final double percentage;
  final double size;
  final List<Color> gradientColors;

  const FancyCircularIndicator({
    super.key,
    required this.percentage,
    this.size = 100,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _FancyCircularPainter(
        percentage: percentage,
        gradientColors: gradientColors,
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Text(
            "${percentage.toInt()}%",
            style: TextStyle(
              fontSize: size * 0.2,
              fontWeight: FontWeight.bold,
              color: gradientColors.last,
            ),
          ),
        ),
      ),
    );
  }
}

class _FancyCircularPainter extends CustomPainter {
  final double percentage;
  final List<Color> gradientColors;

  _FancyCircularPainter({
    required this.percentage,
    required this.gradientColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint backgroundPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    Paint progressPaint = Paint()
      ..shader = SweepGradient(
        colors: gradientColors,
        startAngle: 0.0,
        endAngle: pi * 2,
      ).createShader(Rect.fromCircle(
          center: size.center(Offset.zero), radius: size.width / 2))
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    Offset center = size.center(Offset.zero);
    double radius = size.width / 2;

    canvas.drawCircle(center, radius, backgroundPaint);
    double arcAngle = 2 * pi * (percentage / 100);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -pi / 2,
        arcAngle, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
