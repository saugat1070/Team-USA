import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/run.dart';

/// Contract for saving & loading runs.
///
/// In your real app, you can implement this using:
/// - REST API
/// - Supabase / Firebase
/// - Local database (Hive, Isar, sqflite, etc.)
abstract class RunRepository {
  Future<void> saveRun(Run run);

  Future<List<Run>> getRuns();
}

/// Simple in-memory implementation so MapPage can call `saveRun`
/// without depending on a real backend yet.
class InMemoryRunRepository implements RunRepository {
  final List<Run> _runs = [];

  @override
  Future<void> saveRun(Run run) async {
    _runs.add(run);
  }

  @override
  Future<List<Run>> getRuns() async {
    return List.unmodifiable(_runs);
  }
}

/// Riverpod provider so any widget can access the repository.
final runRepositoryProvider = Provider<RunRepository>((ref) {
  // Swap this with your real implementation later.
  return InMemoryRunRepository();
});

