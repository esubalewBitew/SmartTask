abstract class AnalyticsEvent {}

class LoadAnalytics extends AnalyticsEvent {}

class LoadMetricDetails extends AnalyticsEvent {
  final String metricId;
  LoadMetricDetails(this.metricId);
}

class UpdateMetricGoal extends AnalyticsEvent {
  final String metricId;
  final double newGoal;
  UpdateMetricGoal(this.metricId, this.newGoal);
}
