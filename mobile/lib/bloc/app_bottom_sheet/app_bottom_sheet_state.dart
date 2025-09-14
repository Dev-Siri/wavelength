import "package:flutter/foundation.dart";

@immutable
sealed class AppBottomSheetState {}

class AppBottomSheetOpenState extends AppBottomSheetState {}

class AppBottomSheetClosedState extends AppBottomSheetState {}
