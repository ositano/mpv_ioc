// Author: Green Onyeji (https://github.com/ositano/) (https://www.linkedin.com/in/green-onyeji-11608a97/)
// lib/core/api/exception/failure.dart
//
// Sealed failure hierarchy. Every layer that can fail returns
// Either<Failure, T> — the View never sees raw exceptions.

abstract class Failure {
  String failureMessage();
}

class ValidationFailure implements Failure {
  final String message;
  const ValidationFailure(this.message);

  @override
  String failureMessage() => message;
}

class ServerFailure implements Failure {
  @override
  String failureMessage() => 'Something went wrong. Please try again.';
}

class InternetFailure implements Failure {
  @override
  String failureMessage() => 'No internet connection.';
}

class BadResponseFailure implements Failure {
  final String? message;
  const BadResponseFailure({this.message});

  @override
  String failureMessage() => message ?? 'Unexpected response from server.';
}

class ConnectionTimeOutFailure implements Failure {
  @override
  String failureMessage() => 'Connection timed out.';
}

class UnknownFailure implements Failure {
  final String? message;
  const UnknownFailure({this.message});

  @override
  String failureMessage() => message ?? 'An unknown error occurred.';
}
