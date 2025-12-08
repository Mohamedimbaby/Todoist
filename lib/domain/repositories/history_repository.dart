import '../entities/history_entity.dart';

/// Abstract history repository interface
abstract class HistoryRepository {
  /// Get all history records
  Future<List<HistoryEntity>> getAllHistory();

  /// Get history for a specific date range
  Future<List<HistoryEntity>> getHistoryByDateRange(
    DateTime start,
    DateTime end,
  );

  /// Create a history record
  Future<HistoryEntity> createHistoryRecord(HistoryEntity record);

  /// Get history by task ID
  Future<HistoryEntity?> getHistoryByTaskId(String taskId);

  /// Get total tracked time for all completed tasks
  Future<int> getTotalTrackedTime();

  /// Get total tracked time for a date
  Future<int> getTrackedTimeForDate(DateTime date);
}

