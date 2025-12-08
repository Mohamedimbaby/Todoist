import 'package:equatable/equatable.dart';

/// Base failure class for error handling
abstract class Failure extends Equatable {
  final String message;
  final int? code;

  const Failure({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}

/// Network-related failures
class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'Network error occurred'});
}

/// Server-related failures
class ServerFailure extends Failure {
  const ServerFailure({super.message = 'Server error occurred', super.code});
}

/// Cache/local storage failures
class CacheFailure extends Failure {
  const CacheFailure({super.message = 'Cache error occurred'});
}

/// Authentication failures
class AuthFailure extends Failure {
  const AuthFailure({super.message = 'Authentication failed'});
}

/// Sync-related failures
class SyncFailure extends Failure {
  const SyncFailure({super.message = 'Sync failed'});
}

/// Validation failures
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message});
}

