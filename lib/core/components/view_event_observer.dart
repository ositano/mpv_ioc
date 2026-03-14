// Author: Green Onyeji (https://github.com/ositano/) (https://www.linkedin.com/in/green-onyeji-11608a97/)
// lib/core/components/view_event_observer.dart
//
// ─────────────────────────────────────────────────────────────────
//  Generic dual-stream listener widget.
//
//  Listens to up to two typed streams and fires callbacks when
//  events arrive — only if the widget is still mounted.
//
//  Used by ViewListenerWidget to split navigation events and
//  message events into two separate, type-safe callbacks.
//
//  Generic parameters:
//    T — primary stream type   (e.g. MessageEvent)
//    R — secondary stream type (e.g. NavEvent)
// ─────────────────────────────────────────────────────────────────

import 'dart:async';
import 'package:flutter/material.dart';

class ViewEventObserver<T, R> extends StatefulWidget {
  final Stream<T>    stream;
  final Function(T)  onEvent;

  final Stream<R>?   secondStream;
  final Function(R)? onSecondEvent;

  final Widget child;

  const ViewEventObserver({
    super.key,
    required this.stream,
    required this.onEvent,
    this.secondStream,
    this.onSecondEvent,
    required this.child,
  });

  @override
  State<ViewEventObserver<T, R>> createState() =>
      _ViewEventObserverState<T, R>();
}

class _ViewEventObserverState<T, R>
    extends State<ViewEventObserver<T, R>> {
  StreamSubscription<T>? _subscription;
  StreamSubscription<R>? _secondSubscription;

  @override
  void initState() {
    super.initState();
    _initListeners();
  }

  void _initListeners() {
    _subscription = widget.stream.listen((event) {
      if (mounted) widget.onEvent(event);
    });

    if (widget.secondStream != null && widget.onSecondEvent != null) {
      _secondSubscription = widget.secondStream!.listen((event) {
        if (mounted) widget.onSecondEvent!(event);
      });
    }
  }

  @override
  void dispose() {
    // Critical: cancel both subscriptions to prevent memory leaks and
    // "setState called on deactivated widget" errors.
    _subscription?.cancel();
    _secondSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
