import 'package:flutter/material.dart';

import 'views/home_screen.dart';
import 'views/splash_screen.dart';

class PakaiNiatApp extends StatelessWidget {
  const PakaiNiatApp({super.key, this.showSplash = true});

  final bool showSplash;

  // Core palette: warm ink with honey-gold energy and mint accents.
  static const Color _bg = Color(0xFF0B0E14);
  static const Color _surface = Color(0xFF141925);
  static const Color _surfaceHighlight = Color(0xFF1E2433);
  static const Color _primary = Color(0xFFF59E0B);
  static const Color _primaryLight = Color(0xFFFBBF24);
  static const Color _onPrimary = Color(0xFF1C1400);
  static const Color _accent = Color(0xFF34D399);
  static const Color _error = Color(0xFFFB7185);
  static const Color _text = Color(0xFFF8FAFC);
  static const Color _textMuted = Color(0xFF94A3B8);

  static const _smoothCurve = Curves.easeInOutCubic;
  static const _mediumDur = Duration(milliseconds: 350);

  static PageRouteBuilder<void> _pageRoute(Widget page) {
    return PageRouteBuilder<void>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 0.08);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: _smoothCurve),
        );
        final fade = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: _smoothCurve),
        );
        return FadeTransition(
          opacity: fade,
          child: SlideTransition(position: animation.drive(tween), child: child),
        );
      },
      transitionDuration: _mediumDur,
    );
  }

  @override
  Widget build(BuildContext context) {
    final base = ThemeData.dark();
    const shapeMedium = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(20)),
    );
    const shapeLarge = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(28)),
    );

    return MaterialApp(
      title: 'Pakai Niat',
      debugShowCheckedModeBanner: false,
      theme: base.copyWith(
        scaffoldBackgroundColor: _bg,
        colorScheme: const ColorScheme.dark(
          primary: _primary,
          onPrimary: _onPrimary,
          secondary: _accent,
          onSecondary: _onPrimary,
          surface: _surface,
          onSurface: _text,
          surfaceContainerHighest: _surfaceHighlight,
          error: _error,
          onError: _text,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: _bg,
          foregroundColor: _text,
          elevation: 0,
          centerTitle: true,
          shape: Border(),
        ),
        cardTheme: CardThemeData(
          color: _surface,
          elevation: 0,
          shape: shapeMedium,
          margin: EdgeInsets.zero,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: _primary,
          foregroundColor: _onPrimary,
          elevation: 4,
          highlightElevation: 8,
          shape: StadiumBorder(),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: _surface,
          selectedItemColor: _primaryLight,
          unselectedItemColor: _textMuted,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: _surface.withValues(alpha: 0.95),
          indicatorColor: _primary.withValues(alpha: 0.15),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return IconThemeData(
              color: selected ? _primaryLight : _textMuted,
            );
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return TextStyle(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: selected ? _primaryLight : _textMuted,
            );
          }),
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: _surface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          hintStyle: const TextStyle(color: _textMuted),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: _primaryLight, width: 1.5),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: _primary,
            foregroundColor: _onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: const StadiumBorder(),
            elevation: 0,
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: _text,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: const StadiumBorder(),
            side: BorderSide(color: _textMuted.withValues(alpha: 0.25)),
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: _primaryLight,
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        dividerTheme: DividerThemeData(
          color: _textMuted.withValues(alpha: 0.12),
          thickness: 1,
        ),
        dialogTheme: DialogThemeData(backgroundColor: _surface, shape: shapeLarge),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: _surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: _text, fontWeight: FontWeight.w700),
          displayMedium: TextStyle(color: _text, fontWeight: FontWeight.w700),
          titleLarge: TextStyle(color: _text, fontWeight: FontWeight.w700, fontSize: 22),
          titleMedium: TextStyle(color: _text, fontWeight: FontWeight.w600, fontSize: 16),
          titleSmall: TextStyle(color: _text, fontWeight: FontWeight.w600, fontSize: 14),
          bodyLarge: TextStyle(color: _text, fontSize: 16),
          bodyMedium: TextStyle(color: _text, fontSize: 14),
          bodySmall: TextStyle(color: _textMuted, fontSize: 13),
          labelSmall: TextStyle(color: _textMuted, fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
      home: showSplash ? const SplashScreen() : const HomeScreen(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/home':
            return _pageRoute(const HomeScreen());
        }
        return null;
      },
    );
  }
}
