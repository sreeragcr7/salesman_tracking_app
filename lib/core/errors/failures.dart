abstract class TFailure {
  const TFailure(this.message);

  final String message;
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
