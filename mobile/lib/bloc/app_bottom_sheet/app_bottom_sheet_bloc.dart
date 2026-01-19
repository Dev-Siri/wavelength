import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:go_router/go_router.dart";
import "package:wavelength/bloc/app_bottom_sheet/app_bottom_sheet_event.dart";
import "package:wavelength/bloc/app_bottom_sheet/app_bottom_sheet_state.dart";

class AppBottomSheetBloc
    extends Bloc<AppBottomSheetEvent, AppBottomSheetState> {
  AppBottomSheetBloc() : super(const AppBottomSheetClosedState()) {
    on<AppBottomSheetOpenEvent>(_openAppModalSheet);
    on<AppBottomSheetCloseEvent>(_closeAppModalSheet);
  }

  Future<void> _openAppModalSheet(
    AppBottomSheetOpenEvent event,
    Emitter<AppBottomSheetState> emit,
  ) async {
    emit(const AppBottomSheetOpenState());

    // Reinventing the wheel is my passion.
    await showModalBottomSheet(
      context: event.context,
      builder: event.builder,
      backgroundColor: event.backgroundColor,
      barrierLabel: event.barrierLabel,
      elevation: event.elevation,
      shape: event.shape,
      clipBehavior: event.clipBehavior,
      constraints: event.constraints,
      barrierColor: event.barrierColor,
      isScrollControlled: event.isScrollControlled,
      useRootNavigator: event.useRootNavigator,
      isDismissible: event.isDismissible,
      enableDrag: event.enableDrag,
      showDragHandle: event.showDragHandle,
      useSafeArea: event.useSafeArea,
      routeSettings: event.routeSettings,
      transitionAnimationController: event.transitionAnimationController,
      anchorPoint: event.anchorPoint,
      sheetAnimationStyle: event.sheetAnimationStyle,
      requestFocus: event.requestFocus,
    );

    emit(const AppBottomSheetClosedState());
  }

  Future<void> _closeAppModalSheet(
    AppBottomSheetCloseEvent event,
    Emitter<AppBottomSheetState> emit,
  ) async {
    GoRouter.of(event.context).pop();

    emit(const AppBottomSheetClosedState());
  }
}
