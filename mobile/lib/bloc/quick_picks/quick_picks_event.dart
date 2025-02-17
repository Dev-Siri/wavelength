import "package:flutter/foundation.dart";

@immutable
abstract class QuickPicksEvent {}

class QuickPicksFetchEvent extends QuickPicksEvent {
  final String locale;

  QuickPicksFetchEvent({required this.locale});
}
