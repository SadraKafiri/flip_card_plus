import 'dart:async';

import 'package:flutter/material.dart';

import 'flip_card.dart';

/// A controller used with [FlipCardPlus] to control it programmatically
///
/// {@template flip_card_controller.example}
/// ## Example
///
/// Inside a stateful widgets state do the following:
///
/// ```dart
/// late FlipCardPlusController controller = FlipCardPlusController();
///
/// @override
/// Widget build(BuildContext context) {
///   return FlipCardPlus(
///     controller: controller,
///     flipOnTouch: false,
///     front: ElevatedButton(
///       onPressed: controller.flip,
///       child: const Text('Front'),
///     ),
///     back: ElevatedButton(
///       onPressed: controller.flip,
///       child: const Text('Back'),
///     ),
///   );
/// }
/// ```
/// {@endtemplate}
class FlipCardPlusController {
  /// Creates a [FlipCardPlusController].
  FlipCardPlusController();

  FlipCardPlusState? _internalState;

  /// The internal widget state. Use only if you know what you're doing!
  ///
  /// This will throw an [AssertionError] if controller has not been
  /// assigned to a [FlipCardPlus] widget or state has not been initialized
  FlipCardPlusState get state {
    assert(
      _internalState != null,
      'Controller not attached to any FlipCardPlus. Did you forget to pass the controller to the FlipCardPlus?',
    );
    return _internalState!;
  }

  /// Set the internal state
  set state(FlipCardPlusState? value) => _internalState = value;

  /// {@macro flip_card.FlipCardPlusState.flip}
  Future<void> flip({CardSide? targetSide}) async =>
      await state.flip(targetSide);

  /// {@macro flip_card.FlipCardPlusState.flipWithoutAnimation}
  void flipWithoutAnimation([CardSide? targetSide]) =>
      state.flipWithoutAnimation(targetSide);

  /// {@macro flip_card.FlipCardPlusState.skew}
  Future<void> skew(
    double target, {
    Duration? duration,
    Curve? curve,
  }) async =>
      await state.skew(
        target,
        duration: duration,
        curve: curve,
      );

  /// {@macro flip_card.FlipCardPlusState.hint}
  Future<void> hint({
    double target = 0.2,
    Duration? duration,
    Curve curveTo = Curves.easeInOut,
    Curve curveBack = Curves.easeInOut,
  }) async =>
      await state.hint(
        target: target,
        duration: duration,
        curveTo: curveTo,
        curveBack: curveBack,
      );
}
