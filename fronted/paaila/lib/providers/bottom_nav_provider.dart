import 'package:flutter_riverpod/flutter_riverpod.dart';

class BottomNavNotifier extends StateNotifier<int> {
  BottomNavNotifier() : super(0);

  void setIndex(int index) {
    state = index;
  }
}

final bottomNavIndexProvider =
    StateNotifierProvider<BottomNavNotifier, int>(
  (ref) => BottomNavNotifier(),
);
