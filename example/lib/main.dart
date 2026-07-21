import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flip_card_plus/flip_card_plus.dart';

void main() => runApp(const MyApp());

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          title: 'FlipCardPlus Demo',
          debugShowCheckedModeBanner: false,
          themeMode: currentMode,
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFF9F9FB),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFFF9F9FB),
              elevation: 0,
              scrolledUnderElevation: 0,
              titleTextStyle: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                letterSpacing: 1.0,
                color: Colors.black,
              ),
            ),
            navigationBarTheme: NavigationBarThemeData(
              backgroundColor: const Color(0xFFF4F4F6),
              indicatorColor: Colors.black.withOpacity(0.08),
            ),
            colorScheme: const ColorScheme.light(
              primary: Colors.black,
              secondary: Color(0xFF8E8E93),
              tertiary: Color(0xFFC7C7CC),
              surface: Colors.white,
              onSurface: Colors.black,
              outline: Color(0xFFE5E5EA),
            ),
            useMaterial3: true,
            filledButtonTheme: FilledButtonThemeData(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
            outlinedButtonTheme: OutlinedButtonThemeData(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black,
                side: const BorderSide(color: Color(0xFFE5E5EA)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF0A0A0A),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF0A0A0A),
              elevation: 0,
              scrolledUnderElevation: 0,
              titleTextStyle: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                letterSpacing: 1.0,
                color: Colors.white,
              ),
            ),
            navigationBarTheme: NavigationBarThemeData(
              backgroundColor: const Color(0xFF0D0D0D),
              indicatorColor: Colors.white.withOpacity(0.08),
            ),
            colorScheme: const ColorScheme.dark(
              primary: Colors.white,
              secondary: Color(0xFF8E8E93),
              tertiary: Color(0xFF636366),
              surface: Color(0xFF121212),
              onSurface: Colors.white,
              outline: Color(0xFF2C2C2E),
            ),
            useMaterial3: true,
            filledButtonTheme: FilledButtonThemeData(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
            outlinedButtonTheme: OutlinedButtonThemeData(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFF2C2C2E)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ),
          home: const _DemoShell(),
        );
      },
    );
  }
}

// ── Tab shell ──────────────────────────────────────────────────────────────

class _DemoShell extends StatefulWidget {
  const _DemoShell();

  @override
  State<_DemoShell> createState() => _DemoShellState();
}

class _DemoShellState extends State<_DemoShell> {
  int _tab = 0;

  static const _tabLabels = [
    'Basic',
    'Drag',
    'Style',
    'Control',
    'Advanced',
    'Showcases'
  ];
  static const _tabIcons = [
    Icons.touch_app_outlined,
    Icons.swipe_outlined,
    Icons.auto_awesome_outlined,
    Icons.tune_outlined,
    Icons.dashboard_customize_outlined,
    Icons.view_carousel_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'FlipCardPlus — ${_tabLabels[_tab]}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: [
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (context, mode, _) {
              final isDark = mode == ThemeMode.dark;
              return IconButton(
                icon: Icon(isDark
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined),
                onPressed: () {
                  themeNotifier.value =
                      isDark ? ThemeMode.light : ThemeMode.dark;
                },
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(
        index: _tab,
        children: const [
          _BasicPage(),
          _DragPage(),
          _StylePage(),
          _ControlPage(),
          _AdvancedPage(),
          _ShowcasesPage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: [
          for (int i = 0; i < _tabLabels.length; i++)
            NavigationDestination(
              icon: Icon(_tabIcons[i]),
              label: _tabLabels[i],
            ),
        ],
      ),
    );
  }
}

// ── Shared card face ───────────────────────────────────────────────────────

class _CardFace extends StatelessWidget {
  const _CardFace({
    required this.label,
    required this.sub,
    required this.color,
    this.icon,
  });

  final String label;
  final String sub;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 4,
              child: Container(color: color),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 40, color: color.withOpacity(0.8)),
                      const SizedBox(height: 16),
                    ],
                    Text(
                      label,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      sub,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Page 1 — Basic tap-to-flip ─────────────────────────────────────────────

class _BasicPage extends StatefulWidget {
  const _BasicPage();

  @override
  State<_BasicPage> createState() => _BasicPageState();
}

class _BasicPageState extends State<_BasicPage> {
  final _controller = FlipCardPlusController();
  bool _skewed = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Center(
            child: SizedBox(
              width: double.infinity,
              height: 220,
              child: FlipCardPlus(
                controller: _controller,
                duration: const Duration(milliseconds: 600),
                onFlipStart: (_, __) => setState(() {}),
                front: _CardFace(
                  label: 'Front',
                  sub: 'Tap to flip →',
                  color: cs.primary,
                  icon: Icons.lightbulb_outline,
                ),
                back: _CardFace(
                  label: 'Back',
                  sub: '← Tap to flip back',
                  color: cs.secondary,
                  icon: Icons.star_outline,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              FilledButton.icon(
                onPressed: () => _controller.flip(),
                icon: const Icon(Icons.flip),
                label: const Text('Toggle'),
              ),
              FilledButton.icon(
                onPressed: () async {
                  await _controller.skew(_skewed ? 0.0 : 0.15);
                  setState(() => _skewed = !_skewed);
                },
                icon: Icon(_skewed ? Icons.circle : Icons.circle_outlined),
                label: const Text('Skew'),
              ),
              FilledButton.icon(
                onPressed: () => _controller.hint(),
                icon: const Icon(Icons.preview_outlined),
                label: const Text('Hint'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Page 2 — Drag-to-flip ──────────────────────────────────────────────────

class _DragPage extends StatefulWidget {
  const _DragPage();

  @override
  State<_DragPage> createState() => _DragPageState();
}

class _DragPageState extends State<_DragPage> {
  bool _vertical = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Chip(
                  avatar: Icon(
                    _vertical ? Icons.swipe_vertical : Icons.swipe_outlined,
                    size: 18,
                  ),
                  label: Text(
                    _vertical
                        ? 'Swipe up/down to flip'
                        : 'Swipe left/right to flip',
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 250,
                  child: FlipCardPlus(
                    flipOnDrag: true,
                    flipOnTouch: false,
                    dragThreshold: 0.4,
                    direction: _vertical ? Axis.vertical : Axis.horizontal,
                    duration: const Duration(milliseconds: 400),
                    front: _CardFace(
                      label: 'Question',
                      sub: 'Drag to reveal the answer',
                      color: cs.primary,
                      icon: Icons.help_outline,
                    ),
                    back: _CardFace(
                      label: 'Answer',
                      sub: 'Drag back to see the question',
                      color: cs.tertiary,
                      icon: Icons.check_circle_outline,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          SwitchListTile(
            title: const Text('Vertical drag'),
            value: _vertical,
            onChanged: (v) => setState(() => _vertical = v),
          ),
        ],
      ),
    );
  }
}

// ── Page 3 — Style (curve + borderRadius) ─────────────────────────────────

class _CurveOption {
  const _CurveOption(this.name, this.curve);
  final String name;
  final Curve curve;
}

const _curveOptions = [
  _CurveOption('Linear', Curves.linear),
  _CurveOption('Ease In/Out', Curves.easeInOut),
  _CurveOption('Elastic Out', Curves.elasticOut),
  _CurveOption('Bounce Out', Curves.bounceOut),
  _CurveOption('Back', _BackCurve()),
];

/// A smooth back-ease curve (overshoot).
class _BackCurve extends Curve {
  const _BackCurve();

  @override
  double transform(double t) {
    const c1 = 1.70158;
    const c2 = c1 * 1.525;
    if (t < 0.5) {
      final x = 2 * t;
      return (x * x * ((c2 + 1) * x - c2)) / 2;
    }
    final x = 2 * t - 2;
    return (x * x * ((c2 + 1) * x + c2) + 2) / 2;
  }
}

class _StylePage extends StatefulWidget {
  const _StylePage();

  @override
  State<_StylePage> createState() => _StylePageState();
}

class _StylePageState extends State<_StylePage> {
  final _controller = FlipCardPlusController();
  int _curveIndex = 0;
  double _radius = 24;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final selected = _curveOptions[_curveIndex];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Center(
            child: SizedBox(
              width: double.infinity,
              height: 220,
              child: FlipCardPlus(
                controller: _controller,
                curve: selected.curve,
                reverseCurve: Curves.easeOut,
                borderRadius: BorderRadius.circular(_radius),
                duration: const Duration(milliseconds: 700),
                front: _CardFace(
                  label: 'Front',
                  sub: 'Curve: ${selected.name}\n'
                      'Radius: ${_radius.toStringAsFixed(0)} px',
                  color: cs.primary,
                  icon: Icons.palette_outlined,
                ),
                back: _CardFace(
                  label: 'Back',
                  sub: 'Tap Toggle to feel the curve',
                  color: cs.secondary,
                  icon: Icons.auto_fix_high_outlined,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => _controller.flip(),
            icon: const Icon(Icons.flip),
            label: const Text('Toggle'),
          ),
          const SizedBox(height: 24),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Curve',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (int i = 0; i < _curveOptions.length; i++)
                ChoiceChip(
                  label: Text(_curveOptions[i].name),
                  selected: _curveIndex == i,
                  onSelected: (_) => setState(() => _curveIndex = i),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Text(
                'Corner radius',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: Slider(
                  value: _radius,
                  min: 0,
                  max: 64,
                  divisions: 8,
                  label: _radius.toStringAsFixed(0),
                  onChanged: (v) => setState(() => _radius = v),
                ),
              ),
              SizedBox(
                width: 32,
                child: Text(
                  _radius.toStringAsFixed(0),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Page 4 — Control (isDisabled + onFlipStart + flipCount) ───────────────

class _ControlPage extends StatefulWidget {
  const _ControlPage();

  @override
  State<_ControlPage> createState() => _ControlPageState();
}

class _ControlPageState extends State<_ControlPage> {
  final _controller = FlipCardPlusController();
  bool _disabled = false;
  int _flipCount = 0;
  final List<String> _log = [];

  void _onFlipStart(CardSide from, CardSide to) {
    setState(() {
      _flipCount++;
      _log.insert(0, '#$_flipCount  ${from.name} → ${to.name}');
      if (_log.length > 8) _log.removeLast();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 220,
            child: FlipCardPlus(
              controller: _controller,
              isDisabled: _disabled,
              onFlipStart: _onFlipStart,
              borderRadius: BorderRadius.circular(20),
              duration: const Duration(milliseconds: 500),
              front: _CardFace(
                label: 'Front',
                sub: _disabled ? '🔒 Card is locked' : 'Tap to flip',
                color: _disabled ? Colors.grey.shade700 : cs.primary,
                icon: _disabled ? Icons.lock_outline : Icons.lock_open_outlined,
              ),
              back: _CardFace(
                label: 'Back',
                sub: 'Flip count: $_flipCount',
                color: cs.secondary,
                icon: Icons.bar_chart_outlined,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton.icon(
                onPressed: _disabled ? null : () => _controller.flip(),
                icon: const Icon(Icons.flip),
                label: const Text('Toggle'),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () => setState(() => _disabled = !_disabled),
                icon: Icon(
                  _disabled ? Icons.lock_open : Icons.lock_outline,
                ),
                label: Text(_disabled ? 'Enable' : 'Disable'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'onFlipStart log',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          const SizedBox(height: 8),
          _log.isEmpty
              ? Container(
                  height: 100,
                  alignment: Alignment.center,
                  child: Text(
                    'No flips yet — tap the card.',
                    style: TextStyle(
                      color: cs.onSurface.withAlpha(100),
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _log.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) => ListTile(
                    dense: true,
                    leading: Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: cs.primary,
                    ),
                    title: Text(
                      _log[i],
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

class _AdvancedPage extends StatefulWidget {
  const _AdvancedPage();

  @override
  State<_AdvancedPage> createState() => _AdvancedPageState();
}

class _AdvancedPageState extends State<_AdvancedPage> {
  double _perspective = 0.002;
  double _elevation = 10.0;
  bool _isRtl = false;
  bool _useRepaintBoundary = true;
  Clip _clipBehavior = Clip.antiAlias;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Section 1: Hover-to-flip
          const Text(
            'Hover-to-Flip',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            'Hover over this card with a mouse pointer to flip it. Exiting hover flips it back.',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Center(
            child: SizedBox(
              width: double.infinity,
              height: 180,
              child: FlipCardPlus(
                flipOnHover: true,
                flipOnTouch: false,
                borderRadius: BorderRadius.circular(16),
                front: _CardFace(
                  label: 'Hover Me',
                  sub: 'Hover enter to flip',
                  color: cs.primary,
                  icon: Icons.mouse_outlined,
                ),
                back: _CardFace(
                  label: 'Thanks!',
                  sub: 'Hover exit to return',
                  color: cs.secondary,
                  icon: Icons.emoji_emotions_outlined,
                ),
              ),
            ),
          ),
          const Divider(height: 32),

          // Section 2: Custom Perspective & Dynamic Shadow
          const Text(
            'Perspective & Dynamic Shadow',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            'Adjust sliders to customize the 3D perspective and dynamic shadow elevation. Notice the shadow lift and blur dynamically during flip rotation!',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Center(
            child: SizedBox(
              width: double.infinity,
              height: 200,
              child: FlipCardPlus(
                perspective: _perspective,
                elevation: _elevation,
                // ignore: deprecated_member_use
                shadowColor: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(20),
                duration: const Duration(milliseconds: 800),
                front: _CardFace(
                  label: '3D & Shadow',
                  sub: 'Tap to see the dynamic shadow lift',
                  color: cs.tertiary,
                  icon: Icons.layers_outlined,
                ),
                back: _CardFace(
                  label: 'Midpoint Lift',
                  sub: 'Blur/offset scale dynamically',
                  color: cs.primary,
                  icon: Icons.bubble_chart_outlined,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Perspective Slider
          Row(
            children: [
              const Text(
                '3D Perspective',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              Expanded(
                child: Slider(
                  value: _perspective,
                  min: 0.0,
                  max: 0.005,
                  divisions: 10,
                  label: _perspective.toStringAsFixed(4),
                  onChanged: (v) => setState(() => _perspective = v),
                ),
              ),
              SizedBox(
                width: 50,
                child: Text(
                  _perspective == 0.0
                      ? 'Flat'
                      : _perspective.toStringAsFixed(4),
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
          // Elevation Slider
          Row(
            children: [
              const Text(
                'Shadow Elevation',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              Expanded(
                child: Slider(
                  value: _elevation,
                  min: 0.0,
                  max: 24.0,
                  divisions: 12,
                  label: _elevation.toStringAsFixed(0),
                  onChanged: (v) => setState(() => _elevation = v),
                ),
              ),
              SizedBox(
                width: 50,
                child: Text(
                  '${_elevation.toStringAsFixed(0)} px',
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
          const Divider(height: 32),

          // Section 3: RTL-Aware Flipping
          const Text(
            'RTL-Aware Flipping',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            'In RTL layouts, horizontal flips and drag-gestures automatically mirror. Tap/swipe to feel the flipped direction.',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Directionality(
            textDirection: _isRtl ? TextDirection.rtl : TextDirection.ltr,
            child: SizedBox(
              width: double.infinity,
              height: 180,
              child: FlipCardPlus(
                flipOnDrag: true,
                flipOnTouch: true,
                front: _CardFace(
                  label: _isRtl ? 'يمين إلى يسار (RTL)' : 'Left to Right (LTR)',
                  sub: 'Swipe or Tap to flip',
                  color: cs.secondary,
                  icon: Icons.translate_outlined,
                ),
                back: _CardFace(
                  label: 'Flipped!',
                  sub: 'Drag direction matches text directionality',
                  color: cs.tertiary,
                  icon: Icons.swap_horiz_outlined,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('Simulate RTL text direction'),
            value: _isRtl,
            onChanged: (v) => setState(() => _isRtl = v),
          ),
          const Divider(height: 32),

          // Section 4: Performance Isolations (Advanced)
          const Text(
            'Performance & Repaint Isolation',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            'Toggle RepaintBoundary to isolate card repaints from the parent tree, and adjust corner clipping behavior to optimize GPU resources.',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Center(
            child: SizedBox(
              width: double.infinity,
              height: 180,
              child: FlipCardPlus(
                useRepaintBoundary: _useRepaintBoundary,
                clipBehavior: _clipBehavior,
                borderRadius: BorderRadius.circular(24),
                front: _CardFace(
                  label: 'Performance Card',
                  sub:
                      'RepaintBoundary: ${_useRepaintBoundary ? "ON" : "OFF"}\nClip: ${_clipBehavior.name}',
                  color: cs.primary,
                  icon: Icons.speed_outlined,
                ),
                back: _CardFace(
                  label: 'Render Isolated',
                  sub: 'Tap card to flip and verify repaint boundaries',
                  color: cs.secondary,
                  icon: Icons.memory_outlined,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('Use RepaintBoundary'),
            subtitle: const Text(
                'Isolates paint cycles of card faces during rotation'),
            value: _useRepaintBoundary,
            onChanged: (v) => setState(() => _useRepaintBoundary = v),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              'Corner Clip Behavior',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<Clip>(
              segments: const [
                ButtonSegment<Clip>(
                  value: Clip.antiAlias,
                  label: Text('Anti-Alias'),
                  icon: Icon(Icons.blur_on),
                ),
                ButtonSegment<Clip>(
                  value: Clip.hardEdge,
                  label: Text('Hard Edge'),
                  icon: Icon(Icons.grid_on),
                ),
                ButtonSegment<Clip>(
                  value: Clip.none,
                  label: Text('None'),
                  icon: Icon(Icons.highlight_off),
                ),
              ],
              selected: {_clipBehavior},
              onSelectionChanged: (Set<Clip> newSelection) {
                setState(() {
                  _clipBehavior = newSelection.first;
                });
              },
            ),
          ),
          const Divider(height: 32),

          // Section 5: Platform-Specific Adaptive Card
          const Text(
            'Platform-Specific Adaptations',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            'This card dynamically adapts its interaction features based on the platform. Desktop platforms enable hover-to-flip, while mobile platforms enable drag-to-flip and trigger haptic feedback on flip completion.',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Center(
            child: SizedBox(
              width: double.infinity,
              height: 180,
              child: Builder(
                builder: (context) {
                  final platform = Theme.of(context).platform;
                  final isDesktop = platform == TargetPlatform.windows ||
                      platform == TargetPlatform.macOS ||
                      platform == TargetPlatform.linux;
                  return FlipCardPlus(
                    flipOnHover: isDesktop,
                    flipOnTouch: true,
                    flipOnDrag: !isDesktop,
                    onFlipStart: (fromSide, toSide) {
                      // Trigger haptic feedback on mobile devices
                      if (!isDesktop) {
                        HapticFeedback.lightImpact();
                      }
                    },
                    borderRadius: BorderRadius.circular(20),
                    front: _CardFace(
                      label: isDesktop
                          ? 'Desktop Mode (Windows/macOS)'
                          : 'Mobile Mode (iOS/Android)',
                      sub: isDesktop
                          ? 'Hover with mouse or click to flip'
                          : 'Swipe/drag or tap to flip (Haptics active)',
                      color: isDesktop ? Colors.blueAccent : Colors.tealAccent,
                      icon: isDesktop
                          ? Icons.desktop_windows
                          : Icons.phone_iphone,
                    ),
                    back: _CardFace(
                      label: 'Adaptive Flipped!',
                      sub: 'Platform: ${platform.name.toUpperCase()}',
                      color: cs.secondary,
                      icon: Icons.check_circle_outline,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShowcasesPage extends StatefulWidget {
  const _ShowcasesPage();

  @override
  State<_ShowcasesPage> createState() => _ShowcasesPageState();
}

class _ShowcasesPageState extends State<_ShowcasesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.credit_card), text: 'Credit Card'),
            Tab(icon: Icon(Icons.grid_on), text: 'Memory Match'),
            Tab(icon: Icon(Icons.shopping_bag), text: 'E-Commerce'),
            Tab(icon: Icon(Icons.school), text: 'Flashcards'),
            Tab(icon: Icon(Icons.badge), text: 'Business Card'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              _CreditCardShowcase(),
              _MemoryGameShowcase(),
              _EcommerceShowcase(),
              _FlashcardShowcase(),
              _BusinessCardShowcase(),
            ],
          ),
        ),
      ],
    );
  }
}

class _CreditCardShowcase extends StatefulWidget {
  const _CreditCardShowcase();

  @override
  State<_CreditCardShowcase> createState() => _CreditCardShowcaseState();
}

class _CreditCardShowcaseState extends State<_CreditCardShowcase> {
  final _controller = FlipCardPlusController();
  bool _useVertical = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Interactive Payment Card',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w300,
              letterSpacing: 0.8,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap or swipe card to see the security code on the back.',
            style:
                TextStyle(color: cs.onSurface.withOpacity(0.6), fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Center(
            child: SizedBox(
              width: 320,
              height: 200,
              child: FlipCardPlus(
                controller: _controller,
                flipOnDrag: true,
                direction: _useVertical ? Axis.vertical : Axis.horizontal,
                perspective: 0.0015,
                elevation: 0.0,
                borderRadius: BorderRadius.circular(16),
                front: Container(
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: cs.outline,
                      width: 1.5,
                    ),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'PREMIUM PLATINUM',
                                style: TextStyle(
                                  color: cs.onSurface.withOpacity(0.5),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'FlipCardPlus',
                                style: TextStyle(
                                  color: cs.onSurface,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w300,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          Icon(Icons.wifi,
                              color: cs.onSurface.withOpacity(0.4), size: 20),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            width: 42,
                            height: 30,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: cs.onSurface.withOpacity(0.2),
                                  width: 1.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Stack(
                              children: [
                                Positioned(
                                  top: 10,
                                  left: 0,
                                  right: 0,
                                  height: 1,
                                  child: Container(
                                      color: cs.onSurface.withOpacity(0.2)),
                                ),
                                Positioned(
                                  left: 14,
                                  top: 0,
                                  bottom: 0,
                                  width: 1,
                                  child: Container(
                                      color: cs.onSurface.withOpacity(0.2)),
                                ),
                                Positioned(
                                  right: 14,
                                  top: 0,
                                  bottom: 0,
                                  width: 1,
                                  child: Container(
                                      color: cs.onSurface.withOpacity(0.2)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '7786  5432  1098  9900',
                        style: TextStyle(
                          color: cs.onSurface,
                          fontSize: 18,
                          fontFamily: 'monospace',
                          letterSpacing: 2,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CARDHOLDER',
                                style: TextStyle(
                                    color: cs.onSurface.withOpacity(0.4),
                                    fontSize: 8),
                              ),
                              Text(
                                'HADI',
                                style: TextStyle(
                                    color: cs.onSurface.withOpacity(0.8),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'EXPIRES',
                                style: TextStyle(
                                    color: cs.onSurface.withOpacity(0.4),
                                    fontSize: 8),
                              ),
                              Text(
                                '12/29',
                                style: TextStyle(
                                    color: cs.onSurface.withOpacity(0.8),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: cs.onSurface.withOpacity(0.4),
                                      width: 1.2),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Positioned(
                                left: 10,
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: cs.onSurface.withOpacity(0.4),
                                        width: 1.2),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                back: Container(
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: cs.outline,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),
                      Container(
                        height: 40,
                        color: Colors.black,
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Container(
                                height: 35,
                                decoration: BoxDecoration(
                                  color: cs.brightness == Brightness.dark
                                      ? const Color(0xFF1C1C1E)
                                      : const Color(0xFFE5E5EA),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.only(left: 8),
                                child: Text(
                                  'Hadi Signature',
                                  style: TextStyle(
                                    color: cs.onSurface.withOpacity(0.4),
                                    fontStyle: FontStyle.italic,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 50,
                              height: 35,
                              decoration: BoxDecoration(
                                border: Border.all(color: cs.outline),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '999',
                                style: TextStyle(
                                  color: cs.onSurface,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'monospace',
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'For customer service call +1 (800) FLIP-PLUS. Issued under license by FlipCardPlus Labs.',
                          style: TextStyle(
                              color: cs.onSurface.withOpacity(0.3),
                              fontSize: 8),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton.icon(
                onPressed: () => _controller.flip(),
                icon: const Icon(Icons.flip, size: 18),
                label: const Text('Flip Card'),
              ),
              const SizedBox(width: 16),
              OutlinedButton.icon(
                onPressed: () => setState(() => _useVertical = !_useVertical),
                icon: Icon(_useVertical ? Icons.swipe_vertical : Icons.swipe,
                    size: 18),
                label: Text(_useVertical ? 'Vertical' : 'Horizontal'),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const _ShowcaseExplanation(
            title: 'Interactive Payment Card Showcase',
            description:
                'This showcase demonstrates how FlipCardPlus can be used to build a realistic 3D payment card interface. It highlights horizontal/vertical swipe-to-reveal animations, custom 3D perspective depth, and theme adaptation. The signature and CVV are hidden on the back of the card, mimicking real-world payment flows.',
          ),
        ],
      ),
    );
  }
}

class _MemoryGameShowcase extends StatefulWidget {
  const _MemoryGameShowcase();

  @override
  State<_MemoryGameShowcase> createState() => _MemoryGameShowcaseState();
}

class _MemoryGameShowcaseState extends State<_MemoryGameShowcase> {
  final List<IconData> _symbols = [
    Icons.radio_button_unchecked,
    Icons.radio_button_unchecked,
    Icons.crop_square,
    Icons.crop_square,
    Icons.change_history,
    Icons.change_history,
    Icons.star_border,
    Icons.star_border,
    Icons.close,
    Icons.close,
    Icons.remove,
    Icons.remove,
  ];

  late List<bool> _flipped;
  late List<bool> _matched;
  late List<FlipCardPlusController> _controllers;

  int? _firstSelectedIndex;
  bool _busy = false;
  int _moves = 0;
  int _pairsMatched = 0;

  @override
  void initState() {
    super.initState();
    _resetGame();
  }

  void _resetGame() {
    _symbols.shuffle();
    _flipped = List.filled(12, false);
    _matched = List.filled(12, false);
    _controllers = List.generate(12, (_) => FlipCardPlusController());
    _firstSelectedIndex = null;
    _busy = false;
    _moves = 0;
    _pairsMatched = 0;
    setState(() {});
  }

  void _onCardTap(int index) async {
    if (_busy || _flipped[index] || _matched[index]) return;

    setState(() {
      _flipped[index] = true;
    });
    await _controllers[index].flip();

    if (_firstSelectedIndex == null) {
      _firstSelectedIndex = index;
    } else {
      _moves++;
      final firstIndex = _firstSelectedIndex!;
      if (_symbols[firstIndex] == _symbols[index]) {
        setState(() {
          _matched[firstIndex] = true;
          _matched[index] = true;
          _pairsMatched++;
        });
        _firstSelectedIndex = null;
      } else {
        _busy = true;
        await Future.delayed(const Duration(milliseconds: 1000));
        setState(() {
          _flipped[firstIndex] = false;
          _flipped[index] = false;
        });
        await Future.wait([
          _controllers[firstIndex].flip(),
          _controllers[index].flip(),
        ]);
        _firstSelectedIndex = null;
        _busy = false;
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Moves: $_moves',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: cs.onSurface.withOpacity(0.6)),
              ),
              Text(
                'Matches: $_pairsMatched / 6',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: cs.onSurface.withOpacity(0.6)),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, size: 18),
                onPressed: _resetGame,
                tooltip: 'Reset Game',
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.85,
            ),
            itemCount: 12,
            itemBuilder: (context, index) {
              final isMatched = _matched[index];
              return FlipCardPlus(
                controller: _controllers[index],
                flipOnTouch: false,
                front: InkWell(
                  onTap: () => _onCardTap(index),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: cs.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: cs.outline,
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.question_mark_rounded,
                        size: 20,
                        color: isMatched
                            ? cs.onSurface.withOpacity(0.1)
                            : cs.onSurface.withOpacity(0.3),
                      ),
                    ),
                  ),
                ),
                back: Container(
                  decoration: BoxDecoration(
                    color: cs.brightness == Brightness.dark
                        ? const Color(0xFF1C1C1E)
                        : const Color(0xFFE5E5EA),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isMatched ? cs.primary : cs.outline,
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      _symbols[index],
                      size: 28,
                      color: isMatched
                          ? cs.primary
                          : cs.onSurface.withOpacity(0.7),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          if (_pairsMatched == 6) ...[
            Text(
              'Excellent memory.',
              style: TextStyle(
                  color: cs.onSurface.withOpacity(0.8),
                  fontSize: 15,
                  fontWeight: FontWeight.w300),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 16),
          const _ShowcaseExplanation(
            title: 'Memory Match Game Showcase',
            description:
                'A classic memory matching game built with a grid of 12 FlipCardPlus widgets. Flipping is controlled programmatically via FlipCardPlusController (touch flipping is disabled). It demonstrates state management, batch flipping, and matched card persistence.',
          ),
        ],
      ),
    );
  }
}

class _EcommerceShowcase extends StatefulWidget {
  const _EcommerceShowcase();

  @override
  State<_EcommerceShowcase> createState() => _EcommerceShowcaseState();
}

class _EcommerceShowcaseState extends State<_EcommerceShowcase> {
  final _controller = FlipCardPlusController();
  String _selectedColor = 'Matte Black';
  String _selectedSize = 'Standard';
  bool _addedToCart = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          Center(
            child: SizedBox(
              width: 300,
              height: 380,
              child: FlipCardPlus(
                controller: _controller,
                flipOnTouch: false,
                borderRadius: BorderRadius.circular(20),
                elevation: 0.0,
                front: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: cs.surface,
                    border: Border.all(color: cs.outline),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          Container(
                            height: 160,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: cs.brightness == Brightness.dark
                                  ? const Color(0xFF1C1C1E)
                                  : const Color(0xFFE5E5EA),
                              border: Border.all(color: cs.outline),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.headphones_outlined,
                                size: 64,
                                color: cs.onSurface.withOpacity(0.3),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: cs.primary),
                              ),
                              child: Text(
                                'SALE',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: cs.primary,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'AeroSound Pro Plus',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: cs.onSurface),
                          ),
                          Text(
                            '\$199.99',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w300,
                                color: cs.primary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 14),
                          const Icon(Icons.star, color: Colors.amber, size: 14),
                          const Icon(Icons.star, color: Colors.amber, size: 14),
                          const Icon(Icons.star, color: Colors.amber, size: 14),
                          Icon(Icons.star_half,
                              color: cs.onSurface.withOpacity(0.3), size: 14),
                          const SizedBox(width: 6),
                          Text(
                            '4.8 (124 reviews)',
                            style: TextStyle(
                                color: cs.onSurface.withOpacity(0.5),
                                fontSize: 11),
                          ),
                        ],
                      ),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () => _controller.flip(),
                          icon: const Icon(Icons.tune, size: 16),
                          label: const Text('Customize & Buy'),
                        ),
                      ),
                    ],
                  ),
                ),
                back: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: cs.surface,
                    border: Border.all(color: cs.outline),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Customize Specs',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: cs.onSurface),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () => _controller.flip(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Select Color',
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            color: cs.onSurface.withOpacity(0.5)),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children:
                            ['Matte Black', 'Ocean Blue', 'Rose Gold'].map((c) {
                          final isSelected = _selectedColor == c;
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ChoiceChip(
                              label: Text(
                                c,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isSelected
                                      ? cs.primary
                                      : cs.onSurface.withOpacity(0.7),
                                ),
                              ),
                              selected: isSelected,
                              onSelected: (_) =>
                                  setState(() => _selectedColor = c),
                              backgroundColor: Colors.transparent,
                              selectedColor: cs.primary.withOpacity(0.08),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                                side: BorderSide(
                                  color: isSelected ? cs.primary : cs.outline,
                                ),
                              ),
                              showCheckmark: false,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Cushion Size',
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            color: cs.onSurface.withOpacity(0.5)),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: ['Standard', 'Extra Cushioned'].map((s) {
                          final isSelected = _selectedSize == s;
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ChoiceChip(
                              label: Text(
                                s,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isSelected
                                      ? cs.primary
                                      : cs.onSurface.withOpacity(0.7),
                                ),
                              ),
                              selected: isSelected,
                              onSelected: (_) =>
                                  setState(() => _selectedSize = s),
                              backgroundColor: Colors.transparent,
                              selectedColor: cs.primary.withOpacity(0.08),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                                side: BorderSide(
                                  color: isSelected ? cs.primary : cs.outline,
                                ),
                              ),
                              showCheckmark: false,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Specs: 30hr Playtime, Active Noise Cancelling, Premium Bluetooth 5.3 Audio.',
                        style: TextStyle(
                            fontSize: 11,
                            color: cs.onSurface.withOpacity(0.5),
                            height: 1.4),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () {
                            setState(() {
                              _addedToCart = true;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Added $_selectedColor AeroSound Pro ($_selectedSize) to Cart!',
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                            _controller.flip();
                          },
                          icon: Icon(
                              _addedToCart ? Icons.check : Icons.shopping_cart,
                              size: 16),
                          label: Text(_addedToCart
                              ? 'Added to Cart'
                              : 'Add to Cart (\$199.99)'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const _ShowcaseExplanation(
            title: 'E-Commerce Customizer Showcase',
            description:
                'An interactive product card that flips to reveal customization options. It features custom choice chips, rating stars, and add-to-cart integration. Flipping is triggered via action buttons, demonstrating how the card can act as a container for detailed forms or product attributes.',
          ),
        ],
      ),
    );
  }
}

class _FlashcardShowcase extends StatefulWidget {
  const _FlashcardShowcase();

  @override
  State<_FlashcardShowcase> createState() => _FlashcardShowcaseState();
}

class _FlashcardShowcaseState extends State<_FlashcardShowcase> {
  final _controller = FlipCardPlusController();
  int _currentIndex = 0;
  int _score = 0;

  static const _cards = [
    {
      'q': 'What is the purpose of RepaintBoundary?',
      'a':
          'It isolates repaint cycles, meaning when this widget paints, it does not force its parent or sibling widgets to repaint.',
    },
    {
      'q': 'How does Clip.hardEdge optimize performance?',
      'a':
          'It clips using faster stencil/scissor paths on the GPU, avoiding offscreen save-layer allocations required by Clip.antiAlias.',
    },
    {
      'q': 'Why cache Animation objects in FlipCard?',
      'a':
          'To avoid creating 4 new animation objects per frame tick, reducing Garbage Collection allocations to exactly zero.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final card = _cards[_currentIndex];
    final cs = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Score: $_score / ${_cards.length}',
                style: TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: 13,
                    color: cs.onSurface.withOpacity(0.6)),
              ),
              Text(
                'Card ${_currentIndex + 1} of ${_cards.length}',
                style: TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: 13,
                    color: cs.onSurface.withOpacity(0.6)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: (_currentIndex + 1) / _cards.length,
              backgroundColor: cs.outline,
              valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
              minHeight: 3,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 200,
            child: FlipCardPlus(
              controller: _controller,
              elevation: 0.0,
              front: Container(
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: cs.outline),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'QUESTION',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            color: cs.onSurface.withOpacity(0.4)),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        card['q']!,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w300,
                            height: 1.4,
                            color: cs.onSurface),
                        textAlign: TextAlign.center,
                      ),
                      const Spacer(),
                      Text(
                        'Tap to reveal answer',
                        style: TextStyle(
                            fontSize: 11, color: cs.onSurface.withOpacity(0.4)),
                      ),
                    ],
                  ),
                ),
              ),
              back: Container(
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: cs.outline),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'ANSWER',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            color: cs.onSurface.withOpacity(0.4)),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        card['a']!,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w300,
                            color: cs.onSurface.withOpacity(0.8),
                            height: 1.4),
                        textAlign: TextAlign.center,
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                _score++;
                                _nextCard();
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: cs.outline),
                              foregroundColor: cs.onSurface,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                            ),
                            icon:
                                Icon(Icons.check, color: cs.primary, size: 14),
                            label: const Text('Got it!',
                                style: TextStyle(fontSize: 12)),
                          ),
                          OutlinedButton.icon(
                            onPressed: _nextCard,
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: cs.outline),
                              foregroundColor: cs.onSurface,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                            ),
                            icon: Icon(Icons.refresh,
                                color: cs.onSurface.withOpacity(0.6), size: 14),
                            label: const Text('Practice',
                                style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const _ShowcaseExplanation(
            title: 'Interactive Learning Flashcards',
            description:
                'An educational study card system demonstrating progress tracking and programmatic flipping. When the user flips without animation to reset the side, it showcases instant side-switching using flipWithoutAnimation().',
          ),
        ],
      ),
    );
  }

  void _nextCard() {
    _controller.flipWithoutAnimation();
    setState(() {
      _currentIndex = (_currentIndex + 1) % _cards.length;
    });
  }
}

class _BusinessCardShowcase extends StatelessWidget {
  const _BusinessCardShowcase();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Center(
            child: SizedBox(
              width: 320,
              height: 180,
              child: FlipCardPlus(
                flipOnHover: true,
                flipOnTouch: true,
                elevation: 0.0,
                borderRadius: BorderRadius.circular(12),
                front: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: cs.surface,
                    border: Border.all(color: cs.outline),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: cs.outline, width: 1.2),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'H',
                          style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w200,
                              color: cs.onSurface),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Hadi',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w300,
                                  color: cs.onSurface,
                                  letterSpacing: 0.5),
                            ),
                            Text(
                              'Lead Architect & Creator',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: cs.onSurface.withOpacity(0.6),
                                  fontWeight: FontWeight.w300),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'hadi7786x@gmail.com',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: cs.onSurface.withOpacity(0.7),
                                  fontFamily: 'monospace'),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'github.com/Itsxhadi',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: cs.onSurface.withOpacity(0.7),
                                  fontFamily: 'monospace'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                back: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: cs.surface,
                    border: Border.all(color: cs.outline),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Scan to Connect',
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  color: cs.onSurface),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Hover or tap to check details on the front.',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: cs.onSurface.withOpacity(0.5)),
                            ),
                            const SizedBox(height: 16),
                            FilledButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Contact details saved!'),
                                  ),
                                );
                              },
                              child: const Text('Save Info',
                                  style: TextStyle(fontSize: 11)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: cs.onSurface.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: cs.outline),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            crossAxisSpacing: 3,
                            mainAxisSpacing: 3,
                          ),
                          itemCount: 25,
                          itemBuilder: (context, i) {
                            final isDark = (i * i + i * 3) % 2 == 0;
                            return Container(
                              decoration: BoxDecoration(
                                color: isDark
                                    ? cs.onSurface.withOpacity(0.7)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(1),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const _ShowcaseExplanation(
            title: 'Interactive Business Card',
            description:
                'A premium digital business card showing profile info on the front and contact actions/QR code on the back. It demonstrates the use of hover-to-flip on desktop and tap-to-flip on mobile, showing adaptive user experience.',
          ),
        ],
      ),
    );
  }
}

class _ShowcaseExplanation extends StatelessWidget {
  const _ShowcaseExplanation({required this.title, required this.description});
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      color: cs.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cs.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, size: 18, color: cs.primary),
                const SizedBox(width: 8),
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 8),
            Text(description,
                style: TextStyle(
                    fontSize: 12,
                    color: cs.onSurface.withOpacity(0.7),
                    height: 1.4)),
          ],
        ),
      ),
    );
  }
}
