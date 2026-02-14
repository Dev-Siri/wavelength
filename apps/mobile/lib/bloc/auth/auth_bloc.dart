import "dart:async";

import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_secure_storage/flutter_secure_storage.dart";
import "package:google_sign_in/google_sign_in.dart";
import "package:hive_flutter/hive_flutter.dart";
import "package:wavelength/api/models/api_response.dart";
import "package:wavelength/api/models/auth_user.dart";
import "package:wavelength/api/repositories/auth_repo.dart";
import "package:wavelength/api/repositories/diagnostics_repo.dart";
import "package:wavelength/bloc/auth/auth_event.dart";
import "package:wavelength/bloc/auth/auth_state.dart";
import "package:wavelength/constants.dart";

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  static const userKey = "user_data";
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
    final authToken = await securedStorage.read(key: authTokenKey);
    final authBox = await Hive.openBox(hiveAuthhKey);
    final userProfile = authBox.get(userKey);

    if (authToken != null && userProfile != null) {
      return emit(AuthStateAuthorized(user: userProfile, authToken: authToken));
    }

    emit(AuthStateUnauthorized());
  }

  Future<void> _login(AuthLoginUserEvent event, Emitter<AuthState> emit) async {
    try {
      final user = await googleSignin.signIn();

      if (user == null || user.serverAuthCode == null) {
        return emit(AuthStateUnauthorized());
      }

      final authCodeResponse = await AuthRepo.mobileOAuth(
        serverAuthCode: user.serverAuthCode ?? "",
      );

      if (authCodeResponse is! ApiResponseSuccess<String>) {
        return emit(AuthStateUnauthorized());
      }

      final authTokenResponse = await AuthRepo.consumeAuthToken(
        authCode: authCodeResponse.data,
      );

      if (authTokenResponse is! ApiResponseSuccess<String>) {
        return emit(AuthStateUnauthorized());
      }

      final userProfileResponse = await AuthRepo.fetchUserProfile(
        authToken: authTokenResponse.data,
      );

      if (userProfileResponse is! ApiResponseSuccess<AuthUser>) {
        return emit(AuthStateUnauthorized());
      }

      final authBox = await Hive.openBox(hiveAuthhKey);

      await securedStorage.write(
        key: authTokenKey,
        value: authTokenResponse.data,
      );
      await authBox.put(userKey, userProfileResponse.data);

      emit(
        AuthStateAuthorized(
          user: userProfileResponse.data,
          authToken: authTokenResponse.data,
        ),
      );
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
