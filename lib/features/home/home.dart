import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kitchen_king/features/Maps/map_screen.dart';
import 'package:kitchen_king/features/notificatinos/notification_screen.dart';
import 'package:kitchen_king/features/consumption_graph/total_consumption.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = "/home-screen";
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String locationMessage = "Press the button to get location";

  final Map<String, dynamic> jsonData = {
    "27-03-2024": {
      "gas_used": 1.5,
    },
    "28-03-2024": {
      "gas_used": 1.2,
    }
  };

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

    // Fetch location if permission is granted
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );

    setState(() {
      locationMessage = "Lat: ${position.latitude}, Lng: ${position.longitude}";
    });
  }

  @override
  Widget build(BuildContext context) {
    List<BarChartGroupData> barGroups = [];
    List<String> dates = jsonData.keys.toList();
    for (int i = 0; i < dates.length; i++) {
      String date = dates[i];
      double gasUsed = jsonData[date]["gas_used"] ?? 0.0;
      barGroups.add(
        BarChartGroupData(
          x: i + 1,
          barRods: [
            BarChartRodData(
              toY: gasUsed,
              color: Colors.blue,
              width: 16,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Dashboard'),
        centerTitle: true,
      ),
      // appBar: AppBar(
      //   toolbarHeight: 70,
      //   automaticallyImplyLeading: false,
      //   backgroundColor: const Color(0xFF45484A),
      //   title: const Text(
      //     "Dashboard",
      //     style: TextStyle(
      //       fontSize: 30,
      //       fontWeight: FontWeight.bold,
      //       color: Colors.white,
      //     ),
      //   ),
      //   elevation: 20,
      // ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              margin: const EdgeInsets.only(top: 10),
              color: Colors.white,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 20,
                ),
                height: height * .27,
                width: width * .9,
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Text(
                          "Gas Level Percentage",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () {},
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
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(10.0),
                              child: FancyCircularIndicator(
                                percentage: 75,
                                size: 150,
                                gradientColors: [
                                  Colors.black,
                                  Colors.black,
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 10),
                      ],
                    ),
                  ],
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
                      horizontal: 5,
                    ),
                    height: height * .25,
                    width: width * .44,
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 5),
                              child: Text(
                                "Estimate Days",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            // const Spacer(),
                          ],
                        ),
                        Divider(
                          thickness: 2.0,
                          color: Colors.black54,
                        ),
                        Text(
                          "28",
                          style: TextStyle(
                            fontSize: 45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.all(10),
                  color: Colors.white,
                  elevation: 10,
                  child: Container(
                    height: height * .25,
                    width: width * .44,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      // vertical: ,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              "Total Consumption",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  TotalConsumption.routeName,
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
                          Navigator.pushNamed(context, MapsScreen.routeName);
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
