// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'timer_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$TimerEntity {
  int get remainingSeconds => throw _privateConstructorUsedError;
  int get initialDuration => throw _privateConstructorUsedError;
  TimerStatus get status => throw _privateConstructorUsedError;
  TimerType get type => throw _privateConstructorUsedError;
  int get roundCount => throw _privateConstructorUsedError;
  String? get currentTaskName => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $TimerEntityCopyWith<TimerEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TimerEntityCopyWith<$Res> {
  factory $TimerEntityCopyWith(
          TimerEntity value, $Res Function(TimerEntity) then) =
      _$TimerEntityCopyWithImpl<$Res, TimerEntity>;
  @useResult
  $Res call(
      {int remainingSeconds,
      int initialDuration,
      TimerStatus status,
      TimerType type,
      int roundCount,
      String? currentTaskName});
}

/// @nodoc
class _$TimerEntityCopyWithImpl<$Res, $Val extends TimerEntity>
    implements $TimerEntityCopyWith<$Res> {
  _$TimerEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? remainingSeconds = null,
    Object? initialDuration = null,
    Object? status = null,
    Object? type = null,
    Object? roundCount = null,
    Object? currentTaskName = freezed,
  }) {
    return _then(_value.copyWith(
      remainingSeconds: null == remainingSeconds
          ? _value.remainingSeconds
          : remainingSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      initialDuration: null == initialDuration
          ? _value.initialDuration
          : initialDuration // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as TimerStatus,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as TimerType,
      roundCount: null == roundCount
          ? _value.roundCount
          : roundCount // ignore: cast_nullable_to_non_nullable
              as int,
      currentTaskName: freezed == currentTaskName
          ? _value.currentTaskName
          : currentTaskName // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TimerEntityImplCopyWith<$Res>
    implements $TimerEntityCopyWith<$Res> {
  factory _$$TimerEntityImplCopyWith(
          _$TimerEntityImpl value, $Res Function(_$TimerEntityImpl) then) =
      __$$TimerEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int remainingSeconds,
      int initialDuration,
      TimerStatus status,
      TimerType type,
      int roundCount,
      String? currentTaskName});
}

/// @nodoc
class __$$TimerEntityImplCopyWithImpl<$Res>
    extends _$TimerEntityCopyWithImpl<$Res, _$TimerEntityImpl>
    implements _$$TimerEntityImplCopyWith<$Res> {
  __$$TimerEntityImplCopyWithImpl(
      _$TimerEntityImpl _value, $Res Function(_$TimerEntityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? remainingSeconds = null,
    Object? initialDuration = null,
    Object? status = null,
    Object? type = null,
    Object? roundCount = null,
    Object? currentTaskName = freezed,
  }) {
    return _then(_$TimerEntityImpl(
      remainingSeconds: null == remainingSeconds
          ? _value.remainingSeconds
          : remainingSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      initialDuration: null == initialDuration
          ? _value.initialDuration
          : initialDuration // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as TimerStatus,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as TimerType,
      roundCount: null == roundCount
          ? _value.roundCount
          : roundCount // ignore: cast_nullable_to_non_nullable
              as int,
      currentTaskName: freezed == currentTaskName
          ? _value.currentTaskName
          : currentTaskName // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$TimerEntityImpl implements _TimerEntity {
  const _$TimerEntityImpl(
      {required this.remainingSeconds,
      required this.initialDuration,
      required this.status,
      required this.type,
      this.roundCount = 0,
      this.currentTaskName});

  @override
  final int remainingSeconds;
  @override
  final int initialDuration;
  @override
  final TimerStatus status;
  @override
  final TimerType type;
  @override
  @JsonKey()
  final int roundCount;
  @override
  final String? currentTaskName;

  @override
  String toString() {
    return 'TimerEntity(remainingSeconds: $remainingSeconds, initialDuration: $initialDuration, status: $status, type: $type, roundCount: $roundCount, currentTaskName: $currentTaskName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimerEntityImpl &&
            (identical(other.remainingSeconds, remainingSeconds) ||
                other.remainingSeconds == remainingSeconds) &&
            (identical(other.initialDuration, initialDuration) ||
                other.initialDuration == initialDuration) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.roundCount, roundCount) ||
                other.roundCount == roundCount) &&
            (identical(other.currentTaskName, currentTaskName) ||
                other.currentTaskName == currentTaskName));
  }

  @override
  int get hashCode => Object.hash(runtimeType, remainingSeconds,
      initialDuration, status, type, roundCount, currentTaskName);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TimerEntityImplCopyWith<_$TimerEntityImpl> get copyWith =>
      __$$TimerEntityImplCopyWithImpl<_$TimerEntityImpl>(this, _$identity);
}

abstract class _TimerEntity implements TimerEntity {
  const factory _TimerEntity(
      {required final int remainingSeconds,
      required final int initialDuration,
      required final TimerStatus status,
      required final TimerType type,
      final int roundCount,
      final String? currentTaskName}) = _$TimerEntityImpl;

  @override
  int get remainingSeconds;
  @override
  int get initialDuration;
  @override
  TimerStatus get status;
  @override
  TimerType get type;
  @override
  int get roundCount;
  @override
  String? get currentTaskName;
  @override
  @JsonKey(ignore: true)
  _$$TimerEntityImplCopyWith<_$TimerEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
