import 'package:fpdart/fpdart.dart';
import 'package:salesman_tracking_app/core/errors/failures.dart';
import 'package:salesman_tracking_app/core/usecase/usecase.dart';
import 'package:salesman_tracking_app/domain/entities/user.dart';
import 'package:salesman_tracking_app/domain/repositories/auth_repository.dart';

class Login implements TUsecase<User, LoginParams> {
  final AuthRepository repository;

  Login(this.repository);

  @override
  Future<Either<TFailure, User>> call(LoginParams params) {
    return repository.login(email: params.email, password: params.password);
  }
}

class LoginParams {
  final String email;
  final String password;

  const LoginParams({required this.email, required this.password});
}
