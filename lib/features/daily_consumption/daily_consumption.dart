import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:kitchen_king/model/gas_usage_data.dart';

class DailyConsumption extends StatefulWidget {
  static const String routeName = '/daily-consumption';
  const DailyConsumption({super.key});

  @override
  State<DailyConsumption> createState() => _DailyConsumptionState();
}

class _DailyConsumptionState extends State<DailyConsumption> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gas Usage Tracker',
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
          'Gas Usage Tracker',
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
                        _buildSummaryCards(),
                        const SizedBox(height: 24),
                        _buildMainChart(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildSummaryCards() {
    final latestData = _gasData.isNotEmpty ? _gasData.last : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Summary',
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
              child: _buildSummaryCard(
                'Latest Usage',
                latestData?.gasUsed ?? 0,
                'kg',
                Colors.blue,
                Icons.local_fire_department,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Remaining Gas',
                latestData?.remainingGas ?? 0,
                'kg',
                Colors.green,
                Icons.gas_meter,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Cylinder Size',
                latestData?.cylinderSize ?? 0,
                'kg',
                Colors.purple,
                Icons.category,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Days Left',
                latestData?.daysLeft.toDouble() ?? 0,
                'days',
                Colors.orange,
                Icons.timelapse,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String title,
    double value,
    String unit,
    Color color,
    IconData icon,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        value.toStringAsFixed(2),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        unit,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainChart() {
    if (_gasData.isEmpty) {
      return const Center(
        child: Text('No data available'),
      );
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
            const Text(
              'Daily Gas Consumption',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _getMaxBarValue() * 1.2,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      // tooltipBgColor: Colors.white,
                      tooltipPadding: const EdgeInsets.all(12),
                      tooltipMargin: 8,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final data = _gasData[group.x.toInt()];
                        String value;
                        if (rodIndex == 0) {
                          value = '${data.gasUsed.toStringAsFixed(2)} kg';
                        } else {
                          value = '${data.remainingGas.toStringAsFixed(2)} kg';
                        }
                        return BarTooltipItem(
                          '${_formatDate(data.date)}\n$value',
                          const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value >= 0 && value < _gasData.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Transform.rotate(
                                angle: -0.5,
                                child: Text(
                                  _formatDate(_gasData[value.toInt()].date),
                                  style: const TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                        reservedSize: 42,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toStringAsFixed(1)} kg',
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 10,
                            ),
                          );
                        },
                        reservedSize: 48,
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
                  barGroups: _gasData.asMap().entries.map((entry) {
                    final index = entry.key;
                    final data = entry.value;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: data.gasUsed,
                          color: const Color(0xFF3B82F6),
                          width: 16,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                        BarChartRodData(
                          toY: _getDisplayRemainingGas(data.remainingGas),
                          color: const Color(0xFF10B981),
                          width: 16,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                  gridData: FlGridData(
                    show: true,
                    horizontalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return const FlLine(
                        color: Color(0xFFE2E8F0),
                        strokeWidth: 1,
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('Gas Used', const Color(0xFF3B82F6)),
                const SizedBox(width: 24),
                _buildLegendItem('Remaining Gas', const Color(0xFF10B981)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  double _getDisplayRemainingGas(double value) {
    return value / 15;
  }

  double _getMaxBarValue() {
    double maxGasUsed = 0;
    double maxRemainingGasScaled = 0;

    for (var data in _gasData) {
      if (data.gasUsed > maxGasUsed) {
        maxGasUsed = data.gasUsed;
      }

      double remainingGasScaled = _getDisplayRemainingGas(data.remainingGas);
      if (remainingGasScaled > maxRemainingGasScaled) {
        maxRemainingGasScaled = remainingGasScaled;
      }
    }

    return maxGasUsed > maxRemainingGasScaled
        ? maxGasUsed
        : maxRemainingGasScaled;
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}
