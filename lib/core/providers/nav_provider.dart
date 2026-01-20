import 'package:flutter_riverpod/flutter_riverpod.dart';

// 0 = Timer, 1 = Tasks, 2 = Stats, 3 = Settings
final bottomNavProvider = StateProvider<int>((ref) => 0);
