/// Base exception class
class AppException implements Exception {
  final ErrorType errorType;
  final int? code;

  const AppException({required this.errorType, this.code});

  @override
  String toString() => 'AppException: $errorType (code: $code)';
}


enum ErrorType {
  network,
  server,
  cache,
  auth,
  notFound,
}

