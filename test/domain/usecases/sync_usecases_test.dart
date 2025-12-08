import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tasktime/domain/entities/sync_action_entity.dart';
import 'package:tasktime/domain/repositories/sync_repository.dart';
import 'package:tasktime/domain/usecases/sync_usecases.dart';

class MockSyncRepository extends Mock implements SyncRepository {}

void main() {
  late MockSyncRepository mockRepository;
  late GetPendingSyncActionsUseCase getPendingUseCase;
  late AddSyncActionUseCase addSyncActionUseCase;
  late RemoveSyncActionUseCase removeSyncActionUseCase;
  late HasPendingSyncUseCase hasPendingUseCase;
  late GetSyncQueueCountUseCase getCountUseCase;

  setUp(() {
    mockRepository = MockSyncRepository();
    getPendingUseCase = GetPendingSyncActionsUseCase(mockRepository);
    addSyncActionUseCase = AddSyncActionUseCase(mockRepository);
    removeSyncActionUseCase = RemoveSyncActionUseCase(mockRepository);
    hasPendingUseCase = HasPendingSyncUseCase(mockRepository);
    getCountUseCase = GetSyncQueueCountUseCase(mockRepository);
  });

  setUpAll(() {
    registerFallbackValue(SyncActionEntity(
      id: '',
      type: SyncActionType.createTask,
      entityId: '',
      payload: {},
      createdAt: DateTime.now(),
    ));
  });

  final testAction = SyncActionEntity(
    id: '1',
    type: SyncActionType.createTask,
    entityId: 'task-1',
    payload: {'content': 'Test'},
    createdAt: DateTime.now(),
  );

  group('GetPendingSyncActionsUseCase', () {
    test('should return list of pending actions', () async {
      when(() => mockRepository.getPendingSyncActions())
          .thenAnswer((_) async => [testAction]);

      final result = await getPendingUseCase();

      expect(result, [testAction]);
      verify(() => mockRepository.getPendingSyncActions()).called(1);
    });
  });

  group('AddSyncActionUseCase', () {
    test('should add action to repository', () async {
      when(() => mockRepository.addSyncAction(any()))
          .thenAnswer((_) async {});

      await addSyncActionUseCase(testAction);

      verify(() => mockRepository.addSyncAction(any())).called(1);
    });
  });

  group('RemoveSyncActionUseCase', () {
    test('should remove action from repository', () async {
      when(() => mockRepository.removeSyncAction('1'))
          .thenAnswer((_) async {});

      await removeSyncActionUseCase('1');

      verify(() => mockRepository.removeSyncAction('1')).called(1);
    });
  });

  group('HasPendingSyncUseCase', () {
    test('should return true when there are pending actions', () async {
      when(() => mockRepository.hasPendingSyncActions())
          .thenAnswer((_) async => true);

      final result = await hasPendingUseCase();

      expect(result, true);
    });

    test('should return false when no pending actions', () async {
      when(() => mockRepository.hasPendingSyncActions())
          .thenAnswer((_) async => false);

      final result = await hasPendingUseCase();

      expect(result, false);
    });
  });

  group('GetSyncQueueCountUseCase', () {
    test('should return count of pending actions', () async {
      when(() => mockRepository.getSyncActionCount())
          .thenAnswer((_) async => 5);

      final result = await getCountUseCase();

      expect(result, 5);
    });
  });
}
