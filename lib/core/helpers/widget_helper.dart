// Author: Green Onyeji (https://github.com/ositano/) (https://www.linkedin.com/in/green-onyeji-11608a97/)
// lib/core/helpers/widget_helper.dart
//
// IWidgetHelper matches the call signatures used in ViewListenerWidget:
//   showToast(context, subTitleLabel)    — info/success
//   showToastError(message)              — error (no context needed for
//                                          libraries like toastification)
import 'package:flutter/material.dart';

abstract class IWidgetHelper {
  void showToast({
    BuildContext? context,
    String?       titleLabel,
    String?       subTitleLabel,
  });

  void showToastError({
    BuildContext? context,
    required String message,
  });

  void showToastSuccess({
    BuildContext? context,
    required String message,
  });
}

class WidgetHelperImpl implements IWidgetHelper {
  @override
  void showToast({
    BuildContext? context,
    String?       titleLabel,
    String?       subTitleLabel,
  }) {
    final ctx = context;
    if (ctx == null) return;
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text(subTitleLabel ?? titleLabel ?? ''),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void showToastError({BuildContext? context, required String message}) {
    final ctx = context;
    if (ctx == null) return;
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void showToastSuccess({BuildContext? context, required String message}) {
    final ctx = context;
    if (ctx == null) return;
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
