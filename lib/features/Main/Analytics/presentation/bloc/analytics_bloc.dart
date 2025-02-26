import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/analytics_repository.dart';
import 'analytics_event.dart';
import 'analytics_state.dart';

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final AnalyticsRepository analyticsRepository;

  AnalyticsBloc({required this.analyticsRepository})
      : super(AnalyticsInitial()) {
    on<LoadAnalytics>((event, emit) async {
      emit(AnalyticsLoading());
      try {
        final analytics = await analyticsRepository.getAnalytics();
        emit(AnalyticsLoaded(analytics));
      } catch (e) {
        emit(AnalyticsError(e.toString()));
      }
    });

    on<LoadMetricDetails>((event, emit) async {
      emit(AnalyticsLoading());
      try {
        final metric =
            await analyticsRepository.getMetricDetails(event.metricId);
        emit(MetricDetailsLoaded(metric));
      } catch (e) {
        emit(AnalyticsError(e.toString()));
      }
    });

    on<UpdateMetricGoal>((event, emit) async {
      emit(AnalyticsLoading());
      try {
        await analyticsRepository.updateMetricGoal(
            event.metricId, event.newGoal);
        final analytics = await analyticsRepository.getAnalytics();
        emit(AnalyticsLoaded(analytics));
      } catch (e) {
        emit(AnalyticsError(e.toString()));
      }
    });
  }
}
