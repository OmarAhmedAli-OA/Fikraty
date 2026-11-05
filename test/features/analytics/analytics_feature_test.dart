import 'package:flutter_test/flutter_test.dart';
import 'package:fikraty/features/analytics/data/models/analytics_model.dart';
import 'package:fikraty/features/analytics/data/datasources/analytics_local_data_source.dart';
import 'package:fikraty/features/analytics/data/repositories/analytics_repository_impl.dart';
import 'package:fikraty/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:fikraty/features/analytics/domain/usecases/get_founder_analytics_usecase.dart';
import 'package:fikraty/features/analytics/domain/usecases/get_startup_analytics_usecase.dart';
import 'package:fikraty/features/analytics/domain/usecases/get_investor_analytics_usecase.dart';
import 'package:fikraty/features/analytics/presentation/bloc/analytics_bloc.dart';
import 'package:fikraty/features/analytics/presentation/bloc/analytics_event.dart';
import 'package:fikraty/features/analytics/presentation/bloc/analytics_state.dart';

void main() {
  group('Analytics Models Serialization', () {
    test('AnalyticsMetricModel fromJson and toJson work accurately', () {
      final json = {
        'label': 'Profile Views',
        'value': '2,840',
        'change': '+18% this month',
        'isPositive': true,
      };

      final model = AnalyticsMetricModel.fromJson(json);
      expect(model.label, 'Profile Views');
      expect(model.value, '2,840');
      expect(model.change, '+18% this month');
      expect(model.isPositive, isTrue);

      final out = model.toJson();
      expect(out['label'], 'Profile Views');
      expect(out['value'], '2,840');
    });

    test('AnalyticsChartPointModel fromJson and toJson work accurately', () {
      final json = {'label': 'Day 1', 'value': 42.5};
      final model = AnalyticsChartPointModel.fromJson(json);
      expect(model.label, 'Day 1');
      expect(model.value, 42.5);

      final out = model.toJson();
      expect(out['label'], 'Day 1');
      expect(out['value'], 42.5);
    });

    test('FounderAnalyticsModel serialization', () {
      final model = const FounderAnalyticsModel(
        period: '30D',
        metrics: [
          AnalyticsMetricModel(
            label: 'Profile Views',
            value: '2,840',
            change: '+18%',
          ),
        ],
        reputationScore: 84,
        reputationLevel: 'Rising Founder Tier',
        viewsTrend: [AnalyticsChartPointModel(label: 'Day 1', value: 42)],
        topPosts: [{'title': 'Post 1'}],
        recentActivities: [{'title': 'Activity 1'}],
      );

      final json = model.toJson();
      final reconstructed = FounderAnalyticsModel.fromJson(json);
      expect(reconstructed.period, '30D');
      expect(reconstructed.reputationScore, 84);
      expect(reconstructed.metrics.first.label, 'Profile Views');
    });
  });

  group('AnalyticsLocalDataSource Data Integrity', () {
    late AnalyticsLocalDataSource dataSource;

    setUp(() {
      dataSource = AnalyticsLocalDataSourceImpl();
    });

    test('Founder Analytics contains distinct founder metrics and charts',
        () async {
      for (final period in ['7D', '30D', '90D']) {
        final data = await dataSource.getFounderAnalytics(period);
        expect(data.period, period);
        expect(data.metrics.length, 4);
        expect(data.metrics.any((m) => m.label == 'Profile Views'), isTrue);
        expect(data.metrics.any((m) => m.label == 'Followers'), isTrue);
        expect(data.viewsTrend, isNotEmpty);
      }
    });

    test('Startup Analytics contains MRR, runway, and growth metrics',
        () async {
      for (final period in ['7D', '30D', '90D']) {
        final data = await dataSource.getStartupAnalytics(period);
        expect(data.period, period);
        expect(data.metrics.length, 4);
        expect(data.metrics.any((m) => m.label == 'MRR'), isTrue);
        expect(data.metrics.any((m) => m.label == 'Runway'), isTrue);
        expect(data.mrrTrend, isNotEmpty);
        expect(data.trafficSources, isNotEmpty);
      }
    });

    test('Investor Analytics contains deal evaluation and pipeline metrics',
        () async {
      for (final period in ['7D', '30D', '90D']) {
        final data = await dataSource.getInvestorAnalytics(period);
        expect(data.period, period);
        expect(data.metrics.length, 4);
        expect(
            data.metrics.any((m) => m.label == 'Startups Evaluated'), isTrue);
        expect(data.metrics.any((m) => m.label == 'Active Pipeline'), isTrue);
        expect(data.evaluationsTrend, isNotEmpty);
        expect(data.sectorDistribution, isNotEmpty);
      }
    });
  });

  group('AnalyticsBloc Pipeline', () {
    late AnalyticsLocalDataSource localDataSource;
    late AnalyticsRepository repository;
    late GetFounderAnalyticsUseCase getFounderUseCase;
    late GetStartupAnalyticsUseCase getStartupUseCase;
    late GetInvestorAnalyticsUseCase getInvestorUseCase;
    late AnalyticsBloc bloc;

    setUp(() {
      localDataSource = AnalyticsLocalDataSourceImpl();
      repository = AnalyticsRepositoryImpl(localDataSource);
      getFounderUseCase = GetFounderAnalyticsUseCase(repository);
      getStartupUseCase = GetStartupAnalyticsUseCase(repository);
      getInvestorUseCase = GetInvestorAnalyticsUseCase(repository);

      bloc = AnalyticsBloc(
        getFounderAnalyticsUseCase: getFounderUseCase,
        getStartupAnalyticsUseCase: getStartupUseCase,
        getInvestorAnalyticsUseCase: getInvestorUseCase,
      );
    });

    tearDown(() {
      bloc.close();
    });

    test('Emits FounderAnalyticsLoaded on LoadFounderAnalyticsEvent', () async {
      expectLater(
        bloc.stream,
        emitsInOrder([
          isA<AnalyticsLoading>(),
          isA<FounderAnalyticsLoaded>().having(
            (s) => s.data.reputationScore,
            'reputationScore',
            84,
          ),
        ]),
      );

      bloc.add(const LoadFounderAnalyticsEvent(period: '30D'));
    });

    test('Emits StartupAnalyticsLoaded on LoadStartupAnalyticsEvent', () async {
      expectLater(
        bloc.stream,
        emitsInOrder([
          isA<AnalyticsLoading>(),
          isA<StartupAnalyticsLoaded>().having(
            (s) => s.data.metrics.first.label,
            'first metric label',
            'MRR',
          ),
        ]),
      );

      bloc.add(const LoadStartupAnalyticsEvent(period: '30D'));
    });

    test('Emits InvestorAnalyticsLoaded on LoadInvestorAnalyticsEvent',
        () async {
      expectLater(
        bloc.stream,
        emitsInOrder([
          isA<AnalyticsLoading>(),
          isA<InvestorAnalyticsLoaded>().having(
            (s) => s.data.metrics.first.label,
            'first metric label',
            'Startups Evaluated',
          ),
        ]),
      );

      bloc.add(const LoadInvestorAnalyticsEvent(period: '30D'));
    });
  });
}
