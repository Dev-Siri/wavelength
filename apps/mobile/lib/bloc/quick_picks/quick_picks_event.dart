import "package:flutter/foundation.dart";

@immutable
sealed class QuickPicksEvent {}

class QuickPicksFetchEvent extends QuickPicksEvent {
  final String locale;

  QuickPicksFetchEvent({required this.locale});
}
