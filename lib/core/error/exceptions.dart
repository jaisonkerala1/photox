class AppException implements Exception {
  final String message;
  final int? statusCode;

  AppException({required this.message, this.statusCode});

  @override
  String toString() => message;
}

class ServerException extends AppException {
  ServerException({required super.message, super.statusCode});
}

class NetworkException extends AppException {
  NetworkException({required super.message});
}

class CacheException extends AppException {
  CacheException({required super.message});
}

class UnauthorizedException extends AppException {
  UnauthorizedException({required super.message});
}

class ForbiddenException extends AppException {
  ForbiddenException({required super.message});
}

class NotFoundException extends AppException {
  NotFoundException({required super.message});
}

class ValidationException extends AppException {
  final Map<String, List<String>>? errors;
  
  ValidationException({required super.message, this.errors});
}

class RateLimitException extends AppException {
  final Duration? retryAfter;
  
  RateLimitException({required super.message, this.retryAfter});
}

class RequestCancelledException extends AppException {
  RequestCancelledException({required super.message});
}

class ProcessingException extends AppException {
  ProcessingException({required super.message});
}

class SubscriptionRequiredException extends AppException {
  SubscriptionRequiredException({String? message}) 
    : super(message: message ?? 'This feature requires a PRO subscription.');
}

class InsufficientCreditsException extends AppException {
  final int requiredCredits;
  final int availableCredits;
  
  InsufficientCreditsException({
    required this.requiredCredits,
    required this.availableCredits,
  }) : super(
    message: 'You need $requiredCredits credits but only have $availableCredits.',
  );
}


