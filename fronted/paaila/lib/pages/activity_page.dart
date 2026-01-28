import 'package:flutter/material.dart';

import '../screens/map/map_for_running.dart';

class ActivityPage extends StatelessWidget {
  const ActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Directly show the map for running
    return const MapForRunningPage();
  }
}
