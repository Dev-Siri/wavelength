import "dart:async";
import "dart:convert";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_secure_storage/flutter_secure_storage.dart";
import "package:google_sign_in/google_sign_in.dart";
import "package:wavelength/bloc/auth/auth_event.dart";
import "package:wavelength/bloc/auth/auth_state.dart";
import "package:wavelength/utils/map_to_google_sign_in_account.dart";

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  static const userKey = "user";

  final FlutterSecureStorage securedStorage;
  final GoogleSignIn googleSignin;

  AuthBloc(this.googleSignin, this.securedStorage) : super(AuthStateInitial()) {
    on<AuthLocalUserFetchEvent>(_fetchLocalUser);
    on<AuthLoginUserEvent>(_login);
  }

  Future<void> _fetchLocalUser(
    AuthLocalUserFetchEvent event,
    Emitter<AuthState> emit,
  ) async {
    final userString = await securedStorage.read(key: userKey);

    if (userString != null) {
      final user = await stringMapToGoogleSignInAccount(userString);
      return emit(AuthStateAuthorized(user: user));
    }

    emit(AuthStateUnauthorized());
  }

  Future<void> _login(AuthLoginUserEvent event, Emitter<AuthState> emit) async {
    try {
      final user = await googleSignin.signIn();

      if (user == null) {
        return emit(AuthStateUnauthorized());
      }

      final localUser = googleSignInAccountToLocalAccount(user);
      final userMap = googleSignInAccountToMap(user);
      final stringifiedUserMap = jsonEncode(userMap);

      await securedStorage.write(key: userKey, value: stringifiedUserMap);

      emit(AuthStateAuthorized(user: localUser));
    } catch (err) {
      emit(AuthStateUnauthorized());
    }
  }
}
