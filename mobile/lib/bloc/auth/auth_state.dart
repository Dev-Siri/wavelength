import "package:flutter/foundation.dart";
import "package:wavelength/api/models/local_google_sign_in_account.dart";

@immutable
sealed class AuthState {}

class AuthStateInitial extends AuthState {}

class AuthStateUnauthorized extends AuthState {}

class AuthStateAuthorized extends AuthState {
  final LocalGoogleSignInAccount user;
  final String authToken;

  AuthStateAuthorized({required this.user, required this.authToken});
}
