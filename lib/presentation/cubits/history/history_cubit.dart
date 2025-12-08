import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/history_usecases.dart';
import 'history_state.dart';

/// Cubit for managing task history
class HistoryCubit extends Cubit<HistoryState> {
  final GetAllHistoryUseCase _getAllHistoryUseCase;
  final GetTotalHistoryTimeUseCase _getTotalHistoryTimeUseCase;

  HistoryCubit({
    required GetAllHistoryUseCase getAllHistoryUseCase,
    required GetTotalHistoryTimeUseCase getTotalHistoryTimeUseCase,
  })  : _getAllHistoryUseCase = getAllHistoryUseCase,
        _getTotalHistoryTimeUseCase = getTotalHistoryTimeUseCase,
        super(const HistoryInitial());

  /// Load all history records
  Future<void> loadHistory() async {
    emit(const HistoryLoading());
    try {
      final records = await _getAllHistoryUseCase();
      final totalTime = await _getTotalHistoryTimeUseCase();
      emit(HistoryLoaded(records: records, totalTrackedSeconds: totalTime));
    } catch (e) {
      emit(HistoryError(e.toString()));
    }
  }

  /// Load history for a date range
  Future<void> loadHistoryByDateRange(DateTime start, DateTime end) async {
    emit(const HistoryLoading());
    try {
      final records = await _getAllHistoryUseCase();
      final filteredRecords = records
          .where((r) =>
              r.completedAt.isAfter(start) && r.completedAt.isBefore(end))
          .toList();
      final totalTime =
          filteredRecords.fold(0, (sum, r) => sum + r.totalTrackedSeconds);
      emit(HistoryLoaded(
        records: filteredRecords,
        totalTrackedSeconds: totalTime,
      ));
    } catch (e) {
      emit(HistoryError(e.toString()));
    }
  }
}
