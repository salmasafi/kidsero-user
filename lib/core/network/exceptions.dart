/// Base exception class for all custom exceptions
abstract class AppException implements Exception {
  final String message;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const AppException(
    this.message, {
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() => message;
}

/// Exception thrown when there's a network connectivity issue
class NetworkException extends AppException {
  const NetworkException(
    super.message, {
    super.originalError,
    super.stackTrace,
  });
}

/// Exception thrown when authentication fails or session expires
class AuthenticationException extends AppException {
  const AuthenticationException(
    super.message, {
    super.originalError,
    super.stackTrace,
  });
}

/// Exception thrown when the server returns an error
class ServerException extends AppException {
  final int? statusCode;

  const ServerException(
    super.message, {
    this.statusCode,
    super.originalError,
    super.stackTrace,
  });
}

/// Exception thrown when data parsing fails
class DataParsingException extends AppException {
  const DataParsingException(
    super.message, {
    super.originalError,
    super.stackTrace,
  });
}

/// Exception thrown when a resource is not found
class NotFoundException extends AppException {
  const NotFoundException(
    super.message, {
    super.originalError,
    super.stackTrace,
  });
}

/// Exception thrown for business logic errors
class BusinessLogicException extends AppException {
  const BusinessLogicException(
    super.message, {
    super.originalError,
    super.stackTrace,
  });
}
