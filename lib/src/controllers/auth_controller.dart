part of 'controllers.dart';

typedef IdentityBuilder = String Function(String uid);

class AuthController<T extends Authenticator> extends Cubit<AuthResponse<T>> {
  final AuthMessages _msg;
  final AuthHandler authHandler;
  final BackupHandler<T> dataHandler;

  AuthController.fromHandler({
    required this.authHandler,
    required this.dataHandler,
    AuthMessages? messages,
  })  : _msg = messages ?? const AuthMessages(),
        super(AuthResponse.initial());

  AuthController.fromSource({
    AuthMessages? messages,
    AuthDataSource? auth,
    BackupDataSource<T>? backup,
    ConnectivityProvider? connectivity,
  })  : _msg = messages ?? const AuthMessages(),
        authHandler = AuthHandlerImpl.fromSource(auth ?? AuthDataSourceImpl()),
        dataHandler = BackupHandlerImpl<T>(
          source: backup,
          connectivity: connectivity,
        ),
        super(AuthResponse.initial());

  String get uid => user?.uid ?? "uid";

  User? get user => FirebaseAuth.instance.currentUser;

  Future isLoggedIn([AuthProvider? provider]) async {
    try {
      emit(AuthResponse.loading(provider, _msg.loading));
      final signedIn = await authHandler.isSignIn(provider);
      if (signedIn) {
        emit(AuthResponse.authenticated(state.data, _msg.signIn));
      } else {
        emit(AuthResponse.unauthenticated(_msg.signOut));
      }
    } catch (_) {
      emit(AuthResponse.failure(_msg.failure ?? _));
    }
  }

  Future signInByApple([Authenticator? authenticator]) async {
    emit(AuthResponse.loading(AuthProvider.apple, _msg.loading));
    try {
      final response = await authHandler.signInWithApple();
      final result = response.data;
      if (result != null && result.credential != null) {
        final finalResponse = await authHandler.signUpWithCredential(
          credential: result.credential!,
        );
        if (finalResponse.isSuccessful) {
          final currentData = finalResponse.data?.user;
          final user = (authenticator ?? Authenticator()).copy(
            id: currentData?.uid ?? result.id ?? uid,
            email: result.email,
            name: result.name,
            photo: result.photo,
            provider: AuthProvider.facebook.name,
          ) as T;
          await dataHandler.set(user);
          emit(AuthResponse.authenticated(user, _msg.signIn));
        } else {
          emit(AuthResponse.failure(_msg.failure ?? finalResponse.exception));
        }
      } else {
        emit(AuthResponse.failure(_msg.failure ?? response.exception));
      }
    } catch (_) {
      emit(AuthResponse.failure(_msg.failure ?? _));
    }
  }

  Future signInByBiometric() async {
    emit(AuthResponse.loading(AuthProvider.biometric, _msg.loading));
    final response = await authHandler.signInWithBiometric();
    try {
      if (response.isSuccessful) {
        final userResponse = await dataHandler.get();
        final user = userResponse.data;
        if (userResponse.isSuccessful && user is Authenticator) {
          final email = user.email;
          final password = user.password;
          final loginResponse = await authHandler.signInWithEmailNPassword(
            email: email ?? "example@gmail.com",
            password: password ?? "password",
          );
          if (loginResponse.isSuccessful) {
            emit(AuthResponse.authenticated(user, _msg.signIn));
          } else {
            emit(AuthResponse.failure(_msg.failure ?? loginResponse.exception));
          }
        } else {
          emit(AuthResponse.failure(_msg.failure ?? userResponse.exception));
        }
      } else {
        emit(AuthResponse.failure(_msg.failure ?? response.exception));
      }
    } catch (_) {
      emit(AuthResponse.failure(_msg.failure ?? _));
    }
  }

  Future signInByEmail(EmailAuthenticator authenticator) async {
    final email = authenticator.email;
    final password = authenticator.password;
    if (!Validator.isValidEmail(email)) {
      emit(AuthResponse.failure("Email isn't valid!"));
    } else if (!Validator.isValidPassword(password)) {
      emit(AuthResponse.failure("Password isn't valid!"));
    } else {
      emit(AuthResponse.loading(AuthProvider.email, _msg.loading));
      try {
        final response = await authHandler.signInWithEmailNPassword(
          email: email,
          password: password,
        );
        if (response.isSuccessful) {
          final result = response.data?.user;
          if (result != null) {
            final user = authenticator.copy(
              id: result.uid,
              email: result.email,
              name: result.displayName,
              phone: result.phoneNumber,
              photo: result.photoURL,
              provider: AuthProvider.email.name,
            ) as T;
            emit(AuthResponse.authenticated(user, _msg.signIn));
          } else {
            emit(AuthResponse.failure(_msg.failure ?? response.message));
          }
        } else {
          emit(AuthResponse.failure(_msg.failure ?? response.exception));
        }
      } catch (_) {
        emit(AuthResponse.failure(_msg.failure ?? _));
      }
    }
  }

  Future signInByFacebook([Authenticator? authenticator]) async {
    emit(AuthResponse.loading(AuthProvider.facebook, _msg.loading));
    try {
      final response = await authHandler.signInWithFacebook();
      final result = response.data;
      if (result != null && result.credential != null) {
        final finalResponse = await authHandler.signUpWithCredential(
          credential: result.credential!,
        );
        if (finalResponse.isSuccessful) {
          final currentData = finalResponse.data?.user;
          final user = (authenticator ?? Authenticator()).copy(
            id: currentData?.uid ?? result.id ?? uid,
            email: result.email,
            name: result.name,
            photo: result.photo,
            provider: AuthProvider.facebook.name,
          ) as T;
          await dataHandler.set(user);
          emit(AuthResponse.authenticated(user, _msg.signIn));
        } else {
          emit(AuthResponse.failure(_msg.failure ?? finalResponse.exception));
        }
      } else {
        emit(AuthResponse.failure(_msg.failure ?? response.exception));
      }
    } catch (_) {
      emit(AuthResponse.failure(_msg.failure ?? _));
    }
  }

  Future signInByGithub([Authenticator? authenticator]) async {
    emit(AuthResponse.loading(AuthProvider.github, _msg.loading));
    try {
      final response = await authHandler.signInWithGithub();
      final result = response.data;
      if (result != null && result.credential != null) {
        final finalResponse = await authHandler.signUpWithCredential(
          credential: result.credential!,
        );
        if (finalResponse.isSuccessful) {
          final currentData = finalResponse.data?.user;
          final user = (authenticator ?? Authenticator()).copy(
            id: currentData?.uid ?? result.id ?? uid,
            email: result.email,
            name: result.name,
            photo: result.photo,
            provider: AuthProvider.facebook.name,
          ) as T;
          await dataHandler.set(user);
          emit(AuthResponse.authenticated(user, _msg.signIn));
        } else {
          emit(AuthResponse.failure(_msg.failure ?? finalResponse.exception));
        }
      } else {
        emit(AuthResponse.failure(_msg.failure ?? response.exception));
      }
    } catch (_) {
      emit(AuthResponse.failure(_msg.failure ?? _));
    }
  }

  Future signInByGoogle([Authenticator? authenticator]) async {
    emit(AuthResponse.loading(AuthProvider.google, _msg.loading));
    try {
      final response = await authHandler.signInWithGoogle();
      final result = response.data;
      if (result != null && result.credential != null) {
        final finalResponse = await authHandler.signUpWithCredential(
          credential: result.credential!,
        );
        if (finalResponse.isSuccessful) {
          final currentData = finalResponse.data?.user;
          final user = (authenticator ?? Authenticator()).copy(
            id: currentData?.uid ?? result.id ?? uid,
            name: result.name,
            photo: result.photo,
            email: result.email,
            provider: AuthProvider.google.name,
          ) as T;
          await dataHandler.set(user);
          emit(AuthResponse.authenticated(user, _msg.signIn));
        } else {
          emit(AuthResponse.failure(_msg.failure ?? finalResponse.exception));
        }
      } else {
        emit(AuthResponse.failure(_msg.failure ?? response.exception));
      }
    } catch (_) {
      emit(AuthResponse.failure(_msg.failure ?? _));
    }
  }

  Future signInByUsername(UsernameAuthenticator authenticator) async {
    final username = authenticator.username;
    final password = authenticator.password;
    if (!Validator.isValidUsername(username)) {
      emit(AuthResponse.failure("Username isn't valid!"));
    } else if (!Validator.isValidPassword(password)) {
      emit(AuthResponse.failure("Password isn't valid!"));
    } else {
      emit(AuthResponse.loading(AuthProvider.username, _msg.loading));
      try {
        final response = await authHandler.signInWithUsernameNPassword(
          username: username,
          password: password,
        );
        if (response.isSuccessful) {
          final result = response.data?.user;
          if (result != null) {
            final user = authenticator.copy(
              id: result.uid,
              email: result.email,
              name: result.displayName,
              phone: result.phoneNumber,
              photo: result.photoURL,
              provider: AuthProvider.username.name,
            ) as T;
            emit(AuthResponse.authenticated(user, _msg.signIn));
          } else {
            emit(AuthResponse.failure(_msg.failure ?? response.exception));
          }
        } else {
          emit(AuthResponse.failure(_msg.failure ?? response.exception));
        }
      } catch (_) {
        emit(AuthResponse.failure(_msg.failure ?? _));
      }
    }
  }

  Future signUpByEmail(EmailAuthenticator authenticator) async {
    final email = authenticator.email;
    final password = authenticator.password;
    if (!Validator.isValidEmail(email)) {
      emit(AuthResponse.failure("Email isn't valid!"));
    } else if (!Validator.isValidPassword(password)) {
      emit(AuthResponse.failure("Password isn't valid!"));
    } else {
      emit(AuthResponse.loading(AuthProvider.email, _msg.loading));
      try {
        final response = await authHandler.signUpWithEmailNPassword(
          email: email.use,
          password: password.use,
        );
        if (response.isSuccessful) {
          final result = response.data?.user;
          if (result != null) {
            final user = authenticator.copy(
              id: result.uid,
              email: result.email,
              name: result.displayName,
              phone: result.phoneNumber,
              photo: result.photoURL,
              provider: AuthProvider.email.name,
            ) as T;
            await dataHandler.set(user);
            emit(AuthResponse.authenticated(user, _msg.signUp));
          } else {
            emit(AuthResponse.failure(_msg.failure ?? response.exception));
          }
        } else {
          emit(AuthResponse.failure(_msg.failure ?? response.exception));
        }
      } catch (_) {
        emit(AuthResponse.failure(_msg.failure ?? _));
      }
    }
  }

  Future signUpByUsername(UsernameAuthenticator authenticator) async {
    final username = authenticator.username;
    final password = authenticator.password;
    if (!Validator.isValidUsername(username)) {
      emit(AuthResponse.failure("Username isn't valid!"));
    } else if (!Validator.isValidPassword(password)) {
      emit(AuthResponse.failure("Password isn't valid!"));
    } else {
      emit(AuthResponse.loading(AuthProvider.email, _msg.loading));
      try {
        final response = await authHandler.signUpWithUsernameNPassword(
          username: username.use,
          password: password.use,
        );
        if (response.isSuccessful) {
          final result = response.data?.user;
          if (result != null) {
            final user = authenticator.copy(
              id: result.uid,
              email: result.email,
              name: result.displayName,
              phone: result.phoneNumber,
              photo: result.photoURL,
              provider: AuthProvider.email.name,
            ) as T;
            await dataHandler.set(user);
            emit(AuthResponse.authenticated(user, _msg.signUp));
          } else {
            emit(AuthResponse.failure(_msg.failure ?? response.exception));
          }
        } else {
          emit(AuthResponse.failure(_msg.failure ?? response.exception));
        }
      } catch (_) {
        emit(AuthResponse.failure(_msg.failure ?? _));
      }
    }
  }

  Future signOut([AuthProvider? provider]) async {
    emit(AuthResponse.loading(provider, _msg.loading));
    try {
      final response = await authHandler.signOut(provider);
      if (response.isSuccessful) {
        await dataHandler.clear();
        emit(AuthResponse.unauthenticated(_msg.signOut));
      } else {
        emit(AuthResponse.failure(_msg.failure ?? response.exception));
      }
    } catch (_) {
      emit(AuthResponse.failure(_msg.failure ?? _));
    }
  }
}

class AuthMessages {
  final String? loading;
  final String? failure;

  final String? signIn;
  final String? signOut;
  final String? signUp;

  const AuthMessages({
    this.loading,
    this.signIn,
    this.signOut,
    this.failure,
    this.signUp,
  });
}
