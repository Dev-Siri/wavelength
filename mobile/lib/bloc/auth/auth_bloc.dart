import "dart:async";
import "dart:convert";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_secure_storage/flutter_secure_storage.dart";
import "package:google_sign_in/google_sign_in.dart";
import "package:wavelength/api/models/api_response.dart";
import "package:wavelength/api/models/auth_user.dart";
import "package:wavelength/api/repositories/auth_repo.dart";
import "package:wavelength/api/repositories/diagnostics_repo.dart";
import "package:wavelength/bloc/auth/auth_event.dart";
import "package:wavelength/bloc/auth/auth_state.dart";
import "package:wavelength/utils/map_to_google_sign_in_account.dart";

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  static const userKey = "user";
  static const authTokenKey = "user_auth_token";

  final FlutterSecureStorage securedStorage;
  final GoogleSignIn googleSignin;

  AuthBloc(this.googleSignin, this.securedStorage) : super(AuthStateInitial()) {
    on<AuthLocalUserFetchEvent>(_fetchLocalUser);
    on<AuthLoginUserEvent>(_login);
    on<AuthLogoutUserEvent>(_logout);
  }

  Future<void> _fetchLocalUser(
    AuthLocalUserFetchEvent event,
    Emitter<AuthState> emit,
  ) async {
    final userString = await securedStorage.read(key: userKey);
    final authToken = await securedStorage.read(key: authTokenKey);

    if (userString != null && authToken != null) {
      final user = await stringMapToGoogleSignInAccount(userString);
      return emit(AuthStateAuthorized(user: user, authToken: authToken));
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

      final authTokenResponse = await AuthRepo.createAuthToken(
        AuthUser(
          id: localUser.id,
          email: localUser.email,
          displayName: localUser.displayName ?? "",
          photoUrl: localUser.photoUrl ?? "",
        ),
      );

      if (authTokenResponse is ApiResponseError) {
        return emit(AuthStateUnauthorized());
      }

      final authToken = (authTokenResponse as ApiResponseSuccess<String>).data;

      final userMap = googleSignInAccountToMap(user);
      final stringifiedUserMap = jsonEncode(userMap);

      await securedStorage.write(key: userKey, value: stringifiedUserMap);
      await securedStorage.write(key: authTokenKey, value: authToken);

      emit(AuthStateAuthorized(user: localUser, authToken: authToken));
    } catch (err) {
      DiagnosticsRepo.reportError(
        error: err.toString(),
        source: "AuthBloc._login",
      );
      emit(AuthStateUnauthorized());
    }
  }

  Future<void> _logout(
    AuthLogoutUserEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await googleSignin.signOut();
      await securedStorage.delete(key: userKey);
      await securedStorage.delete(key: authTokenKey);
    } finally {
      emit(AuthStateUnauthorized());
    }
  }
}
