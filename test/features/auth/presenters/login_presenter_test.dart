import 'package:dartz/dartz.dart';
import 'package:flutter_demo/core/domain/model/displayable_failure.dart';
import 'package:flutter_demo/core/domain/model/user.dart';
import 'package:flutter_demo/core/utils/either_extensions.dart';
import 'package:flutter_demo/features/auth/domain/model/log_in_failure.dart';
import 'package:flutter_demo/features/auth/domain/use_cases/log_in_use_case.dart';
import 'package:flutter_demo/features/auth/login/login_initial_params.dart';
import 'package:flutter_demo/features/auth/login/login_presentation_model.dart';
import 'package:flutter_demo/features/auth/login/login_presenter.dart';
import 'package:flutter_demo/utils/app_labels.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../mocks/auth_mock_definitions.dart';

void main() {
  late LoginPresentationModel model;
  late LoginPresenter presenter;
  late MockLoginNavigator navigator;
  late LogInUseCase logInUseCase;

  const username = 'test';
  const password = 'pass';

  void WhenLogInUseCaseCalledWithUsernameAndPasswordThenReturn(
    Future<Either<LogInFailure, User>> valueToReturn,
  ) {
    when(() => logInUseCase.execute(username: username, password: password))
        .thenAnswer((_) => valueToReturn);
  }

  void giveNavigatorAbilityToShowSuccessAlert() {
    when(
      () => navigator.showAlert(
        title: AppLabels.titleOfSuccessfulLoginAlert,
        message: AppLabels.messageOfSuccessfulLoginAlert,
      ),
    ).thenAnswer((_) => Future.value());
  }

  void giveNavigatorAbilityToShowError(
    DisplayableFailure displayableLogInFailure,
  ) {
    when(() => navigator.showError(displayableLogInFailure))
        .thenAnswer((_) => Future.value());
  }

  void verifyNavigatorShowErrorAlert(DisplayableFailure displayableLogInFailure) {
    verify(
          () => navigator.showError(displayableLogInFailure),
    );
  }

  void verifyNavigatorShowSuccessfulLoginAlert() {
    verify(
          () => navigator.showAlert(
        title: AppLabels.titleOfSuccessfulLoginAlert,
        message: AppLabels.messageOfSuccessfulLoginAlert,
      ),
    );
  }

  test(
    'sample test',
    () {
      expect(presenter, isNotNull); // TODO implement this
    },
  );

  group('Login Presenter', () {
    test('disable Login Button if username is empty', () {
      presenter.onUsernameChanged('');

      expect(
        presenter.state,
        predicate<LoginViewModel>((value) {
          expect(value.isLoginEnabled, isFalse);
          return true;
        }),
      );
    });
    test('disable Login Button if password is empty', () {
      presenter.onPasswordChanged('');

      expect(
        presenter.state,
        predicate<LoginViewModel>((value) {
          expect(value.isLoginEnabled, isFalse);
          return true;
        }),
      );
    });
    test(
        'enable Login Button if username and password are at least more than 1 character',
        () {
      presenter.onUsernameChanged('test');
      presenter.onPasswordChanged('pass');

      expect(
        presenter.state,
        predicate<LoginViewModel>((value) {
          expect(value.isLoginEnabled, isTrue);
          return true;
        }),
      );
    });
    test('show loading before calling UseCase with username and password',
        () async {
      presenter.onUsernameChanged(username);
      presenter.onPasswordChanged(password);

      giveNavigatorAbilityToShowSuccessAlert();

      WhenLogInUseCaseCalledWithUsernameAndPasswordThenReturn(Future.delayed(
        const Duration(milliseconds: 100),
            () => success(const User.anonymous()),
      ),);

      Future.delayed(const Duration(milliseconds: 50), () {
        expectLater(presenter.state.isLoading, isTrue);
      });

      await presenter.onLoginButtonPressed();
    });
    test('call UseCase with username and password', () async {
      presenter.onUsernameChanged(username);
      presenter.onPasswordChanged(password);

      WhenLogInUseCaseCalledWithUsernameAndPasswordThenReturn(
        Future.value(success(const User.anonymous())),
      );

      await presenter.onLoginButtonPressed();

      verify(
        () => logInUseCase.execute(username: username, password: password),
      );
    });
    test('show a success dialog if the user logs in successfully', () async {
      presenter.onUsernameChanged(username);
      presenter.onPasswordChanged(password);

      WhenLogInUseCaseCalledWithUsernameAndPasswordThenReturn(
        Future.value(success<LogInFailure, User>(const User.anonymous())),
      );

      await presenter.onLoginButtonPressed();

      verifyNavigatorShowSuccessfulLoginAlert();
    });
    test('show an error dialog if login fails', () async {
      const logInFailure = LogInFailure.unknown('some problem');

      final displayableLogInFailure = logInFailure.displayableFailure();

      presenter.onUsernameChanged(username);
      presenter.onPasswordChanged(password);

      giveNavigatorAbilityToShowError(displayableLogInFailure);

      WhenLogInUseCaseCalledWithUsernameAndPasswordThenReturn(
        Future.value(failure<LogInFailure, User>(logInFailure)),
      );

      await presenter.onLoginButtonPressed();

      verifyNavigatorShowErrorAlert(displayableLogInFailure);
    });
  });

  setUp(() {
    model = LoginPresentationModel.initial(const LoginInitialParams());
    navigator = MockLoginNavigator();
    logInUseCase = MockLogInUseCase();
    presenter = LoginPresenter(
      model,
      navigator,
      logInUseCase,
    );

    giveNavigatorAbilityToShowSuccessAlert();
  });
}
