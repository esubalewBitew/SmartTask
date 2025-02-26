import '../entities/analytics_entity.dart';

abstract class AnalyticsRepository {
  Future<List<AnalyticsEntity>> getAnalytics();
  Future<AnalyticsEntity> getMetricDetails(String metricId);
  Future<void> updateMetricGoal(String metricId, double newGoal);
}
