import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  
  const Failure({required this.message});
  
  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  final int? statusCode;
  
  const ServerFailure({required super.message, this.statusCode});
  
  @override
  List<Object?> get props => [message, statusCode];
}

class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'No internet connection'});
}

class CacheFailure extends Failure {
  const CacheFailure({super.message = 'Cache error occurred'});
}

class AuthFailure extends Failure {
  const AuthFailure({required super.message});
}

class ValidationFailure extends Failure {
  final Map<String, List<String>>? errors;
  
  const ValidationFailure({required super.message, this.errors});
  
  @override
  List<Object?> get props => [message, errors];
}

class ProcessingFailure extends Failure {
  const ProcessingFailure({required super.message});
}

class SubscriptionFailure extends Failure {
  const SubscriptionFailure({
    super.message = 'This feature requires a PRO subscription',
  });
}

class CreditsFailure extends Failure {
  final int requiredCredits;
  final int availableCredits;
  
  const CreditsFailure({
    required this.requiredCredits,
    required this.availableCredits,
    super.message = 'Insufficient credits',
  });
  
  @override
  List<Object?> get props => [message, requiredCredits, availableCredits];
}

class UnknownFailure extends Failure {
  const UnknownFailure({super.message = 'An unexpected error occurred'});
}





