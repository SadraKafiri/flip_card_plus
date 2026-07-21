import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'flip_card_transition.dart';
import 'flip_card_controller.dart';

/// Represents the visible side of the card.
enum CardSide {
  /// The front side of the card.
  front,

  /// The back side of the card.
  back;

  /// Return [CardSide] associated with the [AnimationStatus]
  factory CardSide.fromAnimationStatus(AnimationStatus status) {
    switch (status) {
      case AnimationStatus.dismissed:
      case AnimationStatus.reverse:
        return CardSide.front;
      case AnimationStatus.forward:
      case AnimationStatus.completed:
        return CardSide.back;
    }
  }

  /// Return the opposite of this [CardSide]
  CardSide get opposite {
    switch (this) {
      case CardSide.front:
        return CardSide.back;
      case CardSide.back:
        return CardSide.front;
    }
  }
}

/// Determines how the front and back faces of the card should be sized relative to each other.
enum Fill {
  /// Keep the original dimensions of both faces.
  none,

  /// Size the front face to match the back face.
  front,

  /// Size the back face to match the front face.
  back,
}

enum FlipDirection {
  vertical,
  horizontal,
  verticalTop,
  verticalBottom,
  horizontalLeft,
  horizontalRight;

  Axis get axis {
    switch (this) {
      case FlipDirection.vertical:
      case FlipDirection.verticalTop:
      case FlipDirection.verticalBottom:
        return Axis.vertical;
      case FlipDirection.horizontal:
      case FlipDirection.horizontalLeft:
      case FlipDirection.horizontalRight:
        return Axis.horizontal;
    }
  }

  double get multiplier {
    switch (this) {
      case FlipDirection.vertical:
      case FlipDirection.verticalBottom:
      case FlipDirection.horizontal:
      case FlipDirection.horizontalLeft:
        return 1.0;
      case FlipDirection.verticalTop:
      case FlipDirection.horizontalRight:
        return -1.0;
    }
  }
}

extension on TickerFuture {
  /// Wait until ticker completes or an error is thrown
  Future<void> get complete {
    final completer = Completer();
    void thunk(value) {
      completer.complete();
    }

    orCancel.then(thunk, onError: thunk);
    return completer.future;
  }
}

/// A widget that provides a flip card animation.
/// It could be used for hiding and showing details of a product.
///
/// To control the card programmatically, pass a [controller].
///
/// ## Example
///
/// ```dart
/// FlipCardPlus(
///   fill: Fill.back, // Sizes the back to fill the front dimensions
///   direction: Axis.horizontal, // default
///   initialSide: CardSide.front,
///   flipOnDrag: true,           // enable drag-to-flip
///   borderRadius: BorderRadius.circular(16),
///   curve: Curves.elasticOut,
///   front: Container(child: Text('Front')),
///   back: Container(child: Text('Back')),
/// )
/// ```
class FlipCardPlus extends StatefulWidget {
  /// Creates a [FlipCardPlus] widget.
  const FlipCardPlus({
    super.key,
    required this.front,
    required this.back,
    this.duration = const Duration(milliseconds: 500),
    // ignore: deprecated_member_use_from_same_package
    @Deprecated(
        'Use onFlipStart instead. onFlip will be removed in a future release.')
    this.onFlip,
    this.onFlipStart,
    this.onFlipDone,
    this.direction = Axis.horizontal,
    this.flipDirection,
    this.keepSameDirection = false,
    this.controller,
    this.flipOnTouch = true,
    this.flipOnDrag = false,
    this.dragThreshold = 0.5,
    this.alignment = Alignment.center,
    this.fill = Fill.none,
    this.initialSide = CardSide.front,
    this.side,
    this.sizeToActiveSide = false,
    this.autoFlipDuration,
    this.filterQuality,
    this.curve,
    this.reverseCurve,
    this.isDisabled = false,
    this.borderRadius,
    this.semanticLabel,
    this.flipOnHover = false,
    this.perspective = 0.001,
    this.elevation = 0.0,
    this.shadowColor,
    this.rtlAware = true,
    this.focusable = true,
    this.useRepaintBoundary = true,
    this.clipBehavior = Clip.antiAlias,
  });

  /// The initially shown side of the card.
  final CardSide initialSide;

  /// The declarative side to show. If provided, overrides [initialSide] and
  /// controls the current side reactively.
  final CardSide? side;

  /// {@macro flip_card.FlipCardPlusTransition.alignment}
  final Alignment alignment;

  /// If set, the card will flip automatically once after the specified delay.
  final Duration? autoFlipDuration;

  /// {@macro flip_card.FlipCardPlusTransition.front}
  final Widget front;

  /// {@macro flip_card.FlipCardPlusTransition.back}
  final Widget back;

  /// Assign a controller to [FlipCardPlus] to control it programmatically.
  ///
  /// {@macro flip_card_controller.example}
  final FlipCardPlusController? controller;

  /// {@macro flip_card.FlipCardPlusTransition.direction}
  final Axis direction;

  /// Fine-grained flip direction. When set, overrides [direction].
  final FlipDirection? flipDirection;

  /// Whether the card keeps the same rotation direction when flipping back.
  final bool keepSameDirection;

  /// {@macro flip_card.FlipCardPlusTransition.fill}
  final Fill fill;

  /// Whether to size the card to match the currently active (visible) side.
  final bool sizeToActiveSide;

  /// {@macro flip_card.FlipPlusTransition.filterQuality}
  final FilterQuality? filterQuality;

  /// When true, tapping the card triggers a flip.
  ///
  /// To flip programmatically, use a [controller] instead.
  final bool flipOnTouch;

  /// When true, dragging the card triggers a flip.
  ///
  /// The drag is mapped to the animation controller so the card follows
  /// the finger in real time and snaps to the nearest side on release.
  /// Can be combined with [flipOnTouch].
  final bool flipOnDrag;

  /// The fraction of the card's width/height (0.0–1.0) the drag must pass
  /// for the flip to be committed when the finger is released.
  ///
  /// A fast fling always commits the flip regardless of this threshold.
  /// Only used when [flipOnDrag] is true. Defaults to `0.5`.
  final double dragThreshold;

  /// Called at the start of every flip, providing the [CardSide] being left
  /// ([from]) and the [CardSide] being flipped to ([to]).
  ///
  /// Prefer this over the deprecated [onFlip] callback.
  final void Function(CardSide from, CardSide to)? onFlipStart;

  /// Called at the start of every flip.
  ///
  /// Deprecated — use [onFlipStart] which also provides the source and target
  /// [CardSide].
  @Deprecated('Use onFlipStart instead.')
  final VoidCallback? onFlip;

  /// Called when a flip animation completes, providing the final [CardSide].
  final void Function(CardSide side)? onFlipDone;

  /// The [Duration] of a single flip animation.
  final Duration duration;

  /// The [Curve] applied to the front-face rotation (first half of the flip).
  ///
  /// When null, [Curves.easeIn] is used.
  /// Ignored when a custom [FlipCardPlusTransition.frontAnimator] is passed directly.
  final Curve? curve;

  /// The [Curve] applied to the back-face rotation (second half of the flip).
  ///
  /// Falls back to [curve] when null, then to [Curves.easeOut].
  /// Ignored when a custom [FlipCardPlusTransition.backAnimator] is passed directly.
  final Curve? reverseCurve;

  /// When true, all flip interactions (tap, drag, controller calls) are ignored.
  ///
  /// Useful for loading states or locked quiz cards.
  final bool isDisabled;

  /// Clips each face of the card with the given [BorderRadius].
  ///
  /// Apply this instead of wrapping the whole [FlipCardPlus] in a [ClipRRect] to
  /// avoid visual artefacts at the rotation midpoint.
  final BorderRadius? borderRadius;

  /// Accessibility label announced by screen readers.
  ///
  /// When provided, a [Semantics] widget is added around the card so that
  /// assistive technology can identify it and activate it.
  final String? semanticLabel;

  /// When true, hovering the card with a mouse triggers a flip.
  ///
  /// Hovering over the card will trigger it to flip to the back,
  /// and exiting hover will trigger it to flip back to the front.
  /// Only used when not [isDisabled]. Defaults to `false`.
  final bool flipOnHover;

  /// The perspective value projection to apply to the 3D rotation transform.
  ///
  /// A value of `0.0` represents orthographic projection (no perspective).
  /// A default value of `0.001` provides a realistic 3D depth effect.
  final double perspective;

  /// The base elevation (depth) of the card's shadow.
  ///
  /// When greater than `0.0`, a dynamic shadow is automatically rendered
  /// underneath the active card face. The shadow grows (blurs/lifts) as the
  /// card rotates towards the midpoint of the animation.
  /// Defaults to `0.0` (no shadow).
  final double elevation;

  /// The custom color of the dynamic shadow.
  ///
  /// If null, a standard semi-transparent black color is used.
  /// Only active if [elevation] is greater than `0.0`.
  final Color? shadowColor;

  /// Whether the card should automatically reverse horizontal flip and drag
  /// directions in Right-to-Left (RTL) text layouts.
  ///
  /// Defaults to `true`.
  final bool rtlAware;

  /// Whether the card is focusable using keyboard navigation.
  ///
  /// Pressing `Space` or `Enter` keys on a focused card will trigger it to flip.
  /// Only used when not [isDisabled]. Defaults to `true`.
  final bool focusable;

  /// Whether to wrap each card face in a [RepaintBoundary] to isolate repaints.
  ///
  /// Defaults to `true`.
  final bool useRepaintBoundary;

  /// The clipping behavior to apply to card corners when [borderRadius] is set.
  ///
  /// Defaults to [Clip.antiAlias]. Use [Clip.hardEdge] for faster rendering.
  final Clip clipBehavior;

  @override
  State<StatefulWidget> createState() => FlipCardPlusState();
}

/// State associated with a [FlipCardPlus] widget.
///
/// A [FlipCardPlusState] can be used to [flip], [flipWithoutAnimation], [skew],
/// or [hint] the associated [FlipCardPlus].
class FlipCardPlusState extends State<FlipCardPlus>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  int _flipCount = 0;
  Timer? _autoFlipTimer;

  /// The number of times this card has been flipped since it was created.
  ///
  /// Increments on every [flip] and [flipWithoutAnimation] call, including
  /// those triggered by drag or tap.
  int get flipCount => _flipCount;

  // ── Computed flip-direction helpers ─────────────────────────────────────

  FlipDirection get _resolvedFlipDirection =>
      widget.flipDirection ??
      (widget.direction == Axis.horizontal
          ? FlipDirection.horizontal
          : FlipDirection.vertical);

  Axis get _flipAxis => _resolvedFlipDirection.axis;

  double get _flipMultiplier => _resolvedFlipDirection.multiplier;

  double get effectiveFlipMultiplier {
    double m = _flipMultiplier;
    if (widget.rtlAware && _flipAxis == Axis.horizontal) {
      final isRtl = Directionality.maybeOf(context) == TextDirection.rtl;
      if (isRtl) {
        m *= -1.0;
      }
    }
    return m;
  }

  CardSide _getCardSide(double value) {
    double progress = value % 2.0;
    if (progress < 0) progress += 2.0;
    return (progress <= 0.5 || progress >= 1.5)
        ? CardSide.front
        : CardSide.back;
  }

  // ── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    final initialSide = widget.side ?? widget.initialSide;
    controller = AnimationController(
      value: initialSide == CardSide.front ? 0.0 : 1.0,
      duration: widget.duration,
      lowerBound: double.negativeInfinity,
      upperBound: double.infinity,
      vsync: this,
    );

    widget.controller?.state = this;

    if (widget.autoFlipDuration != null) {
      _autoFlipTimer = Timer(widget.autoFlipDuration!, flip);
    }
  }

  @override
  void didUpdateWidget(FlipCardPlus oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.duration != oldWidget.duration) {
      controller.duration = widget.duration;
    }

    if (widget.controller != oldWidget.controller) {
      if (oldWidget.controller?.state == this) {
        oldWidget.controller?.state = null;
      }
      widget.controller?.state = this;
    }

    if (widget.side != null && widget.side != oldWidget.side) {
      flip(widget.side!);
    }
  }

  @override
  void dispose() {
    _autoFlipTimer?.cancel();
    controller.dispose();
    widget.controller?.state = null;
    super.dispose();
  }

  // ── Public flip API ──────────────────────────────────────────────────────

  /// {@template flip_card.FlipCardPlusState.flip}
  /// Flips the card, or reverses the current animation if it is mid-way.
  ///
  /// Optionally pass a [targetSide] to flip to a specific side.
  ///
  /// Returns a [Future] that completes when the animation finishes.
  /// {@endtemplate}
  Future<void> flip([CardSide? targetSide]) async {
    if (!mounted || widget.isDisabled) return;

    final from = _getCardSide(controller.value);
    targetSide ??= from.opposite;

    double targetValue;
    if (targetSide == from) {
      targetValue = controller.value.roundToDouble();
    } else {
      if (widget.keepSameDirection) {
        targetValue = controller.value.roundToDouble() + 1.0;
      } else {
        if (from == CardSide.front) {
          targetValue = controller.value.roundToDouble() + 1.0;
        } else {
          targetValue = controller.value.roundToDouble() - 1.0;
        }
      }
    }

    await _animateToValue(targetValue, explicitTargetSide: targetSide);
  }

  Future<void> _animateToValue(double targetValue,
      {CardSide? explicitTargetSide}) async {
    final from = _getCardSide(controller.value);
    final targetSide = explicitTargetSide ?? _getCardSide(targetValue);

    // ignore: deprecated_member_use_from_same_package
    widget.onFlip?.call();
    widget.onFlipStart?.call(from, targetSide);
    _flipCount++;

    final distance = (targetValue - controller.value).abs();
    final duration = widget.duration * distance;
    await controller
        .animateTo(targetValue, duration: duration, curve: Curves.linear)
        .complete;

    widget.onFlipDone?.call(targetSide);
  }

  /// {@template flip_card.FlipCardPlusState.flipWithoutAnimation}
  /// Flips the card instantly without playing an animation.
  ///
  /// Optionally pass a [targetSide]. Cancels any running animation.
  /// {@endtemplate}
  void flipWithoutAnimation([CardSide? targetSide]) {
    if (widget.isDisabled) return;
    controller.stop();

    final from = _getCardSide(controller.value);
    targetSide ??= from.opposite;

    // ignore: deprecated_member_use_from_same_package
    widget.onFlip?.call();
    widget.onFlipStart?.call(from, targetSide);
    _flipCount++;

    double targetValue;
    if (targetSide == from) {
      targetValue = controller.value.roundToDouble();
    } else {
      if (widget.keepSameDirection) {
        targetValue = controller.value.roundToDouble() + 1.0;
      } else {
        if (from == CardSide.front) {
          targetValue = controller.value.roundToDouble() + 1.0;
        } else {
          targetValue = controller.value.roundToDouble() - 1.0;
        }
      }
    }

    controller.value = targetValue;

    widget.onFlipDone?.call(targetSide);
  }

  /// Returns the currently active side of the card.
  CardSide get currentSide => _getCardSide(controller.value);

  /// Returns the side opposite to the one currently shown.
  CardSide getOppositeSide() {
    return _getCardSide(controller.value).opposite;
  }

  /// {@template flip_card.FlipCardPlusState.skew}
  /// Skews the card by [target] percentage (0.0–1.0).
  ///
  /// Use with a [MouseRegion] to hint that the card is flippable.
  /// Call `skew(0)` to return to the original position.
  /// Works relative to whichever side (front or back) is currently active.
  ///
  /// Returns a [Future] that resolves when the animation completes.
  /// {@endtemplate}
  Future<void> skew(double target, {Duration? duration, Curve? curve}) async {
    assert(0 <= target && target <= 1);
    final base = controller.value
        .roundToDouble(); // nearest resting position (front or back)
    final targetValue = base + target;

    await controller
        .animateTo(targetValue,
            duration: duration, curve: curve ?? Curves.linear)
        .complete;
  }

  /// {@template flip_card.FlipCardPlusState.hint}
  /// Partially flips the card to [target] and back, hinting it can be flipped.
  ///
  /// Works on whichever side (front or back) is currently active.
  ///
  /// Returns a [Future] that resolves when the animation completes.
  /// {@endtemplate}
  Future<void> hint({
    double target = 0.2,
    Duration? duration,
    Curve curveTo = Curves.easeInOut,
    Curve curveBack = Curves.easeInOut,
  }) async {
    if (controller.isAnimating) return;
    final currentValue = controller.value.roundToDouble();

    duration = duration ?? controller.duration!;
    final halfDuration =
        Duration(milliseconds: (duration.inMilliseconds / 2).round());

    try {
      await controller
          .animateTo(currentValue + target,
              duration: halfDuration, curve: curveTo)
          .complete;
    } finally {
      await controller
          .animateTo(currentValue, duration: halfDuration, curve: curveBack)
          .complete;
    }
  }
  // ── Drag gesture handlers ────────────────────────────────────────────────

  void _handleDragStart(DragStartDetails _) {
    // Stop any in-progress animation so the drag takes direct control.
    controller.stop();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    final size = context.size;
    if (size == null) return;

    // Map drag delta → controller delta.
    // Formula: (-delta / extent) * multiplier
    //   • negation: dragging left (dx < 0) should INCREASE value for a
    //     left-fold card (multiplier = 1).
    //   • multiplier: reverses for right-fold / top-fold directions.
    final double delta;
    if (_flipAxis == Axis.horizontal) {
      delta = (-details.delta.dx / size.width) * effectiveFlipMultiplier;
    } else {
      delta = (-details.delta.dy / size.height) * _flipMultiplier;
    }

    controller.value += delta;
  }

  void _handleDragEnd(DragEndDetails details) {
    final size = context.size ?? const Size(300, 300);

    // Normalise fling velocity to fractions-of-card-size per second.
    final double velocityFraction;
    if (_flipAxis == Axis.horizontal) {
      velocityFraction = (-details.velocity.pixelsPerSecond.dx / size.width) *
          effectiveFlipMultiplier;
    } else {
      velocityFraction = (-details.velocity.pixelsPerSecond.dy / size.height) *
          _flipMultiplier;
    }

    const flingThreshold = 0.3; // fractions/sec
    double targetValue;
    if (velocityFraction > flingThreshold) {
      targetValue = controller.value.ceilToDouble();
      if (targetValue == controller.value) targetValue += 1.0;
    } else if (velocityFraction < -flingThreshold) {
      targetValue = controller.value.floorToDouble();
      if (targetValue == controller.value) targetValue -= 1.0;
    } else {
      final fraction = controller.value - controller.value.floorToDouble();
      if (fraction >= widget.dragThreshold) {
        targetValue = controller.value.floorToDouble() + 1.0;
      } else {
        targetValue = controller.value.floorToDouble();
      }
    }

    _animateToValue(targetValue);
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    Widget child = FlipCardPlusTransition(
      front: widget.front,
      back: widget.back,
      animation: controller,
      direction: widget.direction,
      flipDirection: widget.flipDirection,
      keepSameDirection: widget.keepSameDirection,
      fill: widget.fill,
      sizeToActiveSide: widget.sizeToActiveSide,
      alignment: widget.alignment,
      filterQuality: widget.filterQuality,
      borderRadius: widget.borderRadius,
      curve: widget.curve,
      reverseCurve: widget.reverseCurve,
      perspective: widget.perspective,
      elevation: widget.elevation,
      shadowColor: widget.shadowColor,
      rtlAware: widget.rtlAware,
      useRepaintBoundary: widget.useRepaintBoundary,
      clipBehavior: widget.clipBehavior,
    );

    if (!widget.isDisabled) {
      if (widget.flipOnHover) {
        child = MouseRegion(
          onEnter: (_) {
            if (_getCardSide(controller.value) != CardSide.back) {
              flip(CardSide.back);
            }
          },
          onExit: (_) {
            if (_getCardSide(controller.value) != CardSide.front) {
              flip(CardSide.front);
            }
          },
          child: child,
        );
      }

      if (widget.flipOnDrag) {
        // Drag gesture — optionally combined with tap.
        if (_flipAxis == Axis.horizontal) {
          child = GestureDetector(
            behavior: HitTestBehavior.translucent,
            onHorizontalDragStart: _handleDragStart,
            onHorizontalDragUpdate: _handleDragUpdate,
            onHorizontalDragEnd: _handleDragEnd,
            onTap: widget.flipOnTouch ? flip : null,
            child: child,
          );
        } else {
          child = GestureDetector(
            behavior: HitTestBehavior.translucent,
            onVerticalDragStart: _handleDragStart,
            onVerticalDragUpdate: _handleDragUpdate,
            onVerticalDragEnd: _handleDragEnd,
            onTap: widget.flipOnTouch ? flip : null,
            child: child,
          );
        }
      } else if (widget.flipOnTouch) {
        child = GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: flip,
          child: child,
        );
      }

      if (widget.focusable) {
        child = Focus(
          onKeyEvent: (node, event) {
            if (event is KeyDownEvent) {
              if (event.logicalKey == LogicalKeyboardKey.space ||
                  event.logicalKey == LogicalKeyboardKey.enter) {
                flip();
                return KeyEventResult.handled;
              }
            }
            return KeyEventResult.ignored;
          },
          child: child,
        );
      }
    }

    if (widget.semanticLabel != null) {
      child = Semantics(
        label: widget.semanticLabel,
        button: !widget.isDisabled,
        child: child,
      );
    }

    return child;
  }
}
