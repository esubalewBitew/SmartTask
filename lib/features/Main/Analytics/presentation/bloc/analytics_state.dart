import '../../domain/entities/analytics_entity.dart';

abstract class AnalyticsState {}

class AnalyticsInitial extends AnalyticsState {}

class AnalyticsLoading extends AnalyticsState {}

class AnalyticsLoaded extends AnalyticsState {
  final List<AnalyticsEntity> analytics;
  AnalyticsLoaded(this.analytics);
}

class MetricDetailsLoaded extends AnalyticsState {
  final AnalyticsEntity metric;
  MetricDetailsLoaded(this.metric);
}

class AnalyticsError extends AnalyticsState {
  final String message;
  AnalyticsError(this.message);
}
