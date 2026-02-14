import "package:flutter/foundation.dart";
import "package:wavelength/api/models/auth_user.dart";

@immutable
sealed class AuthState {}

class AuthStateInitial extends AuthState {}

class AuthStateUnauthorized extends AuthState {}

class AuthStateAuthorized extends AuthState {
  final AuthUser user;
  final String authToken;

  AuthStateAuthorized({required this.user, required this.authToken});
}
