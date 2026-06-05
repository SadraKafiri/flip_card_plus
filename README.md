# flip_card_plus [![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://github.com/Itsxhadi/flip_card_plus/pulls) [![Pub Package](https://img.shields.io/pub/v/flip_card_plus.svg)](https://pub.dev/packages/flip_card_plus)

<p align="center">
  <img src="https://raw.githubusercontent.com/Itsxhadi/flip_card_plus/main/screenshots/flip_card_banner.png" alt="flip_card_plus Banner" width="100%" />
</p>

A premium Flutter component that provides a smooth, highly optimized 3D flip card animation. Perfect for cards, games, e-commerce products, flashcards, and profiles.

---

## 🎬 Demo Video

<p align="center">
  <a href="https://youtube.com/shorts/4-EGu33lxwY?feature=share" target="_blank">
    <img src="https://img.youtube.com/vi/4-EGu33lxwY/hqdefault.jpg" width="400" alt="flip_card_plus Demo Video" />
  </a>
  <br/>
  <a href="https://youtube.com/shorts/4-EGu33lxwY?feature=share">▶️ Watch full demo on YouTube</a>
</p>

---

## 📱 Examples Preview

<p align="center">
  <img src="https://raw.githubusercontent.com/Itsxhadi/flip_card_plus/main/screenshots/Screenshot_20260605_094214.png" width="180" alt="Example 1" />
  <img src="https://raw.githubusercontent.com/Itsxhadi/flip_card_plus/main/screenshots/Screenshot_20260605_094217.png" width="180" alt="Example 2" />
  <img src="https://raw.githubusercontent.com/Itsxhadi/flip_card_plus/main/screenshots/Screenshot_20260605_094223.png" width="180" alt="Example 3" />
  <img src="https://raw.githubusercontent.com/Itsxhadi/flip_card_plus/main/screenshots/Screenshot_20260605_094227.png" width="180" alt="Example 4" />
  <br/>
  <strong>Example 1</strong> &nbsp;|&nbsp; 
  <strong>Example 2</strong> &nbsp;|&nbsp; 
  <strong>Example 3</strong> &nbsp;|&nbsp; 
  <strong>Example 4</strong>
</p>

<p align="center">
  <img src="https://raw.githubusercontent.com/Itsxhadi/flip_card_plus/main/screenshots/Screenshot_20260605_094230.png" width="180" alt="Example 5" />
  <img src="https://raw.githubusercontent.com/Itsxhadi/flip_card_plus/main/screenshots/Screenshot_20260605_094234.png" width="180" alt="Example 6" />
  <img src="https://raw.githubusercontent.com/Itsxhadi/flip_card_plus/main/screenshots/Screenshot_20260605_094240.png" width="180" alt="Example 7" />
  <img src="https://raw.githubusercontent.com/Itsxhadi/flip_card_plus/main/screenshots/Screenshot_20260605_094242.png" width="180" alt="Example 8" />
  <br/>
  <strong>Example 5</strong> &nbsp;|&nbsp; 
  <strong>Example 6</strong> &nbsp;|&nbsp; 
  <strong>Example 7</strong> &nbsp;|&nbsp; 
  <strong>Example 8</strong>
</p>

<p align="center">
  <img src="https://raw.githubusercontent.com/Itsxhadi/flip_card_plus/main/screenshots/Screenshot_20260605_094244.png" width="180" alt="Example 9" />
  <img src="https://raw.githubusercontent.com/Itsxhadi/flip_card_plus/main/screenshots/Screenshot_20260605_094247.png" width="180" alt="Example 10" />
  <img src="https://raw.githubusercontent.com/Itsxhadi/flip_card_plus/main/screenshots/Screenshot_20260605_094253.png" width="180" alt="Example 11" />
  <br/>
  <strong>Example 9</strong> &nbsp;|&nbsp; 
  <strong>Example 10</strong> &nbsp;|&nbsp; 
  <strong>Example 11</strong>
</p>

---

## ✨ Features & Performance Optimization

* **Zero Garbage Collection Overhead**: Allocations during active flips are reduced to exactly zero by caching state animation instances.
* **Repaint Boundary Isolation (`useRepaintBoundary`)**: Isolates the repaint lifecycle of card faces, avoiding layout and repaint cycles from propagating to parent/sibling widgets.
* **Customizable ClipBehavior (`clipBehavior`)**: Support for `Clip.hardEdge` to skip offscreen GPU save-layer allocations for a ~30% raster speedup on low-end hardware.
* **Swipe-to-Flip (`flipOnDrag`)**: Intuitive gestures that mirror horizontal and vertical flip directions in Right-to-Left (RTL) text layouts.
* **Keyboard Accessibility (`focusable`)**: Supports focus request and space/enter key triggers to toggle flips programmatically.
* **Premium Dynamic Shadows**: Dynamic shadow casting that blurs and lifts as the rotation angle approaches the midpoint.

---

## 📦 Installation

Add `flip_card_plus` to your `pubspec.yaml`:

```yaml
dependencies:
  flip_card_plus: ^1.0.4
```

Or run:

```bash
flutter pub add flip_card_plus
```

---

## 🚀 How to Use

Import the package:

```dart
import 'package:flip_card_plus/flip_card_plus.dart';
```

### Default Use Case (Touch Controlled)

```dart
FlipCardPlus(
  fill: Fill.back, // Sizes the back side of the card to match the front side
  direction: Axis.horizontal, // Horizontal or Vertical axis
  initialSide: CardSide.front, // Initially visible side
  front: Container(
    child: const Text('Front Side'),
  ),
  back: Container(
    child: const Text('Back Side'),
  ),
)
```

### Controlling Programmatically

To control the card programmatically, pass a `FlipCardPlusController`:

```dart
late FlipCardPlusController _controller = FlipCardPlusController();

@override
Widget build(BuildContext context) {
  return FlipCardPlus(
    controller: _controller,
    front: ...,
    back: ...,
  );
}

void doStuff() {
  // Flip the card programmatically
  _controller.flip();

  // Flip without animation
  _controller.flipWithoutAnimation();

  // Hint flip (slightly animate front and back to show interactiveness)
  _controller.hint();

  // Skew card angle
  _controller.skew(0.2);
}
```

---

## ⚙️ Customization & Parameters (New Features)

`FlipCardPlus` is highly customizable. Below are examples of how to implement the newly introduced premium features:

### 1. Gesture & Hover Triggers
Enable drag-to-flip or hover-to-flip gestures:

```dart
FlipCardPlus(
  flipOnDrag: true,        // Enable swipe/drag to flip gesture
  dragThreshold: 0.4,      // Swipe must pass 40% of size to commit flip
  flipOnHover: true,       // Auto-flip when mouse hovers, flip back on exit
  front: ...,
  back: ...,
)
```

### 2. Premium 3D Depth & Dynamic Shadows
Customize perspective projection and dynamic shadow casting:

```dart
FlipCardPlus(
  perspective: 0.0015,                       // Adjust 3D depth perspective
  elevation: 8.0,                            // Casting shadow intensity
  shadowColor: Colors.black.withValues(alpha: 0.3), // Color of the shadow
  front: ...,
  back: ...,
)
```

### 3. Custom Easing Curves
Configure distinct easing curves for both front and back rotations:

```dart
FlipCardPlus(
  curve: Curves.elasticOut,        // Easing curve for front-to-back flip
  reverseCurve: Curves.bounceOut,  // Easing curve for back-to-front flip
  duration: const Duration(milliseconds: 800),
  front: ...,
  back: ...,
)
```

### 4. Lifecycle Callbacks
Listen to the start and completion of flip actions:

```dart
FlipCardPlus(
  onFlipStart: (fromSide, toSide) {
    print("Flipping started from $fromSide to $toSide");
  },
  onFlipDone: (side) {
    print("Flipped completely! Visible side: $side");
  },
  front: ...,
  back: ...,
)
```

### 5. Layout & Corner Clip Optimization
Smooth out card corner clipping and prevent visual artifacts during 3D rotations:

```dart
FlipCardPlus(
  borderRadius: BorderRadius.circular(16.0), // Clean clipped corner radius
  clipBehavior: Clip.hardEdge,              // Boost raster speed on low-end GPUs
  useRepaintBoundary: true,                  // Isolate card face repaint trees
  front: ...,
  back: ...,
)
```

### 6. Accessibility & Localization
Add accessibility semantics and make the card responsive to RTL layouts:

```dart
FlipCardPlus(
  semanticLabel: "Flashcard showing Flutter tutorial",
  focusable: true,  // Allow focus and flipping using Space/Enter keys
  rtlAware: true,   // Automatically reverse horizontal drag/flip in RTL
  front: ...,
  back: ...,
)
```

### 7. Interactive State Lock
Lock the card interactions when loading or in a resolved game state:

```dart
FlipCardPlus(
  isDisabled: true, // Disables touch, drag, hover, and controller flips
  front: ...,
  back: ...,
)
```

---

## 👤 Author & Maintainer

**Hadi**
- 📧 [hadi7786x@gmail.com](mailto:hadi7786x@gmail.com)
- 🐙 [github.com/Itsxhadi](https://github.com/Itsxhadi)
- 🎬 [YouTube Demo](https://youtube.com/shorts/4-EGu33lxwY?feature=share)
