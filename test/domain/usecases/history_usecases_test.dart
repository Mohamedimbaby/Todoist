import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tasktime/domain/entities/history_entity.dart';
import 'package:tasktime/domain/repositories/history_repository.dart';
import 'package:tasktime/domain/usecases/history_usecases.dart';

class MockHistoryRepository extends Mock implements HistoryRepository {}

void main() {
  late MockHistoryRepository mockRepository;
  late GetAllHistoryUseCase getAllHistoryUseCase;
  late CreateHistoryRecordUseCase createRecordUseCase;
  late GetHistoryByDateRangeUseCase getByDateRangeUseCase;
  late GetTotalHistoryTimeUseCase getTotalTimeUseCase;

  setUp(() {
    mockRepository = MockHistoryRepository();
    getAllHistoryUseCase = GetAllHistoryUseCase(mockRepository);
    createRecordUseCase = CreateHistoryRecordUseCase(mockRepository);
    getByDateRangeUseCase = GetHistoryByDateRangeUseCase(mockRepository);
    getTotalTimeUseCase = GetTotalHistoryTimeUseCase(mockRepository);
  });

  setUpAll(() {
    registerFallbackValue(HistoryEntity(
      id: '',
      taskId: '',
      taskContent: '',
      totalTrackedSeconds: 0,
      completedAt: DateTime.now(),
    ));
  });

  final testRecord = HistoryEntity(
    id: '1',
    taskId: 'task-1',
    taskContent: 'Completed Task',
    totalTrackedSeconds: 3600,
    completedAt: DateTime.now(),
  );

  group('GetAllHistoryUseCase', () {
    test('should return list of history records', () async {
      when(() => mockRepository.getAllHistory())
          .thenAnswer((_) async => [testRecord]);

      final result = await getAllHistoryUseCase();

      expect(result, [testRecord]);
      verify(() => mockRepository.getAllHistory()).called(1);
    });
  });

  group('CreateHistoryRecordUseCase', () {
    test('should create record via repository', () async {
      when(() => mockRepository.createHistoryRecord(any()))
          .thenAnswer((_) async => testRecord);

      final result = await createRecordUseCase(testRecord);

      expect(result, testRecord);
      verify(() => mockRepository.createHistoryRecord(any())).called(1);
    });
  });

  group('GetHistoryByDateRangeUseCase', () {
    test('should return records within date range', () async {
      final start = DateTime(2024, 1, 1);
      final end = DateTime(2024, 12, 31);

      when(() => mockRepository.getHistoryByDateRange(start, end))
          .thenAnswer((_) async => [testRecord]);

      final result = await getByDateRangeUseCase(start, end);

      expect(result, [testRecord]);
      verify(() => mockRepository.getHistoryByDateRange(start, end)).called(1);
    });
  });

  group('GetTotalHistoryTimeUseCase', () {
    test('should return total tracked time in seconds', () async {
      when(() => mockRepository.getTotalTrackedTime())
          .thenAnswer((_) async => 7200);

      final result = await getTotalTimeUseCase();

      expect(result, 7200);
    });
  });
}
