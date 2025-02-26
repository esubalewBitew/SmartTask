class AnalyticsEntity {
  final String id;
  final String metric;
  final double value;
  final DateTime date;
  final String category;
  final Map<String, dynamic> additionalData;

  AnalyticsEntity({
    required this.id,
    required this.metric,
    required this.value,
    required this.date,
    required this.category,
    required this.additionalData,
  });
}
