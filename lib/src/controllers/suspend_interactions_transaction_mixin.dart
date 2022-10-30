import 'dart:async';

import 'package:get/get.dart';

typedef UISuspendedTransaction<T> = FutureOr<T> Function();

/// A mixin to suspend interactions with UI.
mixin SuspendInteractionsTransaction on GetxController {
  bool _isLoading = false;

  /// Suspend interactions with UI.
  void suspendUIInteractions();

  /// Resume interactions with UI.
  void resumeUIInteractions();

  /// Execute a transaction that suspends interactions with UI.
  FutureOr<T> suspendInteractionsTransaction<T>({required UISuspendedTransaction<T> transaction}) async {
    // Suspend interactions with UI.
    if (!_isLoading) {
      suspendUIInteractions();
      _isLoading = true;
      update();
    }

    // Execute the transaction.
    final result = await transaction();

    // Resume interactions with UI.
    if (_isLoading) {
      resumeUIInteractions();
      _isLoading = false;
      update();
    }

    return result;
  }
}
