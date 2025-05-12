import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class TotalConsumption extends StatefulWidget {
  static const String routeName = '/total-consumption-screen';
  const TotalConsumption({super.key});

  @override
  State<TotalConsumption> createState() => _TotalConsumptionState();
}

class _TotalConsumptionState extends State<TotalConsumption> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Total Consumption',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        fontFamily: 'Poppins',
        appBarTheme: const AppBarTheme(
          // backgroundColor: Color(0xFF3B82F6),
          elevation: 0,
        ),
      ),
      home: const GasUsageTrackerScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class GasUsageData {
  final String date;
  final double gasUsed;
  final double remainingGas;
  final double cylinderSize;
  final int daysLeft;
  final int cookingFrequency;
  final int familySize;

  GasUsageData({
    required this.date,
    required this.gasUsed,
    required this.remainingGas,
    required this.cylinderSize,
    required this.daysLeft,
    required this.cookingFrequency,
    required this.familySize,
  });

  factory GasUsageData.fromFirestore(String date, Map<String, dynamic> data) {
    return GasUsageData(
      date: date,
      gasUsed: (data['gas_used'] ?? 0).toDouble(),
      remainingGas: (data['remaining_gas'] ?? 0).toDouble(),
      cylinderSize: (data['cylinder_size'] ?? 0).toDouble(),
      daysLeft: (data['days_left'] ?? 0).toInt(),
      cookingFrequency: (data['cooking_frequency'] ?? 0).toInt(),
      familySize: (data['family_size'] ?? 0).toInt(),
    );
  }
}

class GasUsageTrackerScreen extends StatefulWidget {
  const GasUsageTrackerScreen({super.key});

  @override
  _GasUsageTrackerScreenState createState() => _GasUsageTrackerScreenState();
}

class _GasUsageTrackerScreenState extends State<GasUsageTrackerScreen> {
  List<GasUsageData> _gasData = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchGasData();
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
          // If the document structure is flat (each doc is one day's data)
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

        // Add sample data for demonstration
        _gasData = _getSampleData();
      });
    }
  }

  List<GasUsageData> _getSampleData() {
    return [
      GasUsageData(
        date: '2023-01-01',
        gasUsed: 0.29,
        remainingGas: 14.5,
        cylinderSize: 14.5,
        daysLeft: 65,
        cookingFrequency: 3,
        familySize: 3,
      ),
      GasUsageData(
        date: '2023-01-02',
        gasUsed: 0.31,
        remainingGas: 14.2,
        cylinderSize: 14.5,
        daysLeft: 63,
        cookingFrequency: 3,
        familySize: 3,
      ),
      GasUsageData(
        date: '2023-01-03',
        gasUsed: 0.28,
        remainingGas: 13.9,
        cylinderSize: 14.5,
        daysLeft: 61,
        cookingFrequency: 3,
        familySize: 3,
      ),
      GasUsageData(
        date: '2023-01-04',
        gasUsed: 0.33,
        remainingGas: 13.6,
        cylinderSize: 14.5,
        daysLeft: 59,
        cookingFrequency: 3,
        familySize: 3,
      ),
      GasUsageData(
        date: '2023-01-05',
        gasUsed: 0.27,
        remainingGas: 13.3,
        cylinderSize: 14.5,
        daysLeft: 57,
        cookingFrequency: 3,
        familySize: 3,
      ),
      GasUsageData(
        date: '2023-01-06',
        gasUsed: 0.30,
        remainingGas: 13.0,
        cylinderSize: 14.5,
        daysLeft: 55,
        cookingFrequency: 3,
        familySize: 3,
      ),
      GasUsageData(
        date: '2023-01-07',
        gasUsed: 0.35,
        remainingGas: 12.7,
        cylinderSize: 14.5,
        daysLeft: 53,
        cookingFrequency: 3,
        familySize: 3,
      ),
    ];
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM d').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Total Consumption',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchGasData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _error != null && _gasData.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 60,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchGasData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailCharts(),
                        if (_error != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: Card(
                              color: Colors.red.shade50,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Error',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _error!,
                                      style: TextStyle(
                                        color: Colors.red.shade800,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Showing sample data instead',
                                      style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildDetailCharts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Detailed Analysis',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTrendChart(
                'Usage Trend',
                Colors.blue,
                (data) => data.gasUsed,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTrendChart(
                'Remaining Gas',
                Colors.green,
                (data) => data.remainingGas,
                showDecreasing: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTrendChart(
    String title,
    Color color,
    double Function(GasUsageData) getValue, {
    bool showDecreasing = false,
  }) {
    if (_gasData.isEmpty) {
      return const SizedBox();
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      // tooltipBgColor: Colors.white,
                      tooltipPadding: const EdgeInsets.all(12),
                      getTooltipItems: (List<LineBarSpot> touchedSpots) {
                        return touchedSpots.map((spot) {
                          final data = _gasData[spot.x.toInt()];
                          return LineTooltipItem(
                            '${_formatDate(data.date)}\n${spot.y.toStringAsFixed(2)} kg',
                            TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) {
                      return const FlLine(
                        color: Color(0xFFE2E8F0),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value % 2 == 0 &&
                              value >= 0 &&
                              value < _gasData.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                _formatDate(_gasData[value.toInt()].date),
                                style: const TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 10,
                                ),
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                        reservedSize: 30,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 10,
                            ),
                          );
                        },
                        reservedSize: 28,
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  minX: 0,
                  maxX: _gasData.length - 1.0,
                  minY: showDecreasing
                      ? _gasData.map(getValue).reduce(
                              (min, value) => min < value ? min : value) *
                          0.9
                      : 0,
                  maxY: _gasData
                          .map(getValue)
                          .reduce((max, value) => max > value ? max : value) *
                      1.1,
                  lineBarsData: [
                    LineChartBarData(
                      spots: _gasData.asMap().entries.map((entry) {
                        return FlSpot(
                            entry.key.toDouble(), getValue(entry.value));
                      }).toList(),
                      isCurved: true,
                      color: color,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: Colors.white,
                            strokeWidth: 2,
                            strokeColor: color,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: color.withOpacity(0.2),
                      ),
                    ),
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
