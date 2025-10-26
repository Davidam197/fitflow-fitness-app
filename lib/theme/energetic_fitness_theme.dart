import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Primary Colors
const _mainPurple = Color.fromRGBO(139, 69, 255, 1.0); // HSL(262, 83%, 58%)
const _gradientBlue = Color.fromRGBO(69, 130, 255, 1.0); // HSL(220, 90%, 56%)

// Accent Colors
const _coralOrange = Color.fromRGBO(255, 102, 69, 1.0); // HSL(14, 90%, 60%)
const _pinkAccent = Color.fromRGBO(255, 69, 130, 1.0); // HSL(340, 82%, 52%)

// Neutral Colors
const _background = Color.fromRGBO(252, 252, 255, 1.0); // HSL(240, 20%, 99%)
const _foreground = Color.fromRGBO(38, 38, 42, 1.0); // HSL(240, 10%, 15%)
const _muted = Color.fromRGBO(245, 245, 247, 1.0); // HSL(240, 5%, 96%)
const _border = Color.fromRGBO(230, 230, 235, 1.0); // HSL(240, 10%, 90%)

// Dark Mode Colors
const _darkBackground = Color.fromRGBO(20, 20, 25, 1.0); // HSL(240, 10%, 8%)
const _darkCard = Color.fromRGBO(30, 30, 35, 1.0); // HSL(240, 10%, 12%)

// Gradients
final primaryGradient = const LinearGradient(
  colors: [_mainPurple, _gradientBlue],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  transform: GradientRotation(135 * 3.14159 / 180), // 135 degrees
);

final accentGradient = const LinearGradient(
  colors: [_coralOrange, _pinkAccent],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  transform: GradientRotation(135 * 3.14159 / 180), // 135 degrees
);

// Light Theme
final energeticFitnessLight = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: _background,
  primaryColor: _mainPurple,
  colorScheme: const ColorScheme.light(
    primary: _mainPurple,
    secondary: _gradientBlue,
    tertiary: _coralOrange,
    surface: Colors.white,
    background: _background,
    error: _pinkAccent,
    onPrimary: Colors.white,
    onSurface: _foreground,
    onBackground: _foreground,
    outline: _border,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      color: _foreground,
      fontSize: 20,
      fontWeight: FontWeight.w700,
    ),
    iconTheme: IconThemeData(color: _foreground),
    systemOverlayStyle: SystemUiOverlayStyle.dark,
  ),
  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 0,
    shadowColor: _mainPurple.withOpacity(0.1),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16), // 1rem
      side: const BorderSide(color: _border),
    ),
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: _mainPurple,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      textStyle: const TextStyle(fontWeight: FontWeight.w700),
      elevation: 0,
      shadowColor: _mainPurple.withOpacity(0.2),
    ),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: _mainPurple,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      textStyle: const TextStyle(fontWeight: FontWeight.w700),
      elevation: 0,
      shadowColor: _mainPurple.withOpacity(0.2),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      side: const BorderSide(color: _border),
      foregroundColor: _foreground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    ),
  ),
  chipTheme: ChipThemeData(
    backgroundColor: _muted,
    selectedColor: _mainPurple,
    labelStyle: const TextStyle(color: _foreground, fontWeight: FontWeight.w600),
    secondaryLabelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
    shape: StadiumBorder(side: BorderSide(color: _border)),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: _mainPurple,
    unselectedItemColor: _foreground,
    type: BottomNavigationBarType.fixed,
    elevation: 8,
  ),
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: _mainPurple,
    linearTrackColor: _muted,
  ),
  textTheme: const TextTheme(
    titleLarge: TextStyle(color: _foreground, fontWeight: FontWeight.w700, fontSize: 24),
    titleMedium: TextStyle(color: _foreground, fontWeight: FontWeight.w600, fontSize: 20),
    bodyLarge: TextStyle(color: _foreground, fontSize: 16),
    bodyMedium: TextStyle(color: _foreground, fontSize: 14),
    labelLarge: TextStyle(color: _foreground, fontWeight: FontWeight.w700, fontSize: 14),
  ),
);

// Dark Theme
final energeticFitnessDark = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: _darkBackground,
  primaryColor: _mainPurple,
  colorScheme: const ColorScheme.dark(
    primary: _mainPurple,
    secondary: _gradientBlue,
    tertiary: _coralOrange,
    surface: _darkCard,
    background: _darkBackground,
    error: _pinkAccent,
    onPrimary: Colors.white,
    onSurface: Colors.white,
    onBackground: Colors.white,
    outline: _border,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.w700,
    ),
    iconTheme: IconThemeData(color: Colors.white),
    systemOverlayStyle: SystemUiOverlayStyle.light,
  ),
  cardTheme: CardThemeData(
    color: _darkCard,
    elevation: 0,
    shadowColor: _mainPurple.withOpacity(0.2),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: _border),
    ),
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: _mainPurple,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      textStyle: const TextStyle(fontWeight: FontWeight.w700),
      elevation: 0,
      shadowColor: _mainPurple.withOpacity(0.2),
    ),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: _mainPurple,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      textStyle: const TextStyle(fontWeight: FontWeight.w700),
      elevation: 0,
      shadowColor: _mainPurple.withOpacity(0.2),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      side: const BorderSide(color: _border),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    ),
  ),
  chipTheme: ChipThemeData(
    backgroundColor: _darkCard,
    selectedColor: _mainPurple,
    labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
    secondaryLabelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
    shape: StadiumBorder(side: BorderSide(color: _border)),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: _darkCard,
    selectedItemColor: _mainPurple,
    unselectedItemColor: Colors.white,
    type: BottomNavigationBarType.fixed,
    elevation: 8,
  ),
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: _mainPurple,
    linearTrackColor: _darkCard,
  ),
  textTheme: const TextTheme(
    titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 24),
    titleMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 20),
    bodyLarge: TextStyle(color: Colors.white, fontSize: 16),
    bodyMedium: TextStyle(color: Colors.white, fontSize: 14),
    labelLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
  ),
);

// Gradient Button Widget
class GradientButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final bool isAccent;
  
  const GradientButton({
    super.key, 
    required this.child, 
    this.onPressed,
    this.isAccent = false,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16);
    final gradient = isAccent ? accentGradient : primaryGradient;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: radius,
        child: Ink(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: radius,
            boxShadow: [
              BoxShadow(
                color: (isAccent ? _coralOrange : _mainPurple).withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Container(
            constraints: const BoxConstraints(minHeight: 56),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: DefaultTextStyle.merge(
              style: const TextStyle(
                color: Colors.white, 
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

// Gradient AppBar Widget
class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool isAccent;
  
  const GradientAppBar({
    super.key, 
    required this.title, 
    this.actions,
    this.isAccent = false,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = isAccent ? accentGradient : primaryGradient;
    
    return AppBar(
      flexibleSpace: Container(
        decoration: BoxDecoration(gradient: gradient),
      ),
      title: Text(title),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
