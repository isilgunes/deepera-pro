// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settings_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$SettingsState {
  int get focusDuration => throw _privateConstructorUsedError;
  int get shortBreakDuration => throw _privateConstructorUsedError;
  int get longBreakDuration => throw _privateConstructorUsedError;
  bool get autoStartBreaks => throw _privateConstructorUsedError;
  bool get isAlarmEnabled => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $SettingsStateCopyWith<SettingsState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SettingsStateCopyWith<$Res> {
  factory $SettingsStateCopyWith(
          SettingsState value, $Res Function(SettingsState) then) =
      _$SettingsStateCopyWithImpl<$Res, SettingsState>;
  @useResult
  $Res call(
      {int focusDuration,
      int shortBreakDuration,
      int longBreakDuration,
      bool autoStartBreaks,
      bool isAlarmEnabled});
}

/// @nodoc
class _$SettingsStateCopyWithImpl<$Res, $Val extends SettingsState>
    implements $SettingsStateCopyWith<$Res> {
  _$SettingsStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? focusDuration = null,
    Object? shortBreakDuration = null,
    Object? longBreakDuration = null,
    Object? autoStartBreaks = null,
    Object? isAlarmEnabled = null,
  }) {
    return _then(_value.copyWith(
      focusDuration: null == focusDuration
          ? _value.focusDuration
          : focusDuration // ignore: cast_nullable_to_non_nullable
              as int,
      shortBreakDuration: null == shortBreakDuration
          ? _value.shortBreakDuration
          : shortBreakDuration // ignore: cast_nullable_to_non_nullable
              as int,
      longBreakDuration: null == longBreakDuration
          ? _value.longBreakDuration
          : longBreakDuration // ignore: cast_nullable_to_non_nullable
              as int,
      autoStartBreaks: null == autoStartBreaks
          ? _value.autoStartBreaks
          : autoStartBreaks // ignore: cast_nullable_to_non_nullable
              as bool,
      isAlarmEnabled: null == isAlarmEnabled
          ? _value.isAlarmEnabled
          : isAlarmEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SettingsStateImplCopyWith<$Res>
    implements $SettingsStateCopyWith<$Res> {
  factory _$$SettingsStateImplCopyWith(
          _$SettingsStateImpl value, $Res Function(_$SettingsStateImpl) then) =
      __$$SettingsStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int focusDuration,
      int shortBreakDuration,
      int longBreakDuration,
      bool autoStartBreaks,
      bool isAlarmEnabled});
}

/// @nodoc
class __$$SettingsStateImplCopyWithImpl<$Res>
    extends _$SettingsStateCopyWithImpl<$Res, _$SettingsStateImpl>
    implements _$$SettingsStateImplCopyWith<$Res> {
  __$$SettingsStateImplCopyWithImpl(
      _$SettingsStateImpl _value, $Res Function(_$SettingsStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? focusDuration = null,
    Object? shortBreakDuration = null,
    Object? longBreakDuration = null,
    Object? autoStartBreaks = null,
    Object? isAlarmEnabled = null,
  }) {
    return _then(_$SettingsStateImpl(
      focusDuration: null == focusDuration
          ? _value.focusDuration
          : focusDuration // ignore: cast_nullable_to_non_nullable
              as int,
      shortBreakDuration: null == shortBreakDuration
          ? _value.shortBreakDuration
          : shortBreakDuration // ignore: cast_nullable_to_non_nullable
              as int,
      longBreakDuration: null == longBreakDuration
          ? _value.longBreakDuration
          : longBreakDuration // ignore: cast_nullable_to_non_nullable
              as int,
      autoStartBreaks: null == autoStartBreaks
          ? _value.autoStartBreaks
          : autoStartBreaks // ignore: cast_nullable_to_non_nullable
              as bool,
      isAlarmEnabled: null == isAlarmEnabled
          ? _value.isAlarmEnabled
          : isAlarmEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$SettingsStateImpl implements _SettingsState {
  const _$SettingsStateImpl(
      {this.focusDuration = 25,
      this.shortBreakDuration = 5,
      this.longBreakDuration = 15,
      this.autoStartBreaks = false,
      this.isAlarmEnabled = true});

  @override
  @JsonKey()
  final int focusDuration;
  @override
  @JsonKey()
  final int shortBreakDuration;
  @override
  @JsonKey()
  final int longBreakDuration;
  @override
  @JsonKey()
  final bool autoStartBreaks;
  @override
  @JsonKey()
  final bool isAlarmEnabled;

  @override
  String toString() {
    return 'SettingsState(focusDuration: $focusDuration, shortBreakDuration: $shortBreakDuration, longBreakDuration: $longBreakDuration, autoStartBreaks: $autoStartBreaks, isAlarmEnabled: $isAlarmEnabled)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SettingsStateImpl &&
            (identical(other.focusDuration, focusDuration) ||
                other.focusDuration == focusDuration) &&
            (identical(other.shortBreakDuration, shortBreakDuration) ||
                other.shortBreakDuration == shortBreakDuration) &&
            (identical(other.longBreakDuration, longBreakDuration) ||
                other.longBreakDuration == longBreakDuration) &&
            (identical(other.autoStartBreaks, autoStartBreaks) ||
                other.autoStartBreaks == autoStartBreaks) &&
            (identical(other.isAlarmEnabled, isAlarmEnabled) ||
                other.isAlarmEnabled == isAlarmEnabled));
  }

  @override
  int get hashCode => Object.hash(runtimeType, focusDuration,
      shortBreakDuration, longBreakDuration, autoStartBreaks, isAlarmEnabled);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SettingsStateImplCopyWith<_$SettingsStateImpl> get copyWith =>
      __$$SettingsStateImplCopyWithImpl<_$SettingsStateImpl>(this, _$identity);
}

abstract class _SettingsState implements SettingsState {
  const factory _SettingsState(
      {final int focusDuration,
      final int shortBreakDuration,
      final int longBreakDuration,
      final bool autoStartBreaks,
      final bool isAlarmEnabled}) = _$SettingsStateImpl;

  @override
  int get focusDuration;
  @override
  int get shortBreakDuration;
  @override
  int get longBreakDuration;
  @override
  bool get autoStartBreaks;
  @override
  bool get isAlarmEnabled;
  @override
  @JsonKey(ignore: true)
  _$$SettingsStateImplCopyWith<_$SettingsStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
