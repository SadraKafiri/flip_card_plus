# Changelog

## [1.0.5] — 2026-06-09

## [1.0.4] — 2026-06-05

### Added
- Optimized search topics in `pubspec.yaml` to improve package discoverability on pub.dev.
- Initial stable release of `flip_card_plus` package.
- Premium customizable 3D flip card widget with smooth animations, realistic perspective projection, and zero-allocation performance.
- Swipe/drag-to-flip gesture (`flipOnDrag`) with configurable commit threshold (`dragThreshold`).
- Hover-to-flip trigger for desktop (`flipOnHover`) using `MouseRegion`.
- Premium dynamic shadow casting (`elevation` & `shadowColor`) that lifts and blurs at the flip midpoint.
- Custom animation easing curves (`curve` & `reverseCurve`) for front and back rotations independently.
- Lifecycle callbacks: `onFlipStart(CardSide from, CardSide to)` and `onFlipDone(CardSide side)`.
- Keyboard accessibility (`focusable`) — `Space`/`Enter` keys trigger flip when card is focused.
- RTL layout support (`rtlAware`) — automatically mirrors horizontal drag/flip directions.
- Repaint boundary isolation (`useRepaintBoundary`) and corner clip optimization (`clipBehavior`).
- Border radius clipping (`borderRadius`) applied per-face to avoid artefacts at the rotation midpoint.
- Programmatic control via `FlipCardPlusController` — `flip()`, `flipWithoutAnimation()`, `hint()`, `skew()`.
- Interactive state lock (`isDisabled`) to disable all interactions.
- Declarative `side` property for reactive side control.
- Auto-flip after delay (`autoFlipDuration`).
- Added package branding banner (`flip_card_banner.png`) at the top of README.md and as the first screenshot in pubspec.yaml.
- 📺 **[Watch the full demo on YouTube →](https://youtu.be/4-EGu33lxwY)**

### Fixed
- Fixed missing Dartdoc comments on several public symbols (`CardSide`, `Fill`, and default constructors).
- Reduced screenshot listings in `pubspec.yaml` to exactly 10 to comply with pub.dev constraints.
- Updated example preview image sources in `README.md` to direct `raw.githubusercontent.com` URLs.
- Corrected `onFlipDone` callback parameter type in README documentation (`CardSide` not `bool`).
- Replaced deprecated `Colors.withOpacity()` with `Colors.withValues(alpha:)` in code examples.
