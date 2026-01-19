import "package:flutter/cupertino.dart";

@immutable
sealed class AppBottomSheetEvent {
  const AppBottomSheetEvent();
}

class AppBottomSheetOpenEvent extends AppBottomSheetEvent {
  final BuildContext context;
  final WidgetBuilder builder;
  final Color? backgroundColor;
  final String? barrierLabel;
  final double? elevation;
  final ShapeBorder? shape;
  final Clip? clipBehavior;
  final BoxConstraints? constraints;
  final Color? barrierColor;
  final bool isScrollControlled;
  final bool useRootNavigator;
  final bool isDismissible;
  final bool enableDrag;
  final bool? showDragHandle;
  final bool useSafeArea;
  final RouteSettings? routeSettings;
  final AnimationController? transitionAnimationController;
  final Offset? anchorPoint;
  final AnimationStyle? sheetAnimationStyle;
  final bool? requestFocus;

  const AppBottomSheetOpenEvent({
    required this.context,
    required this.builder,
    this.backgroundColor,
    this.barrierLabel,
    this.elevation,
    this.shape,
    this.clipBehavior,
    this.constraints,
    this.barrierColor,
    this.isScrollControlled = false,
    this.useRootNavigator = false,
    this.isDismissible = true,
    this.enableDrag = true,
    this.showDragHandle,
    this.useSafeArea = false,
    this.routeSettings,
    this.transitionAnimationController,
    this.anchorPoint,
    this.sheetAnimationStyle,
    this.requestFocus,
  });
}

class AppBottomSheetCloseEvent extends AppBottomSheetEvent {
  final BuildContext context;

  const AppBottomSheetCloseEvent({required this.context});
}
