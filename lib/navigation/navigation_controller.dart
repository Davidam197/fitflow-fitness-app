import 'package:flutter/material.dart';

class NavigationController {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static int _currentIndex = 0;
  static final ValueNotifier<int> currentIndexNotifier = ValueNotifier<int>(0);

  static int get currentIndex => _currentIndex;
  
  static void setIndex(int index) {
    _currentIndex = index;
    currentIndexNotifier.value = index;
  }

  static void navigateToTab(int index) {
    setIndex(index);
  }
}
