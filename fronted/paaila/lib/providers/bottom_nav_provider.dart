import 'package:flutter_riverpod/flutter_riverpod.dart';

final bottomNavIndexProvider = StateNotifierProvider<BottomNavNotifier, int>(
  (ref) => BottomNavNotifier(),
);

class BottomNavNotifier extends StateNotifier<int> {
  BottomNavNotifier() : super(0);

  void setIndex(int index) {
    state = index;
  }

  void resetIndex() {
    state = 0;
  }
}
