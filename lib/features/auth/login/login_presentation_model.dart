import 'package:dartz/dartz.dart';
import 'package:flutter_demo/core/domain/model/user.dart';
import 'package:flutter_demo/core/utils/bloc_extensions.dart';
import 'package:flutter_demo/features/auth/domain/model/log_in_failure.dart';
import 'package:flutter_demo/features/auth/login/login_credentials.dart';
import 'package:flutter_demo/features/auth/login/login_initial_params.dart';

/// Model used by presenter, contains fields that are relevant to presenters and implements ViewModel to expose data to view (page)
class LoginPresentationModel implements LoginViewModel {


  /// Creates the initial state
  LoginPresentationModel.initial(
    // ignore: avoid_unused_constructor_parameters
    LoginInitialParams initialParams,
  ) : credentials = const LoginCredentials(),
      loginResult = const FutureResult<Either<LogInFailure, User>>.empty();

  /// Used for the copyWith method
  LoginPresentationModel._(this.credentials, this.loginResult);

  final LoginCredentials credentials;
  final FutureResult<Either<LogInFailure, User>> loginResult;

  String get username => credentials.username;

  String get password => credentials.password;

  @override
  bool get isLoading => loginResult.isPending();

  @override
  bool get isLoginEnabled => !credentials.isUsernameOrPasswordEmpty();

  LoginPresentationModel copyWith({String? username, String? password, FutureResult<Either<LogInFailure, User>>? loginResult,}) {
    return LoginPresentationModel._(
      credentials.copyWith(
        username,
        password,
      ),
      loginResult ?? this.loginResult,
    );
  }


}

/// Interface to expose fields used by the view (page).
abstract class LoginViewModel {
  bool get isLoginEnabled;
  bool get isLoading;
}
