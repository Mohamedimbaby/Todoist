import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tasktime/domain/entities/timer_entity.dart';
import 'package:tasktime/domain/repositories/timer_repository.dart';
import 'package:tasktime/presentation/cubits/timer/timer_cubit.dart';
import 'package:tasktime/presentation/cubits/timer/timer_state.dart';

class MockTimerRepository extends Mock implements TimerRepository {}

void main() {
  late MockTimerRepository mockRepository;

  setUp(() {
    mockRepository = MockTimerRepository();
  });

  final testTimer = TimerEntity(
    id: '1',
    taskId: 'task-1',
    isRunning: false,
    accumulatedSeconds: 100,
  );

  TimerCubit buildCubit() => TimerCubit(timerRepository: mockRepository);

  group('TimerCubit', () {
    test('initial state is TimerInitial', () {
      final cubit = buildCubit();
      expect(cubit.state, const TimerInitial());
    });

    test('loadTimers emits TimerLoaded on success', () async {
      when(() => mockRepository.getAllTimers())
          .thenAnswer((_) async => [testTimer]);
      when(() => mockRepository.getRunningTimer())
          .thenAnswer((_) async => null);

      final cubit = buildCubit();
      await cubit.loadTimers();

      expect(cubit.state, isA<TimerLoaded>());
    });

    test('startTimer stops all and starts new timer', () async {
      final runningTimer = testTimer.copyWith(isRunning: true);
      when(() => mockRepository.stopAllTimers()).thenAnswer((_) async {});
      when(() => mockRepository.startTimer('task-1'))
          .thenAnswer((_) async => runningTimer);
      when(() => mockRepository.getAllTimers())
          .thenAnswer((_) async => [runningTimer]);

      final cubit = buildCubit();
      await cubit.startTimer('task-1');

      expect(cubit.state, isA<TimerLoaded>());
      verify(() => mockRepository.stopAllTimers()).called(1);
      verify(() => mockRepository.startTimer('task-1')).called(1);
    });
  });
}
