import 'package:flutter/material.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UI/UX Component Simulator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF06060a),
      ),
      home: const SimulatorHome(),
    );
  }
}

class SimulatorHome extends StatefulWidget {
  const SimulatorHome({super.key});

  @override
  State<SimulatorHome> createState() => _SimulatorHomeState();
}

class _SimulatorHomeState extends State<SimulatorHome>
    with SingleTickerProviderStateMixin {
  bool _drawerOpen = true;
  late final AnimationController _drawerController;
  late final Animation<double> _drawerAnim;
  static const double _drawerWidth = 400;

  Color desktopHeaderColor = const Color(0xFF0f1117);
  Color desktopSidebarColor = const Color(0xFF0c0c12);
  Color desktopToolbarColor = const Color(0xFF0e0e15);
  Color desktopMainColor = const Color(0xFF111118);
  Color desktopStatusbarColor = const Color(0xFF09090f);

  Color mobileAppbarColor = const Color(0xFF0f1117);
  Color mobileContentColor = const Color(0xFF111118);
  Color mobileCard1Color = const Color(0xFF141420);
  Color mobileCard2Color = const Color(0xFF141420);
  Color mobileBottomNavColor = const Color(0xFF0c0c12);
  Color mobileFabColor = const Color(0xFFe8e8ee);
  bool _isDarkMode = true;
  Color _getBackgroundColor() {
    return _isDarkMode ? const Color(0xFF06060a) : const Color(0xFFF5F5F5);
  }

  void _applyRandomDarkTheme() {
    final baseHue = (DateTime.now().millisecondsSinceEpoch % 360).toDouble();
    const fibShifts = [0, 13, 21, 34, 55, 89];

    // 5 desktop colors — dark, low lightness, subtle hue drift via Fibonacci
    final desktopColors = List.generate(5, (i) {
      final hue = (baseHue + fibShifts[i]) % 360;
      final lightness = 0.06 + (fibShifts[i] % 6) * 0.008; // 0.06 → ~0.10
      return HSLColor.fromAHSL(1.0, hue, 0.18, lightness).toColor();
    });

    // 5 mobile body colors + 1 light FAB
    final mobileColors = [
      ...List.generate(5, (i) {
        final hue = (baseHue + fibShifts[i + 1]) % 360;
        final lightness = 0.07 + (fibShifts[i] % 5) * 0.009;
        return HSLColor.fromAHSL(1.0, hue, 0.18, lightness).toColor();
      }),
      const Color(0xFFe8e8ee), // FAB stays light for contrast
    ];

    setState(() => _isDarkMode = true);
    _applyFibPalette(desktopColors, mobileColors);
  }

  void _applyRandomLightTheme() {
    final baseHue = (DateTime.now().millisecondsSinceEpoch % 360).toDouble();
    const fibShifts = [0, 13, 21, 34, 55, 89];

    // 5 desktop colors — light, high lightness, subtle hue drift via Fibonacci
    final desktopColors = List.generate(5, (i) {
      final hue = (baseHue + fibShifts[i]) % 360;
      final lightness = (0.91 + (fibShifts[i] % 5) * 0.008).clamp(0.0, 1.0);
      return HSLColor.fromAHSL(1.0, hue, 0.10, lightness).toColor();
    });

    // 5 mobile body colors + 1 dark FAB
    final mobileColors = [
      ...List.generate(5, (i) {
        final hue = (baseHue + fibShifts[i + 1]) % 360;
        final lightness = (0.92 + (fibShifts[i] % 4) * 0.009).clamp(0.0, 1.0);
        return HSLColor.fromAHSL(1.0, hue, 0.10, lightness).toColor();
      }),
      const Color(0xFF1a1a2e), // FAB stays dark for contrast
    ];

    setState(() => _isDarkMode = false);
    _applyFibPalette(desktopColors, mobileColors);
  }

  void _applyFibPalette(List<Color> desktop, List<Color> mobile) {
    setState(() {
      if (desktop.length == 5) {
        desktopHeaderColor = desktop[0];
        desktopSidebarColor = desktop[1];
        desktopToolbarColor = desktop[2];
        desktopMainColor = desktop[3];
        desktopStatusbarColor = desktop[4];
      }
      if (mobile.length == 6) {
        mobileAppbarColor = mobile[0];
        mobileContentColor = mobile[1];
        mobileCard1Color = mobile[2];
        mobileCard2Color = mobile[3];
        mobileBottomNavColor = mobile[4];
        mobileFabColor = mobile[5];
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _drawerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
      value: 1.0,
    );
    _drawerAnim =
        CurvedAnimation(parent: _drawerController, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _drawerController.dispose();
    super.dispose();
  }

  void _toggleDrawer() {
    setState(() => _drawerOpen = !_drawerOpen);
    _drawerOpen ? _drawerController.forward() : _drawerController.reverse();
  }

  void resetDesktop() {
    setState(() {
      desktopHeaderColor = const Color(0xFF0f1117);
      desktopSidebarColor = const Color(0xFF0c0c12);
      desktopToolbarColor = const Color(0xFF0e0e15);
      desktopMainColor = const Color(0xFF111118);
      desktopStatusbarColor = const Color(0xFF09090f);
    });
  }

  void resetMobile() {
    setState(() {
      mobileAppbarColor = const Color(0xFF0f1117);
      mobileContentColor = const Color(0xFF111118);
      mobileCard1Color = const Color(0xFF141420);
      mobileCard2Color = const Color(0xFF141420);
      mobileBottomNavColor = const Color(0xFF0c0c12);
      mobileFabColor = const Color(0xFFe8e8ee);
    });
  }

  void _showPicker(
    BuildContext context,
    String label,
    Color current,
    ValueChanged<Color> onChanged,
  ) async {
    final Color? newColor = await showColorPickerDialog(
      context,
      current,
      title: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      width: 40,
      spacing: 6,
      runSpacing: 6,
      elevation: 2,
      showRecentColors: true,
      maxRecentColors: 10,
      pickersEnabled: <ColorPickerType, bool>{
        ColorPickerType.wheel: true,
        ColorPickerType.primary: true,
        ColorPickerType.accent: true,
        ColorPickerType.bw: true,
        ColorPickerType.custom: true,
      },
      enableOpacity: true,
      customColorSwatchesAndNames: <ColorSwatch<Object>, String>{
        const MaterialColor(0xFF1e1e2e, <int, Color>{
          50: Color(0xFFe8e8ee),
          100: Color(0xFFc8c8d4),
        }): 'Dark Theme',
        Colors.blueGrey: 'Blue Grey',
      },
    );

    if (newColor != null && newColor != current) {
      setState(() => onChanged(newColor));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _getBackgroundColor(),
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _drawerAnim,
            builder: (_, child) => Padding(
              padding: EdgeInsets.only(left: _drawerWidth * _drawerAnim.value),
              child: child,
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 60, vertical: 50),
                child: Column(
                  children: [
                    Positioned(
                      bottom: 24,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: AnimatedBuilder(
                          animation: _drawerAnim,
                          builder: (_, child) => Transform.translate(
                            offset:
                                Offset(_drawerWidth * _drawerAnim.value / 2, 0),
                            child: child,
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            decoration: BoxDecoration(
                              color: _isDarkMode
                                  ? const Color(0xFF1E1E1E)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(40),
                              border: Border.all(
                                color:
                                    (_isDarkMode ? Colors.white : Colors.black)
                                        .withOpacity(0.1),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.wb_sunny,
                                  color:
                                      _isDarkMode ? Colors.white : Colors.amber,
                                  size: 28,
                                ),
                                const SizedBox(width: 16),
                                GestureDetector(
                                  // onTap: () {
                                  //   setState(() {
                                  //     _isDarkMode = !_isDarkMode;
                                  //   });
                                  // },
                                  onTap: null,
                                  child: Container(
                                    width: 80,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      gradient: LinearGradient(
                                        colors: _isDarkMode
                                            ? [
                                                const Color(0xFF9E9E9E),
                                                const Color(0xFF9E9E9E)
                                              ]
                                            : [
                                                const Color(0xFFF39C12),
                                                const Color(0xFFF1C40F)
                                              ],
                                      ),
                                    ),
                                    child: Stack(
                                      children: [
                                        AnimatedPositioned(
                                          duration:
                                              const Duration(milliseconds: 200),
                                          left: _isDarkMode ? 42 : 2,
                                          top: 2,
                                          bottom: 2,
                                          child: Container(
                                            width: 36,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(18),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.2),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Icon(
                                  Icons.nightlight_round,
                                  color:
                                      _isDarkMode ? Colors.white : Colors.grey,
                                  size: 28,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _Laptop(
                          desktopHeaderColor: desktopHeaderColor,
                          desktopSidebarColor: desktopSidebarColor,
                          desktopToolbarColor: desktopToolbarColor,
                          desktopMainColor: desktopMainColor,
                          desktopStatusbarColor: desktopStatusbarColor,
                          isDarkMode: _isDarkMode,
                        ),
                        const SizedBox(width: 80),
                        _MobilePhone(
                          mobileAppbarColor: mobileAppbarColor,
                          mobileContentColor: mobileContentColor,
                          mobileCard1Color: mobileCard1Color,
                          mobileCard2Color: mobileCard2Color,
                          mobileBottomNavColor: mobileBottomNavColor,
                          mobileFabColor: mobileFabColor,
                          isDarkMode: _isDarkMode,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _drawerAnim,
            builder: (_, child) => Transform.translate(
              offset: Offset(_drawerWidth * (_drawerAnim.value - 1.0), 0),
              child: child,
            ),
            child: Container(
              width: _drawerWidth,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                color: _isDarkMode ? Colors.black87 : Colors.white,
                border: Border(
                  right: BorderSide(color: Colors.white.withOpacity(0.07)),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 24,
                    offset: const Offset(4, 0),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(12, 52, 12, 24),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () => showDialog(
                            context: context,
                            builder: (_) =>
                                _FibWizardDialog(onApply: _applyFibPalette),
                          ),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E1E1E),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.12)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.auto_awesome,
                                    size: 14, color: Colors.white),
                                SizedBox(width: 8),
                                Text('GENERATE PALETTE',
                                    style: TextStyle(
                                        fontSize: 20,
                                        letterSpacing: 1.2,
                                        color: Colors.white)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () => _applyRandomDarkTheme(),
                                child: Container(
                                  width: double.infinity,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E1E1E),
                                    border: Border.all(color: Colors.white),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.auto_awesome,
                                          size: 14, color: Colors.white),
                                      SizedBox(width: 8),
                                      Text('Dark Theme',
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.white)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () => _applyRandomLightTheme(),
                                child: Container(
                                  width: double.infinity,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                        color: Colors.black.withOpacity(0.12)),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.auto_awesome,
                                          size: 14, color: Colors.black),
                                      SizedBox(width: 8),
                                      Text('Light Theme',
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.black87)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    _ColorControlSection(
                      title: 'Desktop Sections',
                      resetLabel: 'Reset Desktop',
                      onReset: resetDesktop,
                      isDarkMode: _isDarkMode,
                      rows: [
                        _ColorRow(
                          label: 'Header Bar',
                          color: desktopHeaderColor,
                          onTap: (ctx) => _showPicker(
                              ctx,
                              'Header Bar',
                              desktopHeaderColor,
                              (c) => desktopHeaderColor = c),
                          onHexChanged: (c) =>
                              setState(() => desktopHeaderColor = c),
                        ),
                        _ColorRow(
                          label: 'Sidebar',
                          color: desktopSidebarColor,
                          onTap: (ctx) => _showPicker(
                              ctx,
                              'Sidebar',
                              desktopSidebarColor,
                              (c) => desktopSidebarColor = c),
                          onHexChanged: (c) =>
                              setState(() => desktopSidebarColor = c),
                        ),
                        _ColorRow(
                          label: 'Toolbar',
                          color: desktopToolbarColor,
                          onTap: (ctx) => _showPicker(
                              ctx,
                              'Toolbar',
                              desktopToolbarColor,
                              (c) => desktopToolbarColor = c),
                          onHexChanged: (c) =>
                              setState(() => desktopToolbarColor = c),
                        ),
                        _ColorRow(
                          label: 'Body',
                          color: desktopMainColor,
                          onTap: (ctx) => _showPicker(ctx, 'Body',
                              desktopMainColor, (c) => desktopMainColor = c),
                          onHexChanged: (c) =>
                              setState(() => desktopMainColor = c),
                        ),
                        _ColorRow(
                          label: 'Status Bar',
                          color: desktopStatusbarColor,
                          onTap: (ctx) => _showPicker(
                              ctx,
                              'Status Bar',
                              desktopStatusbarColor,
                              (c) => desktopStatusbarColor = c),
                          onHexChanged: (c) =>
                              setState(() => desktopStatusbarColor = c),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _ColorControlSection(
                      title: 'Mobile Sections',
                      resetLabel: 'Reset Mobile',
                      onReset: resetMobile,
                      isDarkMode: _isDarkMode,
                      rows: [
                        _ColorRow(
                          label: 'App Bar',
                          color: mobileAppbarColor,
                          onTap: (ctx) => _showPicker(ctx, 'App Bar',
                              mobileAppbarColor, (c) => mobileAppbarColor = c),
                          onHexChanged: (c) =>
                              setState(() => mobileAppbarColor = c),
                        ),
                        _ColorRow(
                          label: 'Body',
                          color: mobileContentColor,
                          onTap: (ctx) => _showPicker(
                              ctx,
                              'Body',
                              mobileContentColor,
                              (c) => mobileContentColor = c),
                          onHexChanged: (c) =>
                              setState(() => mobileContentColor = c),
                        ),
                        _ColorRow(
                          label: 'Card 1',
                          color: mobileCard1Color,
                          onTap: (ctx) => _showPicker(ctx, 'Card 1',
                              mobileCard1Color, (c) => mobileCard1Color = c),
                          onHexChanged: (c) =>
                              setState(() => mobileCard1Color = c),
                        ),
                        _ColorRow(
                          label: 'Card 2',
                          color: mobileCard2Color,
                          onTap: (ctx) => _showPicker(ctx, 'Card 2',
                              mobileCard2Color, (c) => mobileCard2Color = c),
                          onHexChanged: (c) =>
                              setState(() => mobileCard2Color = c),
                        ),
                        _ColorRow(
                          label: 'Bottom Nav',
                          color: mobileBottomNavColor,
                          onTap: (ctx) => _showPicker(
                              ctx,
                              'Bottom Nav',
                              mobileBottomNavColor,
                              (c) => mobileBottomNavColor = c),
                          onHexChanged: (c) =>
                              setState(() => mobileBottomNavColor = c),
                        ),
                        _ColorRow(
                          label: 'FAB Button',
                          color: mobileFabColor,
                          onTap: (ctx) => _showPicker(ctx, 'FAB Button',
                              mobileFabColor, (c) => mobileFabColor = c),
                          onHexChanged: (c) =>
                              setState(() => mobileFabColor = c),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _drawerAnim,
            builder: (_, __) {
              final left = _drawerWidth * _drawerAnim.value;
              return Positioned(
                top: 16,
                left: left,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: _toggleDrawer,
                    child: Container(
                      width: 28,
                      height: 28,
                      margin: const EdgeInsets.only(left: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0e0e14),
                        borderRadius: BorderRadius.circular(6),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.1)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: AnimatedBuilder(
                          animation: _drawerAnim,
                          builder: (_, __) => Icon(
                            _drawerOpen
                                ? Icons.chevron_left
                                : Icons.chevron_right,
                            size: 18,
                            color: Colors.white.withOpacity(0.5),
                            semanticLabel: _drawerOpen ? 'Open' : 'Close',
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class FibonacciColorGenerator {
  static const List<int> _fibShifts = [13, 21, 34, 55, 89, 144];

  static List<Color> fromColor(Color base) {
    final hsl = HSLColor.fromColor(base);
    return _fibShifts.map((shift) {
      return hsl.withHue((hsl.hue + shift) % 360).toColor();
    }).toList();
  }

  static Color fromHex(String hex) {
    final clean = hex.replaceAll('#', '').padLeft(6, '0');
    return Color(int.parse('FF$clean', radix: 16));
  }
}

class _FibWizardDialog extends StatefulWidget {
  final void Function(List<Color> desktopColors, List<Color> mobileColors)
      onApply;

  const _FibWizardDialog({required this.onApply});

  @override
  State<_FibWizardDialog> createState() => _FibWizardDialogState();
}

class _FibWizardDialogState extends State<_FibWizardDialog> {
  Color _seedColor = const Color(0xFF3D85C8);
  final _hexController = TextEditingController(text: '3D85C8');
  List<Color> _preview = [];
  bool _applyToDesktop = true;
  bool _applyToMobile = true;

  @override
  void initState() {
    super.initState();
    _generate();
  }

  void _generate() {
    setState(() {
      _preview = FibonacciColorGenerator.fromColor(_seedColor);
    });
  }

  void _randomize() {
    final random =
        Color(0xFF000000 | (DateTime.now().millisecondsSinceEpoch & 0xFFFFFF));
    setState(() {
      _seedColor = random;
      _hexController.text =
          random.value.toRadixString(16).substring(2).toUpperCase();
    });
    _generate();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF0e0e14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 440,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Generate Colors',
                    style: TextStyle(
                        fontSize: 20, letterSpacing: 1.5, color: Colors.white)),
                IconButton(
                  icon:
                      const Icon(Icons.close, size: 16, color: Colors.white54),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                GestureDetector(
                  onTap: () async {
                    final picked = await showColorPickerDialog(
                      context,
                      _seedColor,
                      pickersEnabled: {
                        ColorPickerType.wheel: true,
                        ColorPickerType.primary: true,
                      },
                    );
                    setState(() {
                      _seedColor = picked;
                      _hexController.text = picked.value
                          .toRadixString(16)
                          .substring(2)
                          .toUpperCase();
                    });
                    _generate();
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _seedColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white24),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 120,
                  child: TextField(
                    controller: _hexController,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontFamily: 'monospace'),
                    decoration: InputDecoration(
                      prefixText: '#',
                      prefixStyle: const TextStyle(color: Colors.white54),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: Colors.white24),
                      ),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp('[0-9a-fA-F]')),
                      LengthLimitingTextInputFormatter(6),
                      TextInputFormatter.withFunction(
                          (o, n) => n.copyWith(text: n.text.toUpperCase())),
                    ],
                    onSubmitted: (v) {
                      if (v.length == 6) {
                        setState(() {
                          _seedColor = FibonacciColorGenerator.fromHex(v);
                        });
                        _generate();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                TextButton.icon(
                  onPressed: _randomize,
                  icon:
                      const Icon(Icons.shuffle, size: 20, color: Colors.white),
                  label: const Text('Random',
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          letterSpacing: 0.8)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_preview.isNotEmpty) ...[
              Text('GENERATED COLORS',
                  style: TextStyle(
                      fontSize: 20, letterSpacing: 1.2, color: Colors.white)),
              const SizedBox(height: 8),
              SizedBox(
                height: 44,
                child: Row(
                  children: _preview.asMap().entries.map((e) {
                    return Expanded(
                      child: Tooltip(
                        message:
                            '#${e.value.value.toRadixString(16).substring(2).toUpperCase()}',
                        child: Container(
                          margin: const EdgeInsets.only(right: 4),
                          decoration: BoxDecoration(
                            color: e.value,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
            ],
            Text('APPLY TO',
                style: TextStyle(
                    fontSize: 20, letterSpacing: 1.5, color: Colors.white)),
            const SizedBox(height: 10),
            Row(
              children: [
                _TargetToggle(
                  label: 'Desktop',
                  sublabel: 'Header · Sidebar ·\nToolbar · Body · Status',
                  value: _applyToDesktop,
                  onChanged: (v) => setState(() => _applyToDesktop = v),
                ),
                const SizedBox(width: 10),
                _TargetToggle(
                  label: 'Mobile',
                  sublabel: 'AppBar · Body ·\nCard1 · Card2 ·\nNav · FAB',
                  value: _applyToMobile,
                  onChanged: (v) => setState(() => _applyToMobile = v),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel',
                      style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
                  ),
                  onPressed:
                      (_applyToDesktop || _applyToMobile) && _preview.isNotEmpty
                          ? () {
                              widget.onApply(
                                _applyToDesktop ? _preview.sublist(0, 5) : [],
                                _applyToMobile ? _preview : [],
                              );
                              Navigator.pop(context);
                            }
                          : null,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Icon(Icons.auto_awesome,
                            size: 20, color: Colors.black87),
                        SizedBox(width: 8),
                        const Text('APPLY PALETTE',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TargetToggle extends StatelessWidget {
  final String label, sublabel;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _TargetToggle({
    required this.label,
    required this.sublabel,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(!value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: value ? Colors.white.withOpacity(0.06) : Colors.transparent,
            border: Border.all(
              color: value ? Colors.white30 : Colors.white12,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(value ? Icons.check_box : Icons.check_box_outline_blank,
                      size: 14, color: value ? Colors.white : Colors.white38),
                  const SizedBox(width: 6),
                  Text(label,
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          letterSpacing: 0.5)),
                ],
              ),
              const SizedBox(height: 4),
              Text(sublabel,
                  style: const TextStyle(
                      fontSize: 16, color: Colors.white38, letterSpacing: 0.6)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ColorRow {
  final String label;
  final Color color;
  final void Function(BuildContext ctx) onTap;
  final void Function(Color color) onHexChanged;

  const _ColorRow({
    required this.label,
    required this.color,
    required this.onTap,
    required this.onHexChanged,
  });
}

class _ColorControlSection extends StatefulWidget {
  final String title;
  final String resetLabel;
  final List<_ColorRow> rows;
  final VoidCallback onReset;
  final bool isDarkMode;

  const _ColorControlSection({
    required this.title,
    required this.resetLabel,
    required this.rows,
    required this.onReset,
    required this.isDarkMode,
  });

  @override
  State<_ColorControlSection> createState() => _ColorControlSectionState();
}

class _ColorControlSectionState extends State<_ColorControlSection>
    with SingleTickerProviderStateMixin {
  bool _expanded = true;
  late final AnimationController _controller;
  late final Animation<double> _expandAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
      value: 1.0,
    );
    _expandAnim = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    if (_expanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.isDarkMode ? Colors.black87 : Colors.white,
        border: Border.all(
            color: widget.isDarkMode
                ? Colors.white.withOpacity(0.07)
                : Colors.black87),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: _toggle,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
                child: Row(
                  children: [
                    Text(
                      widget.title.toUpperCase(),
                      style: TextStyle(
                          fontSize: 20,
                          letterSpacing: 1,
                          color: widget.isDarkMode
                              ? Colors.white
                              : Colors.black87),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                          height: 1,
                          color: widget.isDarkMode
                              ? Colors.white.withOpacity(0.06)
                              : Colors.black87),
                    ),
                    const SizedBox(width: 10),
                    AnimatedBuilder(
                      animation: _expandAnim,
                      builder: (_, __) => Transform.rotate(
                        angle: (1.0 - _expandAnim.value) * 3.14159,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: widget.isDarkMode
                                ? Colors.white.withOpacity(0.04)
                                : Colors.black87,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.08)),
                          ),
                          child: Center(
                              child: Icon(Icons.expand_more,
                                  size: 18,
                                  color: Colors.white.withOpacity(0.5))),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizeTransition(
            sizeFactor: _expandAnim,
            axisAlignment: -1,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...widget.rows.map((row) => _ColorControlRow(
                        label: row.label,
                        color: row.color,
                        onTap: row.onTap,
                        onHexChanged: row.onHexChanged,
                        isDarkMode: widget.isDarkMode,
                      )),
                  const SizedBox(height: 14),
                  Center(
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: widget.onReset,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 7),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: widget.isDarkMode
                                    ? Colors.white.withOpacity(0.15)
                                    : Colors.black87),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            widget.resetLabel.toUpperCase(),
                            style: TextStyle(
                              fontSize: 16,
                              letterSpacing: 1,
                              color: widget.isDarkMode
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ColorControlRow extends StatelessWidget {
  final String label;
  final Color color;
  final void Function(BuildContext ctx) onTap;
  final void Function(Color color) onHexChanged;
  final bool isDarkMode;

  const _ColorControlRow({
    required this.label,
    required this.color,
    required this.onTap,
    required this.onHexChanged,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final hex = '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 96,
            child: Text(label,
                style: TextStyle(
                    fontSize: 16,
                    letterSpacing: 0.8,
                    color: isDarkMode ? Colors.white : Colors.black87)),
          ),
          Row(
            children: [
              SizedBox(
                width: 90,
                child: TextField(
                  controller:
                      TextEditingController(text: hex.replaceAll('#', '')),
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                  decoration: InputDecoration(
                    prefixText: '#',
                    prefixStyle: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black87),
                    isDense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide:
                          BorderSide(color: Colors.white.withOpacity(0.2)),
                    ),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp('[#]')),
                    FilteringTextInputFormatter.deny(RegExp('[\\s]')),
                    TextInputFormatter.withFunction(
                      (oldValue, newValue) => TextEditingValue(
                        text: newValue.text.toUpperCase(),
                        selection: newValue.selection,
                      ),
                    ),
                    FilteringTextInputFormatter.allow(RegExp('[0-9a-fA-F]')),
                    LengthLimitingTextInputFormatter(6),
                  ],
                  onSubmitted: (value) {
                    final hex = value.trim().replaceAll('#', '');
                    if (hex.length == 6 || hex.length == 3) {
                      try {
                        final colorValue =
                            int.parse(hex.padLeft(6, '0'), radix: 16);
                        final newColor = Color(0xFF000000 | colorValue);
                        onHexChanged(newColor);
                      } catch (e) {}
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => onTap(context),
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                      boxShadow: [
                        BoxShadow(color: color.withOpacity(0.4), blurRadius: 6)
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => onTap(context),
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                          color: isDarkMode
                              ? Colors.white.withOpacity(0.1)
                              : Colors.black87),
                    ),
                    child: Center(
                      child: Icon(Icons.edit,
                          size: 12,
                          color: isDarkMode
                              ? Colors.white.withOpacity(0.6)
                              : Colors.black87),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Laptop extends StatelessWidget {
  final Color desktopHeaderColor;
  final Color desktopSidebarColor;
  final Color desktopToolbarColor;
  final Color desktopMainColor;
  final Color desktopStatusbarColor;
  final bool isDarkMode;

  const _Laptop({
    required this.desktopHeaderColor,
    required this.desktopSidebarColor,
    required this.desktopToolbarColor,
    required this.desktopMainColor,
    required this.desktopStatusbarColor,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Desktop',
          style:
              TextStyle(fontSize: 9, letterSpacing: 1.8, color: Colors.white),
        ),
        const SizedBox(height: 14),
        Column(
          children: [
            Container(
              width: 700,
              decoration: BoxDecoration(
                color: const Color(0xFF1a1a1a),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                border: Border.all(color: const Color(0xFF3a3a3a)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.6),
                      blurRadius: 80,
                      offset: const Offset(0, -40)),
                  BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 60,
                      offset: const Offset(0, 20)),
                ],
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 24,
                    child: Center(
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                            color: Color(0xFF2a2a2a), shape: BoxShape.circle),
                      ),
                    ),
                  ),
                  Container(
                    height: 430,
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF06060a),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: _DesktopWebApp(
                      headerColor: desktopHeaderColor,
                      sidebarColor: desktopSidebarColor,
                      toolbarColor: desktopToolbarColor,
                      mainColor: desktopMainColor,
                      statusbarColor: desktopStatusbarColor,
                      isDarkMode: isDarkMode,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            Container(
              width: 724,
              height: 12,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF2a2a2a),
                    Color(0xFF222222),
                    Color(0xFF1a1a1a)
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DesktopWebApp extends StatelessWidget {
  final Color headerColor;
  final Color sidebarColor;
  final Color toolbarColor;
  final Color mainColor;
  final Color statusbarColor;
  final bool isDarkMode;

  const _DesktopWebApp({
    required this.headerColor,
    required this.sidebarColor,
    required this.toolbarColor,
    required this.mainColor,
    required this.statusbarColor,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 38,
          color: headerColor,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Row(
                    children: [
                      _dot(const Color(0xFFff5f57)),
                      const SizedBox(width: 5),
                      _dot(const Color(0xFFfebc2e)),
                      const SizedBox(width: 5),
                      _dot(const Color(0xFF28c840)),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Text('DASHBOARD',
                      style: TextStyle(
                          fontSize: 8,
                          letterSpacing: 1,
                          color: isDarkMode
                              ? Colors.white
                              : const Color(0xFF1E1E1E))),
                ],
              ),
              Row(
                children: [
                  _navPill('Overview', isActive: true),
                  _navPill('Analytics'),
                  _navPill('Deploy'),
                  _navPill('Settings'),
                  const SizedBox(width: 8),
                  _iconCircle(Icons.account_circle, size: 20),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 200,
                color: sidebarColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sidebarCat('MAIN'),
                    _sidebarItem('Dashboard', isActive: true),
                    _sidebarItem('Projects'),
                    _sidebarItem('Analytics'),
                    _sidebarCat('CONFIG'),
                    _sidebarItem('API Keys'),
                    _sidebarItem('Webhooks'),
                    _sidebarItem('Team'),
                    _sidebarCat('SYSTEM'),
                    _sidebarItem('Logs'),
                    _sidebarItem('Billing'),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  color: mainColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        height: 34,
                        color: toolbarColor,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                _toolBtn('New +'),
                                _toolBtn('Filter'),
                                _toolBtn('Export'),
                              ],
                            ),
                            Row(
                              children: [
                                Text('Last sync 2m ago ●',
                                    style: TextStyle(
                                        fontSize: 7,
                                        letterSpacing: 1,
                                        color: Colors.white.withOpacity(0.2))),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                      child:
                                          _statCard('UPTIME', '99.9%', 0.99)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                      child:
                                          _statCard('REQUESTS', '2.4M', 0.72)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                      child: _statCard('LATENCY', '18ms', 0.4)),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.02),
                                    border: Border.all(
                                        color: isDarkMode
                                            ? Colors.white.withOpacity(0.07)
                                            : const Color(0xFF1E1E1E)),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Column(
                                    children: [
                                      _tableRow([
                                        'SERVICE',
                                        'STATUS',
                                        'REGION',
                                        'CPU'
                                      ], isHeader: true),
                                      _tableRow([
                                        'api-gateway',
                                        'Live',
                                        'us-east-1',
                                        '12%'
                                      ]),
                                      _tableRow([
                                        'data-stream',
                                        'Live',
                                        'eu-west-2',
                                        '34%'
                                      ]),
                                      _tableRow([
                                        'ml-inference',
                                        'Warn',
                                        'ap-south-1',
                                        '78%'
                                      ], isWarning: true),
                                      _tableRow(
                                          ['cdn-edge', 'Live', 'global', '8%']),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 26,
          color: statusbarColor,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text('● CONNECTED',
                      style: TextStyle(
                          fontSize: 7,
                          letterSpacing: 1,
                          color: isDarkMode
                              ? Colors.white.withOpacity(0.5)
                              : const Color(0xFF1E1E1E))),
                  const SizedBox(width: 14),
                  Text('v4.2.1',
                      style: TextStyle(
                          fontSize: 7,
                          color: isDarkMode
                              ? Colors.white
                              : const Color(0xFF1E1E1E))),
                  const SizedBox(width: 14),
                  Text('3 pods running',
                      style: TextStyle(
                          fontSize: 7,
                          color: isDarkMode
                              ? Colors.white
                              : const Color(0xFF1E1E1E))),
                ],
              ),
              Text('UTC 14:32:08',
                  style: TextStyle(
                      fontSize: 7,
                      color:
                          isDarkMode ? Colors.white : const Color(0xFF1E1E1E))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _dot(Color color) => Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle));

  Widget _iconCircle(IconData? icon, {double size = 22}) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isDarkMode
              ? Colors.white.withOpacity(0.04)
              : const Color(0xFF1E1E1E),
          border: Border.all(
              color: isDarkMode
                  ? Colors.white.withOpacity(0.07)
                  : const Color(0xFF1E1E1E)),
          shape: BoxShape.circle,
        ),
        child: Center(child: Icon(icon, size: 9, color: Colors.white)),
      );

  Widget _navPill(String text, {bool isActive = false}) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: isActive
              ? isDarkMode
                  ? const Color(0xFF1E1E1E)
                  : Colors.white.withOpacity(0.09)
              : isDarkMode
                  ? const Color(0xFF1E1E1E)
                  : Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(3),
          border: Border.all(
              color: isActive
                  ? isDarkMode
                      ? Colors.white.withOpacity(0.15)
                      : Colors.black87
                  : Colors.transparent),
        ),
        child: Text(text,
            style: TextStyle(
              fontSize: 8,
              letterSpacing: 0.8,
              color: isActive
                  ? isDarkMode
                      ? Colors.white
                      : const Color(0xFF1E1E1E)
                  : isDarkMode
                      ? Colors.white
                      : const Color(0xFF1E1E1E),
            )),
      );

  Widget _sidebarCat(String title) => Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
        child: Text(title,
            style: TextStyle(
                fontSize: 7,
                letterSpacing: 2,
                color: isDarkMode
                    ? Colors.white.withOpacity(0.2)
                    : const Color(0xFF1E1E1E))),
      );

  Widget _sidebarItem(String title, {bool isActive = false}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        color: isActive ? Colors.white.withOpacity(0.05) : Colors.transparent,
        child: Row(
          children: [
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: isActive
                    ? isDarkMode
                        ? Colors.white
                        : const Color(0xFF1E1E1E)
                    : isDarkMode
                        ? Colors.white
                        : const Color(0xFF1E1E1E),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(title,
                style: TextStyle(
                  fontSize: 8,
                  letterSpacing: 0.8,
                  color: isActive
                      ? isDarkMode
                          ? Colors.white
                          : const Color(0xFF1E1E1E)
                      : isDarkMode
                          ? Colors.white
                          : const Color(0xFF1E1E1E),
                )),
          ],
        ),
      );

  Widget _toolBtn(String text) => Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Text(text,
            style: TextStyle(
                fontSize: 8,
                letterSpacing: 0.8,
                color: isDarkMode ? Colors.white : const Color(0xFF1E1E1E))),
      );

  Widget _statCard(String title, String value, double fill) => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          border: Border.all(
              color: isDarkMode
                  ? Colors.white.withOpacity(0.07)
                  : const Color(0xFF1E1E1E)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(
                    fontSize: 8,
                    letterSpacing: 1,
                    color:
                        isDarkMode ? Colors.white : const Color(0xFF1E1E1E))),
            const SizedBox(height: 5),
            Text(value,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color:
                        isDarkMode ? Colors.white : const Color(0xFF1E1E1E))),
            const SizedBox(height: 5),
            Container(
              height: 2,
              color: isDarkMode
                  ? Colors.white.withOpacity(0.06)
                  : const Color(0xFF1E1E1E),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: fill,
                child: Container(color: Colors.white.withOpacity(0.3)),
              ),
            ),
          ],
        ),
      );

  Widget _tableRow(List<String> cells,
          {bool isHeader = false, bool isWarning = false}) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isHeader ? Colors.white.withOpacity(0.03) : Colors.transparent,
          border: Border(
              bottom: BorderSide(
                  color: isDarkMode
                      ? Colors.white.withOpacity(0.07)
                      : const Color(0xFF1E1E1E))),
        ),
        child: Row(
          children: cells.map((cell) {
            final isStatus =
                cell == 'Live' || cell == 'Warn' || cell == 'STATUS';
            return Expanded(
              child: isStatus && !isHeader
                  ? Row(
                      children: [
                        Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: isWarning
                                ? const Color(0xFFfebc2e)
                                : const Color(0xFF28c840),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(cell,
                            style: TextStyle(
                                fontSize: 7.5,
                                letterSpacing: 0.8,
                                color: isDarkMode
                                    ? Colors.white
                                    : const Color(0xFF1E1E1E))),
                      ],
                    )
                  : Text(cell,
                      style: TextStyle(
                        fontSize: isHeader ? 7 : 7.5,
                        letterSpacing: isHeader ? 1.5 : 0.8,
                        color: isHeader
                            ? isDarkMode
                                ? Colors.white.withOpacity(0.25)
                                : const Color(0xFF1E1E1E)
                            : isDarkMode
                                ? Colors.white
                                : const Color(0xFF1E1E1E),
                      )),
            );
          }).toList(),
        ),
      );
}

class _MobilePhone extends StatelessWidget {
  final Color mobileAppbarColor;
  final Color mobileContentColor;
  final Color mobileCard1Color;
  final Color mobileCard2Color;
  final Color mobileBottomNavColor;
  final Color mobileFabColor;
  final bool isDarkMode;

  const _MobilePhone({
    required this.mobileAppbarColor,
    required this.mobileContentColor,
    required this.mobileCard1Color,
    required this.mobileCard2Color,
    required this.mobileBottomNavColor,
    required this.mobileFabColor,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Mobile',
          style:
              TextStyle(fontSize: 9, letterSpacing: 1.8, color: Colors.white),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: 290,
          height: 590,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 278,
                height: 578,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF141418),
                      Color(0xFF0c0c10),
                      Color(0xFF111116)
                    ],
                  ),
                  borderRadius: BorderRadius.circular(48),
                  border: Border.all(color: Colors.white.withOpacity(0.12)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.7),
                        blurRadius: 120,
                        offset: const Offset(0, 50)),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                        child: CustomPaint(painter: GlyphPatternPainter())),
                    Positioned(
                      right: 16,
                      top: 200,
                      child: Container(
                        width: 3,
                        height: 160,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.white.withOpacity(0.08),
                              Colors.white.withOpacity(0.12),
                              Colors.white.withOpacity(0.08),
                              Colors.transparent,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 80,
                      right: 16,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: Colors.white.withOpacity(0.06)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 6,
                top: 150,
                child: Container(
                  width: 4,
                  height: 54,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1e1e22),
                    border: Border.all(color: Colors.white.withOpacity(0.06)),
                    borderRadius: const BorderRadius.horizontal(
                        right: Radius.circular(2)),
                  ),
                ),
              ),
              Positioned(
                left: 6,
                top: 136,
                child: Container(
                  width: 4,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1e1e22),
                    border: Border.all(color: Colors.white.withOpacity(0.06)),
                    borderRadius:
                        const BorderRadius.horizontal(left: Radius.circular(2)),
                  ),
                ),
              ),
              Positioned(
                left: 6,
                top: 174,
                child: Container(
                  width: 4,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1e1e22),
                    border: Border.all(color: Colors.white.withOpacity(0.06)),
                    borderRadius:
                        const BorderRadius.horizontal(left: Radius.circular(2)),
                  ),
                ),
              ),
              Positioned(
                top: 17,
                left: 17,
                right: 17,
                bottom: 17,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF06060a),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: Stack(
                    children: [
                      _MobileWebApp(
                        appbarColor: mobileAppbarColor,
                        contentColor: mobileContentColor,
                        card1Color: mobileCard1Color,
                        card2Color: mobileCard2Color,
                        bottomNavColor: mobileBottomNavColor,
                        fabColor: mobileFabColor,
                        isDarkMode: isDarkMode,
                      ),
                      Positioned(
                        top: 12,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            width: 90,
                            height: 22,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 4,
                                  height: 4,
                                  decoration: const BoxDecoration(
                                      color: Color(0xFF1a1a22),
                                      shape: BoxShape.circle),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF111111),
                                    border: Border.all(
                                        color: const Color(0xFF1a1a1a)),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 6,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            width: 100,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class GlyphPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    for (double x = 0; x < size.width; x += 8) {
      for (double y = 0; y < size.height; y += 8) {
        canvas.drawCircle(Offset(x, y), 0.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MobileWebApp extends StatelessWidget {
  final Color appbarColor;
  final Color contentColor;
  final Color card1Color;
  final Color card2Color;
  final Color bottomNavColor;
  final Color fabColor;
  final bool isDarkMode;

  const _MobileWebApp({
    required this.appbarColor,
    required this.contentColor,
    required this.card1Color,
    required this.card2Color,
    required this.bottomNavColor,
    required this.fabColor,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: appbarColor,
          padding: const EdgeInsets.fromLTRB(16, 38, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const SizedBox(width: 10),
                  Text('Dashboard',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                        color:
                            isDarkMode ? Colors.white : const Color(0xFF1E1E1E),
                      )),
                ],
              ),
              Row(
                children: [
                  _iconCircle(Icons.circle_notifications),
                  const SizedBox(width: 6),
                  _iconCircle(Icons.more_vert),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            color: contentColor,
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.04),
                          border: Border.all(
                            color: isDarkMode
                                ? Colors.white.withOpacity(0.07)
                                : const Color(0xFF1E1E1E),
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.search,
                              size: 10,
                              color: isDarkMode
                                  ? Colors.white
                                  : const Color(0xFF1E1E1E),
                            ),
                            const SizedBox(width: 6),
                            Text('Search services…',
                                style: TextStyle(
                                  fontSize: 8,
                                  letterSpacing: 0.8,
                                  color: isDarkMode
                                      ? Colors.white
                                      : const Color(0xFF1E1E1E),
                                )),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _chip('All', isSelected: true),
                          const SizedBox(width: 5),
                          _chip('Live'),
                          const SizedBox(width: 5),
                          _chip('Warning'),
                          const SizedBox(width: 5),
                          _chip('Offline'),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: _stat('UPTIME %', '99.9')),
                          const SizedBox(width: 6),
                          Expanded(child: _stat('LATENCY', '18')),
                          const SizedBox(width: 6),
                          Expanded(child: _stat('PODS', '4')),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text('SERVICES',
                          style: TextStyle(
                              fontSize: 7,
                              letterSpacing: 2,
                              color: Colors.white.withOpacity(0.2))),
                      const SizedBox(height: 8),
                      _card(
                        icon: Icons.apps,
                        title: 'api-gateway',
                        subtitle: 'us-east-1 · 12% CPU',
                        badge: 'LIVE',
                        badgeColor: const Color(0xFF28c840),
                        bgColor: card1Color,
                      ),
                      const SizedBox(height: 8),
                      _card(
                        icon: Icons.cached,
                        title: 'ml-inference',
                        subtitle: 'ap-south-1 · 78% CPU',
                        badge: 'WARN',
                        badgeColor: const Color(0xFFfebc2e),
                        bgColor: card2Color,
                      ),
                      const SizedBox(height: 8),
                      _card(
                        icon: Icons.radio_button_checked,
                        title: 'data-stream',
                        subtitle: 'eu-west-2 · 34% CPU',
                        badge: 'LIVE',
                        badgeColor: const Color(0xFF28c840),
                        bgColor: card1Color,
                      ),
                      const SizedBox(height: 60),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: fabColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 24,
                            offset: const Offset(0, 6)),
                      ],
                    ),
                    child: Center(
                        child: Icon(Icons.add,
                            size: 20,
                            color: isDarkMode
                                ? const Color(0xFF1E1E1E)
                                : Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          color: bottomNavColor,
          padding: const EdgeInsets.fromLTRB(8, 10, 8, 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(Icons.home, 'Home', isActive: true),
              _navItem(Icons.monitor_heart, 'Monitor'),
              _navItem(Icons.cloud, 'Deploy'),
              _navItem(Icons.account_circle, 'Account'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _iconCircle(IconData? icon) => Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          border: Border.all(
              color: isDarkMode
                  ? Colors.white.withOpacity(0.07)
                  : const Color(0xFF1E1E1E)),
          shape: BoxShape.circle,
        ),
        child: Center(
            child: Icon(
          icon,
          size: 9,
          color: isDarkMode ? Colors.white : const Color(0xFF1E1E1E),
        )),
      );

  Widget _chip(String label, {bool isSelected = false}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color:
              isSelected ? Colors.white.withOpacity(0.08) : Colors.transparent,
          border: Border.all(
              color: isDarkMode
                  ? Colors.white.withOpacity(isSelected ? 0.15 : 0.07)
                  : const Color(0xFF1E1E1E)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: TextStyle(
              fontSize: 8,
              letterSpacing: 0.8,
              color: isSelected
                  ? isDarkMode
                      ? Colors.white
                      : const Color(0xFF1E1E1E)
                  : isDarkMode
                      ? Colors.white
                      : const Color(0xFF1E1E1E),
            )),
      );

  Widget _stat(String label, String value) => Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          border: Border.all(
              color: isDarkMode
                  ? Colors.white.withOpacity(0.07)
                  : const Color(0xFF1E1E1E)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color:
                        isDarkMode ? Colors.white : const Color(0xFF1E1E1E))),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                    fontSize: 6.5,
                    letterSpacing: 0.8,
                    color:
                        isDarkMode ? Colors.white : const Color(0xFF1E1E1E))),
          ],
        ),
      );

  Widget _card({
    required IconData? icon,
    required String title,
    required String subtitle,
    required String badge,
    required Color badgeColor,
    required Color bgColor,
  }) =>
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(
              color: isDarkMode
                  ? Colors.white.withOpacity(0.07)
                  : const Color(0xFF1E1E1E)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                border: Border.all(
                    color: isDarkMode
                        ? Colors.white.withOpacity(0.07)
                        : const Color(0xFF1E1E1E)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                  child: Icon(icon,
                      size: 13,
                      color:
                          isDarkMode ? Colors.white : const Color(0xFF1E1E1E))),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                          color: isDarkMode
                              ? Colors.white
                              : const Color(0xFF1E1E1E))),
                  const SizedBox(height: 3),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 7.5,
                          letterSpacing: 0.6,
                          color: isDarkMode
                              ? Colors.white
                              : const Color(0xFF1E1E1E))),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                border: Border.all(color: badgeColor.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(badge,
                  style: TextStyle(
                      fontSize: 7, letterSpacing: 0.8, color: badgeColor)),
            ),
          ],
        ),
      );

  Widget _navItem(IconData? icon, String label, {bool isActive = false}) =>
      Column(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isActive
                  ? isDarkMode
                      ? Colors.white.withOpacity(0.08)
                      : const Color(0xFF1E1E1E)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              // border: Border.all(
              //   color:
              //       (isDarkMode ? Colors.white : Colors.black).withOpacity(0.1),
              // ),
            ),
            child: Center(
                child: Icon(icon,
                    size: 14,
                    color: isActive
                        ? Colors.white
                        : isDarkMode
                            ? Colors.white
                            : const Color(0xFF1E1E1E))),
          ),
          const SizedBox(height: 3),
          Text(label,
              style: TextStyle(
                fontSize: 6.5,
                letterSpacing: 0.8,
                color: isActive
                    ? isDarkMode
                        ? Colors.white
                        : const Color(0xFF1E1E1E)
                    : isDarkMode
                        ? Colors.white
                        : const Color(0xFF1E1E1E),
              )),
        ],
      );
}
