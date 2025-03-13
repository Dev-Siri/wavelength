import "package:flutter/foundation.dart";

@immutable
abstract class LibraryState {}

class LibraryStateDefault extends LibraryState {}

class LibraryStateLoading extends LibraryState {}

class LibraryStateLoadError extends LibraryState {}

class LibraryStateLoadSuccess extends LibraryState {}
