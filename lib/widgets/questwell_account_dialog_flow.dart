import 'package:flutter/material.dart';

/// Owns only the dialogs belonging to one account's asynchronous operation.
class QuestwellAccountDialogFlow {
  QuestwellAccountDialogFlow({
    required bool Function() isCurrent,
    required Listenable accountChanges,
  })  : _isCurrent = isCurrent,
        _accountChanges = accountChanges {
    _accountChanges.addListener(_checkAccount);
  }

  final bool Function() _isCurrent;
  final Listenable _accountChanges;
  final _routes = <DialogRoute<Object?>>[];
  bool _cancelled = false;

  bool get active {
    if (!_cancelled && !_isCurrent()) cancel();
    return !_cancelled;
  }

  void _checkAccount() {
    if (!_isCurrent()) cancel();
  }

  void cancel() {
    if (_cancelled) return;
    _cancelled = true;
    _accountChanges.removeListener(_checkAccount);
    final routes = _routes.reversed.toList();
    // Account notifications and disposal can occur while Navigator is locked.
    // Invalidate actions now, then remove only our exact routes after the frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final route in routes) {
        final navigator = route.navigator;
        if (navigator != null && route.isActive) navigator.removeRoute(route);
      }
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  static QuestwellAccountDialogFlow? of(BuildContext context) =>
      context.getInheritedWidgetOfExactType<_AccountDialogScope>()?.flow;

  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    QuestwellAccountDialogFlow? flow,
  }) {
    final owner = flow ?? of(context);
    if (owner == null) return showDialog<T>(context: context, builder: builder);
    return owner._show<T>(context, builder);
  }

  Future<T?> _show<T>(BuildContext context, WidgetBuilder builder) async {
    if (!active || !context.mounted) return null;
    final route = DialogRoute<T>(
      context: context,
      builder: (_) => _AccountDialogScope(
        flow: this,
        child: Builder(
            builder: (context) =>
                active ? builder(context) : const SizedBox.shrink()),
      ),
    );
    _routes.add(route);
    try {
      return await Navigator.of(context, rootNavigator: true).push(route);
    } finally {
      _routes.remove(route);
    }
  }

  static void pop<T>(BuildContext context, [T? result]) {
    if (!context.mounted) return;
    final flow = of(context);
    final route = ModalRoute.of(context);
    if (flow != null &&
        (!flow.active ||
            !flow._routes.contains(route) ||
            route?.isCurrent != true)) {
      return;
    }
    Navigator.pop(context, result);
  }
}

class _AccountDialogScope extends InheritedWidget {
  const _AccountDialogScope({required this.flow, required super.child});
  final QuestwellAccountDialogFlow flow;
  @override
  bool updateShouldNotify(_AccountDialogScope oldWidget) =>
      flow != oldWidget.flow;
}
