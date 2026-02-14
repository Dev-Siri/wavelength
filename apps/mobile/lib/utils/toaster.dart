import "package:flutter/material.dart";

enum ToastType { success, error, info }

const toastTypeToColorMap = {
  ToastType.success: Colors.green,
  ToastType.error: Colors.red,
  ToastType.info: Colors.blue,
};

mixin Toaster {
  void showToast(BuildContext context, String message, ToastType type) {
    final messenger = ScaffoldMessenger.of(context);

    messenger.showSnackBar(
      SnackBar(
        backgroundColor: toastTypeToColorMap[type],
        content: Text(message, style: const TextStyle(color: Colors.white)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
