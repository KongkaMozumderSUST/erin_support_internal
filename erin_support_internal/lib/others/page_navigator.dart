import 'package:flutter/material.dart';

class GlobalPageNavigator {
  static PageController? pageController;

  static String? productUuid;
  static String? categoryId;
  static Map<String, dynamic>? mapdata;
  static List<int> history = [];
  static bool _isInitialized = false;
  static void initialize() {
    pageController = PageController();
  }

  static void goTo(int page, {String? uuid, Map<String, dynamic>? data}) {
    productUuid = null;
    mapdata = null;
    if (history.isEmpty || history.last != page) {
      history.add(page); // push new page into history
    }

    pageController!.jumpToPage(page);
  }

  static void nextPage() {
    pageController!.nextPage(
      duration: const Duration(milliseconds: 0),
      curve: Curves.easeInOut,
    );
  }

  static void previousPage() {
    pageController!.previousPage(
      duration: const Duration(milliseconds: 10),
      curve: Curves.easeInOut,
    );
  }

  static void nextPagep() {
    int next = pageController!.page!.toInt() + 1;
    goTo(next);
  }

  static void previousPagep() {
    if (history.length > 1) {
      history.removeLast(); // remove current
      int prev = history.last; // go back to previous visited page
      pageController!.animateToPage(
        prev,
        duration: const Duration(milliseconds: 10),
        curve: Curves.easeInOut,
      );
    }
  }

  static bool canGoBack() {
    return history.length > 1;
  }
}