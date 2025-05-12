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