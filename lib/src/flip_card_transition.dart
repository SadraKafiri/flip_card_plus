import 'dart:math';

import 'package:flutter/material.dart';

import 'flip_card.dart';

Widget _fill(Widget child, Key key) => Positioned.fill(key: key, child: child);
Widget _noop(Widget child, Key key) => KeyedSubtree(key: key, child: child);

/// The transition used internally by [FlipCardPlus].
///
/// You can obtain more direct control by providing your own [Animation] at
/// the cost of the built-in helpers like [FlipCardPlusState.flip].
class FlipCardPlusTransition extends StatefulWidget {
  const FlipCardPlusTransition({
    super.key,
    required this.front,
    required this.back,
    required this.animation,
    this.direction = Axis.horizontal,
    this.flipDirection,
    this.keepSameDirection = false,
    this.fill = Fill.none,
    this.sizeToActiveSide = false,
    this.alignment = Alignment.center,
    this.frontAnimator,
    this.backAnimator,
    this.filterQuality,
    this.borderRadius,
    this.curve,
    this.reverseCurve,
    this.perspective = 0.001,
    this.elevation = 0.0,
    this.shadowColor,
    this.rtlAware = true,
    this.useRepaintBoundary = true,
    this.clipBehavior = Clip.antiAlias,
  });

  /// {@template flip_card.FlipCardPlusTransition.front}
  /// The widget rendered on the front side.
  /// {@endtemplate}
  final Widget front;

  /// {@template flip_card.FlipCardPlusTransition.back}
  /// The widget rendered on the back side.
  /// {@endtemplate}
  final Widget back;

  /// The [Animation] that drives the flip.
  final Animation<double> animation;

  /// {@template flip_card.FlipCardPlusTransition.direction}
  /// The animation [Axis] of the card.
  /// {@endtemplate}
  final Axis direction;

  /// Fine-grained flip direction. Overrides [direction] when set.
  final FlipDirection? flipDirection;

  /// Whether the card keeps the same rotation direction when flipping back.
  final bool keepSameDirection;

  /// {@template flip_card.FlipCardPlusTransition.fill}
  /// Whether to stretch one side to fill the other.
  /// {@endtemplate}
  final Fill fill;

  /// Whether to size the card to the currently active (visible) side.
  final bool sizeToActiveSide;

  /// {@template flip_card.FlipCardPlusTransition.alignment}
  /// How to align [front] and [back] inside the card.
  /// {@endtemplate}
  final Alignment alignment;

  /// {@macro flip_card.FlipPlusTransition.filterQuality}
  final FilterQuality? filterQuality;

  /// Custom [Animatable] for the front face.
  ///
  /// When null, [defaultFrontAnimator] (or one built from [curve]) is used.
  final Animatable<double>? frontAnimator;

  /// Custom [Animatable] for the back face.
  ///
  /// When null, [defaultBackAnimator] (or one built from [reverseCurve] /
  /// [curve]) is used.
  final Animatable<double>? backAnimator;

  /// Clips each face of the card with the given [BorderRadius] inside the
  /// rotation transform, preventing artefacts at the midpoint.
  final BorderRadius? borderRadius;

  /// The [Curve] for the front-face rotation (first half of the flip).
  ///
  /// When null, [Curves.easeIn] is used.
  /// Ignored if [frontAnimator] is provided.
  final Curve? curve;

  /// The [Curve] for the back-face rotation (second half of the flip).
  ///
  /// Falls back to [curve], then to [Curves.easeOut].
  /// Ignored if [backAnimator] is provided.
  final Curve? reverseCurve;

  /// The perspective value projection.
  final double perspective;

  /// The base elevation of the card shadow.
  final double elevation;

  /// Custom color of the dynamic shadow.
  final Color? shadowColor;

  /// Whether horizontal flip directions are RTL-aware.
  final bool rtlAware;

  /// Whether to wrap each card face in a [RepaintBoundary].
  final bool useRepaintBoundary;

  /// The clipping behavior to apply to card corners when [borderRadius] is set.
  final Clip clipBehavior;

  // ── Default animators ────────────────────────────────────────────────────

  /// Default front animator: 0 → π/2 with easeIn, then held at π/2.
  static final defaultFrontAnimator = TweenSequence(
    [
      TweenSequenceItem<double>(
        tween: Tween(begin: 0.0, end: pi / 2)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50.0,
      ),
      TweenSequenceItem<double>(
        tween: ConstantTween<double>(pi / 2),
        weight: 50.0,
      ),
    ],
  );

  /// Default back animator: held at π/2, then -π/2 → 0 with easeOut.
  static final defaultBackAnimator = TweenSequence(
    [
      TweenSequenceItem<double>(
        tween: ConstantTween<double>(pi / 2),
        weight: 50.0,
      ),
      TweenSequenceItem<double>(
        tween: Tween(begin: -pi / 2, end: 0.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50.0,
      ),
    ],
  );

  // ── Animator factories ───────────────────────────────────────────────────

  /// Builds a front animator using [curve] instead of the default easeIn.
  static Animatable<double> buildFrontAnimator({
    Curve curve = Curves.easeIn,
  }) =>
      TweenSequence([
        TweenSequenceItem<double>(
          tween: Tween(begin: 0.0, end: pi / 2).chain(CurveTween(curve: curve)),
          weight: 50.0,
        ),
        TweenSequenceItem<double>(
          tween: ConstantTween<double>(pi / 2),
          weight: 50.0,
        ),
      ]);

  /// Builds a back animator using [curve] instead of the default easeOut.
  static Animatable<double> buildBackAnimator({
    Curve curve = Curves.easeOut,
  }) =>
      TweenSequence([
        TweenSequenceItem<double>(
          tween: ConstantTween<double>(pi / 2),
          weight: 50.0,
        ),
        TweenSequenceItem<double>(
          tween:
              Tween(begin: -pi / 2, end: 0.0).chain(CurveTween(curve: curve)),
          weight: 50.0,
        ),
      ]);

  @override
  State<FlipCardPlusTransition> createState() => _FlipCardPlusTransitionState();
}

class _FlipCardPlusTransitionState extends State<FlipCardPlusTransition> {
  late Widget _front;
  late Widget _back;
  late bool _isFrontHalf;

  late Animation<double> _frontAnimation;
  late Animation<double> _backAnimation;

  void _updateAnimations() {
    _frontAnimation = _MappedAnimation(
      parent: widget.animation,
      frontAnimator: _effectiveFrontAnimator,
      backAnimator: _effectiveBackAnimator,
      isFront: true,
    );
    _backAnimation = _MappedAnimation(
      parent: widget.animation,
      frontAnimator: _effectiveFrontAnimator,
      backAnimator: _effectiveBackAnimator,
      isFront: false,
    );
  }

  @override
  void initState() {
    super.initState();
    _front = widget.front;
    _back = widget.back;

    double progress = widget.animation.value % 2.0;
    if (progress < 0) progress += 2.0;
    _isFrontHalf = progress <= 0.5 || progress >= 1.5;

    widget.animation.addListener(_handleAnimationUpdate);
    _updateAnimations();
  }

  @override
  void didUpdateWidget(covariant FlipCardPlusTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animation != oldWidget.animation ||
        widget.frontAnimator != oldWidget.frontAnimator ||
        widget.backAnimator != oldWidget.backAnimator ||
        widget.curve != oldWidget.curve ||
        widget.reverseCurve != oldWidget.reverseCurve ||
        widget.keepSameDirection != oldWidget.keepSameDirection) {
      oldWidget.animation.removeListener(_handleAnimationUpdate);
      widget.animation.addListener(_handleAnimationUpdate);

      double progress = widget.animation.value % 2.0;
      if (progress < 0) progress += 2.0;
      _isFrontHalf = progress <= 0.5 || progress >= 1.5;
    }
    _updateAnimations();
    _handleAnimationUpdate();
  }

  @override
  void dispose() {
    widget.animation.removeListener(_handleAnimationUpdate);
    super.dispose();
  }

  void _handleAnimationUpdate() {
    final value = widget.animation.value;
    final isStatic = widget.animation.status == AnimationStatus.dismissed ||
        widget.animation.status == AnimationStatus.completed;

    bool updated = false;

    double progress = value % 2.0;
    if (progress < 0) progress += 2.0;
    final isFrontHalf = progress <= 0.5 || progress >= 1.5;

    if (isFrontHalf != _isFrontHalf) {
      _isFrontHalf = isFrontHalf;
      updated = true;
    }

    if (isStatic || !isFrontHalf) {
      if (_front != widget.front) {
        _front = widget.front;
        updated = true;
      }
    }

    if (isStatic || isFrontHalf) {
      if (_back != widget.back) {
        _back = widget.back;
        updated = true;
      }
    }

    if (updated) {
      setState(() {});
    }
  }

  // ── Effective animators (respects curve / reverseCurve) ──────────────────

  Animatable<double> get _effectiveFrontAnimator {
    if (widget.frontAnimator != null) return widget.frontAnimator!;
    if (widget.curve != null) {
      return FlipCardPlusTransition.buildFrontAnimator(curve: widget.curve!);
    }
    return FlipCardPlusTransition.defaultFrontAnimator;
  }

  Animatable<double> get _effectiveBackAnimator {
    if (widget.backAnimator != null) return widget.backAnimator!;
    final c = widget.reverseCurve ?? widget.curve;
    if (c != null) {
      return FlipCardPlusTransition.buildBackAnimator(curve: c);
    }
    return FlipCardPlusTransition.defaultBackAnimator;
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final showingFront = _isFrontHalf;

    final Widget frontChild;
    final Widget backChild;

    const frontKey = ValueKey('FlipCardPlus_Front_Key');
    const backKey = ValueKey('FlipCardPlus_Back_Key');

    if (widget.sizeToActiveSide) {
      if (showingFront) {
        frontChild = _noop(_buildContent(child: _front), frontKey);
        backChild = _fill(_buildContent(child: _back), backKey);
      } else {
        frontChild = _fill(_buildContent(child: _front), frontKey);
        backChild = _noop(_buildContent(child: _back), backKey);
      }
    } else {
      final frontPositioning = widget.fill == Fill.front ? _fill : _noop;
      final backPositioning = widget.fill == Fill.back ? _fill : _noop;
      frontChild = frontPositioning(_buildContent(child: _front), frontKey);
      backChild = backPositioning(_buildContent(child: _back), backKey);
    }

    return Stack(
      alignment: widget.alignment,
      fit: StackFit.passthrough,
      children: _isFrontHalf
          ? <Widget>[backChild, frontChild]
          : <Widget>[frontChild, backChild],
    );
  }

  Widget _buildContent({required Widget child}) {
    final isFront = child == _front;
    final showingFront = _isFrontHalf;

    final Animation<double> animation =
        isFront ? _frontAnimation : _backAnimation;

    final resolvedDirection = widget.flipDirection ??
        (widget.direction == Axis.vertical
            ? FlipDirection.vertical
            : FlipDirection.horizontal);

    double multiplier = resolvedDirection.multiplier;
    if (widget.rtlAware && resolvedDirection.axis == Axis.horizontal) {
      final isRtl = Directionality.maybeOf(context) == TextDirection.rtl;
      if (isRtl) {
        multiplier *= -1.0;
      }
    }

    // Apply border-radius clipping inside the rotation to avoid artefacts.
    Widget effectiveChild = widget.borderRadius != null
        ? ClipRRect(
            borderRadius: widget.borderRadius!,
            clipBehavior: widget.clipBehavior,
            child: child,
          )
        : child;

    // Apply RepaintBoundary if useRepaintBoundary is true
    if (widget.useRepaintBoundary) {
      effectiveChild = RepaintBoundary(child: effectiveChild);
    }

    // Apply dynamic shadow if elevation > 0.0
    if (widget.elevation > 0.0) {
      final progress = 1.0 - (widget.animation.value - 0.5).abs() * 2;
      final currentElevation =
          widget.elevation + (widget.elevation * 0.8 * progress);
      final blurRadius = currentElevation * 2.0;
      final offsetY = currentElevation * 0.8;
      final shadowColor = (widget.shadowColor ?? Colors.black).withValues(
        alpha: (0.2 - (0.05 * progress)).clamp(0.0, 1.0),
      );

      effectiveChild = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: widget.borderRadius,
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: blurRadius,
              offset: Offset(0, offsetY),
            ),
          ],
        ),
        child: effectiveChild,
      );
    }

    /// Pointer events that would reach the inactive face should be ignored.
    return IgnorePointer(
      ignoring: isFront ? !showingFront : showingFront,
      child: FlipPlusTransition(
        animation: animation,
        direction: resolvedDirection.axis,
        multiplier: multiplier,
        filterQuality: widget.filterQuality,
        perspective: widget.perspective,
        child: effectiveChild,
      ),
    );
  }
}

/// The per-face rotation transition used by [FlipCardPlusTransition].
///
/// Applies a rotation [Transform] in [direction] where the angle is
/// `animation.value`. Omits the [Transform] entirely when the card is flat
/// or static to prevent Impeller compositing conflicts.
class FlipPlusTransition extends AnimatedWidget {
  const FlipPlusTransition({
    super.key,
    required this.child,
    required this.animation,
    required this.direction,
    this.multiplier = 1.0,
    required this.filterQuality,
    this.perspective = 0.001,
  }) : super(listenable: animation);

  /// The [Animation] that controls this transition.
  final Animation<double> animation;

  /// The widget being animated.
  final Widget child;

  /// The flip axis.
  final Axis direction;

  /// Rotation angle multiplier (sign controls fold direction).
  final double multiplier;

  /// The perspective value projection.
  final double perspective;

  /// {@template flip_card.FlipPlusTransition.filterQuality}
  /// The [FilterQuality] for the internal [Transform].
  ///
  /// Setting this to [FilterQuality.none] can prevent white-line artefacts
  /// in scrolling lists at the cost of slightly lower render quality.
  /// {@endtemplate}
  final FilterQuality? filterQuality;

  @override
  Widget build(BuildContext context) {
    final isPerpendicular = (animation.value.abs() - (pi / 2)).abs() < 0.0001;
    final isFlat = animation.value == 0.0;

    Widget result = child;

    if (!isPerpendicular && !isFlat) {
      final transform = Matrix4.identity();
      if (perspective != 0.0) {
        transform.setEntry(3, 2, perspective);
      }
      switch (direction) {
        case Axis.horizontal:
          transform.rotateY(animation.value * multiplier);
          break;
        case Axis.vertical:
          transform.rotateX(animation.value * multiplier);
          break;
      }
      result = Transform(
        transform: transform,
        alignment: FractionalOffset.center,
        filterQuality: filterQuality,
        child: result,
      );
    }

    if (isPerpendicular) {
      result = Opacity(opacity: 0.0, child: result);
    }

    return result;
  }
}

class _MappedAnimation extends Animation<double>
    with AnimationWithParentMixin<double> {
  _MappedAnimation({
    required this.parent,
    required this.frontAnimator,
    required this.backAnimator,
    required this.isFront,
  });

  @override
  final Animation<double> parent;
  final Animatable<double> frontAnimator;
  final Animatable<double> backAnimator;
  final bool isFront;

  @override
  double get value {
    double progress = parent.value % 2.0;
    if (progress < 0) progress += 2.0;

    if (progress <= 1.0) {
      return (isFront ? frontAnimator : backAnimator).transform(progress);
    } else {
      return (isFront ? backAnimator : frontAnimator).transform(progress - 1.0);
    }
  }
}
