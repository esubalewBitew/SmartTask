import '../../domain/entities/analytics_entity.dart';
import '../../domain/repositories/analytics_repository.dart';
import '../datasources/analytics_remote_data_source.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final AnalyticsRemoteDataSource remoteDataSource;

  AnalyticsRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<AnalyticsEntity>> getAnalytics() async {
    return await remoteDataSource.getAnalytics();
  }

  @override
  Future<AnalyticsEntity> getMetricDetails(String metricId) async {
    return await remoteDataSource.getMetricDetails(metricId);
  }

  @override
  Future<void> updateMetricGoal(String metricId, double newGoal) async {
    await remoteDataSource.updateMetricGoal(metricId, newGoal);
  }
}
