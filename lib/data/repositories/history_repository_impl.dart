import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/history_entity.dart';
import '../../domain/repositories/history_repository.dart';
import '../models/history_model.dart';

/// Implementation of HistoryRepository using Hive
class HistoryRepositoryImpl implements HistoryRepository {
  final Box<HistoryModel> _historyBox;

  HistoryRepositoryImpl({required Box<HistoryModel> historyBox})
      : _historyBox = historyBox;

  @override
  Future<List<HistoryEntity>> getAllHistory() async {
    final records = _historyBox.values.map((m) => m.toEntity()).toList();
    records.sort((a, b) => b.completedAt.compareTo(a.completedAt));
    return records;
  }

  @override
  Future<List<HistoryEntity>> getHistoryByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    return _historyBox.values
        .where((m) =>
            m.completedAt.isAfter(start) && m.completedAt.isBefore(end))
        .map((m) => m.toEntity())
        .toList();
  }

  @override
  Future<HistoryEntity> createHistoryRecord(HistoryEntity record) async {
    final id = record.id.isEmpty ? const Uuid().v4() : record.id;
    final newRecord = HistoryEntity(
      id: id,
      taskId: record.taskId,
      taskContent: record.taskContent,
      totalTrackedSeconds: record.totalTrackedSeconds,
      completedAt: record.completedAt,
      projectId: record.projectId,
    );
    await _historyBox.put(id, HistoryModel.fromEntity(newRecord));
    return newRecord;
  }

  @override
  Future<HistoryEntity?> getHistoryByTaskId(String taskId) async {
    try {
      final model = _historyBox.values.firstWhere(
        (m) => m.taskId == taskId,
      );
      return model.toEntity();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<int> getTotalTrackedTime() async {
    int total = 0;
    for (final model in _historyBox.values) {
      total += model.totalTrackedSeconds;
    }
    return total;
  }

  @override
  Future<int> getTrackedTimeForDate(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    final records = await getHistoryByDateRange(start, end);
    int total = 0;
    for (final record in records) {
      total += record.totalTrackedSeconds;
    }
    return total;
  }
}
