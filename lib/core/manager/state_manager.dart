// Author: Green Onyeji (https://github.com/ositano/) (https://www.linkedin.com/in/green-onyeji-11608a97/)
// lib/core/manager/state_manager.dart
//
// ─────────────────────────────────────────────────────────────────
//  Base class for every Manager.
//
//  Responsibilities:
//    • Form field registry with grouping, typing, and validation
//    • requestStatus ValueNotifier
//    • Navigation helpers (emit NavEvents via NavigationService stream)
//    • Message helpers (emit MessageEvents via NavigationService stream)
//
//  There is NO BuildContext here. ViewListenerWidget catches the
//  streams and executes navigation/toasts in the widget tree.
// ─────────────────────────────────────────────────────────────────

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

import '../data/events/message_event.dart';
import '../data/events/nav_event.dart';
import '../enums/enums.dart';
import '../utils/navigation_service.dart';

// ── Form field wrapper ─────────────────────────────────────────────

class FormFieldItem<T> {
  final ValueNotifier<T> value;
  final T? initialValue;
  final String? Function(dynamic) validator;
  final String fieldName;
  bool touched;

  FormFieldItem({
    required this.initialValue,
    required this.fieldName,
    required this.validator,
  })  : value    = ValueNotifier<T>(initialValue as T),
        touched  = false;
}

// ── StateManager ───────────────────────────────────────────────────

class StateManager extends ChangeNotifier {
  final Map<String, Map<String, FormFieldItem<dynamic>>> _groups = {};
  final Map<String, ValueNotifier<bool>> _groupValid = {};

  ValueNotifier<RequestStatus> requestStatus =
      ValueNotifier(RequestStatus.initial);

  final NavigationService _navService = GetIt.I<NavigationService>();

  Stream<NavEvent>     get navigationStream => _navService.navigationStream;
  Stream<MessageEvent> get messageStream    => _navService.messageStream;

  // ── Field management ───────────────────────────────────────────

  void addField<T>({
    String groupId = 'default',
    required String fieldName,
    required T initialValue,
    required String? Function(T?) validator,
  }) {
    _groups.putIfAbsent(groupId, () => {});
    _groupValid.putIfAbsent(groupId, () => ValueNotifier<bool>(false));
    _groups[groupId]![fieldName] = FormFieldItem<T>(
      fieldName:     fieldName,
      initialValue:  initialValue,
      validator:     (dynamic v) => validator(v as T?),
    );
    _validateGroup(groupId);
  }

  void updateField<T>(String fieldName, T value,
      {String groupId = 'default'}) {
    final field = _groups[groupId]?[fieldName];
    if (field is FormFieldItem<T>) {
      field.value.value = value;
      field.touched     = true;
      _validateGroup(groupId);
      field.value.notifyListeners();
    }
  }

  void markAllAsTouched({String groupId = 'default'}) {
    _groups[groupId]?.values.forEach((f) {
      f.touched = true;
      f.value.notifyListeners();
    });
    _validateGroup(groupId);
    notifyListeners();
  }

  ValueListenable<bool> isValid({String groupId = 'default'}) =>
      _groupValid[groupId] ?? ValueNotifier(false);

  ValueListenable<T> getFieldListenable<T>(String fieldName,
      {String groupId = 'default'}) {
    final field = _groups[groupId]?[fieldName];
    if (field is FormFieldItem<T>) return field.value;
    throw Exception('Field "$fieldName" in group "$groupId" not found');
  }

  T getFieldValue<T>(String fieldName, {String groupId = 'default'}) {
    final field = _groups[groupId]?[fieldName];
    if (field is FormFieldItem<T>) return field.value.value;
    throw Exception('Field "$fieldName" in group "$groupId" not found');
  }

  String? getFieldError(String fieldName, {String groupId = 'default'}) {
    final field = _groups[groupId]?[fieldName];
    if (field == null || !field.touched) return null;
    return field.validator(field.value.value);
  }

  /// Checks if a specific field has been interacted with (touched)
  bool isFieldTouched(String fieldName, {String groupId = 'default'}) {
    final field = _groups[groupId]?[fieldName];
    return field?.touched ?? false;
  }

  void Function() touchField(String fieldName,
      {String groupId = 'default'}) {
    return () {
      final field = _groups[groupId]?[fieldName];
      if (field != null && !field.touched) {
        field.touched = true;
        field.value.notifyListeners();
        _validateGroup(groupId);
      }
    };
  }

  void resetForm({String groupId = 'default'}) {
    _groups[groupId]?.values.forEach((f) {
      f.value.value = f.initialValue;
      f.touched     = false;
      f.value.notifyListeners();
    });
    _validateGroup(groupId);
  }

  void _validateGroup(String groupId) {
    final group = _groups[groupId];
    if (group == null) return;
    final allValid =
        group.values.every((f) => f.validator(f.value.value) == null);
    _groupValid[groupId]?.value = allValid;
  }

  // ── Navigation helpers ─────────────────────────────────────────

  void showUiMessage(String message,
      {MessageType messageType = MessageType.error}) =>
      _navService.showMessage(
          MessageEvent(message, messageType: messageType));

  void navigateTo(
    String name, {
    Map<String, String> pathParameters  = const {},
    Map<String, String> queryParameters = const {},
    Object?    extra,
    String?    fragment,
    RouteType  routeType  = RouteType.named,
    RouteLevel routeLevel = RouteLevel.normal,
  }) =>
      _navService.navigateTo(
        name,
        pathParameters:  pathParameters,
        queryParameters: queryParameters,
        extra:           extra,
        fragment:        fragment,
        routeType:       routeType,
        routeLevel:      routeLevel,
      );

  void onBackPressed() => navigateTo('/back');

  void onBackPressedWithData(dynamic data) =>
      navigateTo('/back', extra: data);

  // ── Dispose ────────────────────────────────────────────────────

  @override
  void dispose() {
    for (final group in _groups.values) {
      for (final field in group.values) {
        field.value.dispose();
      }
    }
    for (final n in _groupValid.values) {
      n.dispose();
    }
    requestStatus.dispose();
    super.dispose();
  }
}
