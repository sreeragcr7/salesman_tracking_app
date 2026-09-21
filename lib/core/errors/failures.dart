import 'package:equatable/equatable.dart';

abstract class TFailure extends Equatable {
  const TFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

final class ServerFailure extends TFailure {
  const ServerFailure(super.message);
}

final class NetworkFailure extends TFailure {
  const NetworkFailure(super.message);
}

final class AuthFailure extends TFailure {
  const AuthFailure(super.message);
}

final class CacheFailure extends TFailure {
  const CacheFailure(super.message);
}
