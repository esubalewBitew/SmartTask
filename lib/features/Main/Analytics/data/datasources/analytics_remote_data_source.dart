import '../models/analytics_model.dart';

abstract class AnalyticsRemoteDataSource {
  Future<List<AnalyticsModel>> getAnalytics();
  Future<AnalyticsModel> getMetricDetails(String metricId);
  Future<void> updateMetricGoal(String metricId, double newGoal);
}

class AnalyticsRemoteDataSourceImpl implements AnalyticsRemoteDataSource {
  @override
  Future<List<AnalyticsModel>> getAnalytics() async {
    // Implement API call
    throw UnimplementedError();
  }

  @override
  Future<AnalyticsModel> getMetricDetails(String metricId) async {
    // Implement API call
    throw UnimplementedError();
  }

  @override
  Future<void> updateMetricGoal(String metricId, double newGoal) async {
    // Implement API call
    throw UnimplementedError();
  }
}
