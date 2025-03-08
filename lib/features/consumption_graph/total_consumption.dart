import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
// import 'package:syncfusion_flutter_charts/charts.dart';

class TotalConsumption extends StatefulWidget {
  static const String routeName = '/total-consumption-screen';
  const TotalConsumption({super.key});

  @override
  State<TotalConsumption> createState() => _TotalConsumptionState();
}

class _TotalConsumptionState extends State<TotalConsumption> {
  final List<GasUsageData> gasData = [
    GasUsageData(day: 27, gasUsed: 1.5),
    GasUsageData(day: 28, gasUsed: 1.2),
  ];
  final Map<String, dynamic> data = {
    "27-03-2024": {
      "cylinder_size": 14.2,
      "gas_used": 1.5,
      "family_size": 4,
      "cooking_frequency": 3,
      "remaining_gas": 7.8,
      "days_left": 5
    },
    "28-03-2024": {
      "cylinder_size": 14.2,
      "gas_used": 1.2,
      "family_size": 4,
      "cooking_frequency": 2,
      "remaining_gas": 6.6,
      "days_left": 4
    }
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF45484A),
        title: const Text(
          "Gas Usage Chart",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevation: 20,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceBetween,
            maxY: 2, // Adjust based on max gas usage
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    // Convert the index to the actual date
                    final dates = data.keys.toList();
                    final index = value.toInt();
                    return Text(
                      dates[index].substring(0, 5), // Show date
                      style: const TextStyle(fontSize: 10),
                    );
                  },
                  reservedSize: 40,
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    return Text(
                      value.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 10),
                    );
                  },
                ),
              ),
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            barGroups: data.entries.map((entry) {
              return BarChartGroupData(
                x: data.keys.toList().indexOf(entry.key),
                barRods: [
                  BarChartRodData(
                    toY: entry.value['gas_used'].toDouble(),
                    color: Colors.blue,
                    width: 15,
                  )
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class GasUsageData {
  final int day;
  final double gasUsed;
  GasUsageData({required this.day, required this.gasUsed});
}
