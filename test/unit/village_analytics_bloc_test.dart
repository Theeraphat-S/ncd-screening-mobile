import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/domain/models/village_analytics.dart';
import 'package:ncd_screening_mobile/feature/nurse/bloc/village_analytics_bloc.dart';
import '../support/mock_ncd_repository.dart';

class FailingMockNcdRepository extends MockNcdRepository {
  @override
  Future<List<Village>> getVillages() async {
    throw Exception('Database connection error');
  }
}

void main() {
  late MockNcdRepository repository;

  setUp(() {
    repository = MockNcdRepository();
  });

  group('VillageAnalyticsBloc Unit Tests', () {
    test('Initial state is VillageAnalyticsStatus.initial', () {
      final bloc = VillageAnalyticsBloc(repository);
      expect(bloc.state.status, equals(VillageAnalyticsStatus.initial));
      expect(bloc.state.analytics, isNull);
      expect(bloc.state.villages, isEmpty);
      expect(bloc.state.selectedVillageId, isNull);
      expect(bloc.state.sortOrder, equals(AnalyticsSortOrder.highRiskDesc));
      bloc.close();
    });

    test(
      'VillageAnalyticsLoadRequested loads data and computes analytics',
      () async {
        final bloc = VillageAnalyticsBloc(repository);
        bloc.add(const VillageAnalyticsLoadRequested());

        await expectLater(
          bloc.stream,
          emitsInOrder([
            isA<VillageAnalyticsState>().having(
              (s) => s.status,
              'status',
              VillageAnalyticsStatus.loading,
            ),
            isA<VillageAnalyticsState>()
                .having(
                  (s) => s.status,
                  'status',
                  VillageAnalyticsStatus.success,
                )
                .having((s) => s.analytics, 'analytics', isNotNull)
                .having((s) => s.villages.length, 'villages count', 5)
                .having((s) => s.selectedVillageId, 'selectedVillageId', isNull)
                .having(
                  (s) => s.analytics!.totalPatients,
                  'total patients',
                  greaterThan(0),
                )
                .having(
                  (s) => s.analytics!.villageComparisons.length,
                  'comparisons count',
                  5,
                ),
          ]),
        );
        await bloc.close();
      },
    );

    test(
      'VillageAnalyticsFilterChanged dynamically filters analytics for a single village',
      () async {
        final bloc = VillageAnalyticsBloc(repository);
        bloc.add(const VillageAnalyticsLoadRequested());

        // Wait for initial load
        await bloc.stream.firstWhere(
          (s) => s.status == VillageAnalyticsStatus.success,
        );

        // Now filter by V001
        bloc.add(const VillageAnalyticsFilterChanged('V001'));

        await expectLater(
          bloc.stream,
          emitsInOrder([
            isA<VillageAnalyticsState>()
                .having(
                  (s) => s.status,
                  'status',
                  VillageAnalyticsStatus.success,
                )
                .having((s) => s.selectedVillageId, 'selectedVillageId', 'V001')
                .having(
                  (s) => s.analytics!.selectedVillageId,
                  'analytics selectedVillageId',
                  'V001',
                )
                .having(
                  (s) => s.analytics!.isAllVillages,
                  'isAllVillages',
                  isFalse,
                ),
          ]),
        );

        // Reset to ALL
        bloc.add(const VillageAnalyticsFilterChanged('ALL'));

        await expectLater(
          bloc.stream,
          emitsInOrder([
            isA<VillageAnalyticsState>()
                .having(
                  (s) => s.status,
                  'status',
                  VillageAnalyticsStatus.success,
                )
                .having((s) => s.selectedVillageId, 'selectedVillageId', isNull)
                .having(
                  (s) => s.analytics!.isAllVillages,
                  'isAllVillages',
                  isTrue,
                ),
          ]),
        );

        await bloc.close();
      },
    );

    test(
      'VillageAnalyticsSortOrderChanged re-sorts village comparisons',
      () async {
        final bloc = VillageAnalyticsBloc(repository);
        bloc.add(const VillageAnalyticsLoadRequested());

        // Wait for initial load
        await bloc.stream.firstWhere(
          (s) => s.status == VillageAnalyticsStatus.success,
        );

        // Change sort order to villageNumberAsc
        bloc.add(
          const VillageAnalyticsSortOrderChanged(
            AnalyticsSortOrder.villageNumberAsc,
          ),
        );

        await expectLater(
          bloc.stream,
          emitsInOrder([
            isA<VillageAnalyticsState>()
                .having(
                  (s) => s.status,
                  'status',
                  VillageAnalyticsStatus.success,
                )
                .having(
                  (s) => s.sortOrder,
                  'sortOrder',
                  AnalyticsSortOrder.villageNumberAsc,
                )
                .having(
                  (s) => s.analytics!.sortOrder,
                  'analytics sortOrder',
                  AnalyticsSortOrder.villageNumberAsc,
                )
                .having(
                  (s) => s
                      .analytics!
                      .villageComparisons
                      .first
                      .village
                      .villageNumber,
                  'first village number',
                  '1',
                ),
          ]),
        );

        await bloc.close();
      },
    );

    test(
      'VillageAnalyticsRefreshRequested reloads latest data and recomputes',
      () async {
        final bloc = VillageAnalyticsBloc(repository);
        bloc.add(const VillageAnalyticsLoadRequested());

        await bloc.stream.firstWhere(
          (s) => s.status == VillageAnalyticsStatus.success,
        );

        bloc.add(const VillageAnalyticsRefreshRequested());

        await expectLater(
          bloc.stream,
          emitsInOrder([
            isA<VillageAnalyticsState>().having(
              (s) => s.status,
              'status',
              VillageAnalyticsStatus.loading,
            ),
            isA<VillageAnalyticsState>()
                .having(
                  (s) => s.status,
                  'status',
                  VillageAnalyticsStatus.success,
                )
                .having((s) => s.analytics, 'analytics', isNotNull),
          ]),
        );

        await bloc.close();
      },
    );

    test('Emits failure state when repository throws an error', () async {
      final failingRepo = FailingMockNcdRepository();
      final bloc = VillageAnalyticsBloc(failingRepo);
      bloc.add(const VillageAnalyticsLoadRequested());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<VillageAnalyticsState>().having(
            (s) => s.status,
            'status',
            VillageAnalyticsStatus.loading,
          ),
          isA<VillageAnalyticsState>()
              .having((s) => s.status, 'status', VillageAnalyticsStatus.failure)
              .having(
                (s) => s.errorMessage,
                'errorMessage',
                contains('ไม่สามารถโหลดข้อมูลสถิติสุขภาพได้'),
              ),
        ]),
      );

      await bloc.close();
    });
  });
}
