import '../../domain/entities/analytics_entity.dart';

class AnalyticsModel extends AnalyticsEntity {
  AnalyticsModel({
    required String id,
    required String metric,
    required double value,
    required DateTime date,
    required String category,
    required Map<String, dynamic> additionalData,
  }) : super(
          id: id,
          metric: metric,
          value: value,
          date: date,
          category: category,
          additionalData: additionalData,
        );

  factory AnalyticsModel.fromJson(Map<String, dynamic> json) {
    return AnalyticsModel(
      id: json['id'],
      metric: json['metric'],
      value: json['value'].toDouble(),
      date: DateTime.parse(json['date']),
      category: json['category'],
      additionalData: json['additional_data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'metric': metric,
      'value': value,
      'date': date.toIso8601String(),
      'category': category,
      'additional_data': additionalData,
    };
  }
}
