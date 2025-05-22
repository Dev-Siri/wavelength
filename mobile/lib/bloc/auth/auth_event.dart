import "package:flutter/foundation.dart";

@immutable
abstract class AuthEvent {}

class AuthLocalUserFetchEvent extends AuthEvent {}

class AuthLoginUserEvent extends AuthEvent {}

class AuthLogoutUserEvent extends AuthEvent {}
