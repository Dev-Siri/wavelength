import "package:flutter/foundation.dart";

@immutable
sealed class AppBottomSheetState {
  const AppBottomSheetState();
}

class AppBottomSheetOpenState extends AppBottomSheetState {
  const AppBottomSheetOpenState();
}

class AppBottomSheetClosedState extends AppBottomSheetState {
  const AppBottomSheetClosedState();
}
