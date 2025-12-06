import 'package:flutter/material.dart';

class NavigationService {
  static NavigationService? _instance;
  static NavigationService get instance => _instance ??= NavigationService._internal();
  NavigationService._internal();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<T?> push<T extends Object?>(Widget screen) {
    return navigatorKey.currentState!.push<T>(
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  Future<T?> pushReplacement<T extends Object?, TO extends Object?>(
    Widget screen,
  ) {
    return navigatorKey.currentState!.pushReplacement<T, TO>(
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  void pop<T extends Object?>([T? result]) {
    navigatorKey.currentState!.pop(result);
  }
}