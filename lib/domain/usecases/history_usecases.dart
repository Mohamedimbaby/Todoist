import '../entities/history_entity.dart';
import '../repositories/history_repository.dart';

/// Use case for getting all history
class GetAllHistoryUseCase {
  final HistoryRepository _repository;

  GetAllHistoryUseCase(this._repository);

  Future<List<HistoryEntity>> call() => _repository.getAllHistory();
}

/// Use case for creating history record
class CreateHistoryRecordUseCase {
  final HistoryRepository _repository;

  CreateHistoryRecordUseCase(this._repository);

  Future<HistoryEntity> call(HistoryEntity record) =>
      _repository.createHistoryRecord(record);
}

/// Use case for getting history by date range
class GetHistoryByDateRangeUseCase {
  final HistoryRepository _repository;

  GetHistoryByDateRangeUseCase(this._repository);

  Future<List<HistoryEntity>> call(DateTime start, DateTime end) =>
      _repository.getHistoryByDateRange(start, end);
}

/// Use case for getting total tracked time
class GetTotalHistoryTimeUseCase {
  final HistoryRepository _repository;

  GetTotalHistoryTimeUseCase(this._repository);

  Future<int> call() => _repository.getTotalTrackedTime();
}

