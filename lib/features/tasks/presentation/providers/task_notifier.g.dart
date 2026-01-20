// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$taskRepositoryHash() => r'94f49e2069c5194d1ec94c31bccc3efc74e0fe59';

/// See also [taskRepository].
@ProviderFor(taskRepository)
final taskRepositoryProvider = AutoDisposeProvider<TaskRepository>.internal(
  taskRepository,
  name: r'taskRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$taskRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef TaskRepositoryRef = AutoDisposeProviderRef<TaskRepository>;
String _$taskNotifierHash() => r'33b88d652f17befbf3170c61873ee07da988b012';

/// See also [TaskNotifier].
@ProviderFor(TaskNotifier)
final taskNotifierProvider =
    AutoDisposeNotifierProvider<TaskNotifier, List<TaskEntity>>.internal(
  TaskNotifier.new,
  name: r'taskNotifierProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$taskNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TaskNotifier = AutoDisposeNotifier<List<TaskEntity>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
