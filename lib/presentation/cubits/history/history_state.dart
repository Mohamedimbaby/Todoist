import 'package:equatable/equatable.dart';
import '../../../domain/entities/history_entity.dart';

/// States for HistoryCubit
abstract class HistoryState extends Equatable {
  const HistoryState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class HistoryInitial extends HistoryState {
  const HistoryInitial();
}

/// Loading state
class HistoryLoading extends HistoryState {
  const HistoryLoading();
}

/// History loaded successfully
class HistoryLoaded extends HistoryState {
  final List<HistoryEntity> records;
  final int totalTrackedSeconds;

  const HistoryLoaded({
    required this.records,
    required this.totalTrackedSeconds,
  });

  String get formattedTotalTime {
    final hours = totalTrackedSeconds ~/ 3600;
    final minutes = (totalTrackedSeconds % 3600) ~/ 60;
    return '${hours}h ${minutes}m';
  }

  @override
  List<Object?> get props => [records, totalTrackedSeconds];
}

/// Error state
class HistoryError extends HistoryState {
  final String message;

  const HistoryError(this.message);

  @override
  List<Object?> get props => [message];
}

