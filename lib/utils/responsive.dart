import 'package:flutter/material.dart';
import 'dart:io';

class Responsive {
  // Device type detection
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }
  
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600 && width < 1200;
  }
  
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1200;
  }

  // Platform detection
  static bool isIOS(BuildContext context) {
    return Platform.isIOS;
  }

  static bool isAndroid(BuildContext context) {
    return Platform.isAndroid;
  }

  // Screen size categories
  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 400;
  }

  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width > 1000;
  }

  // Safe area considerations
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  static double getBottomSafeArea(BuildContext context) {
    return MediaQuery.of(context).padding.bottom;
  }

  static double getTopSafeArea(BuildContext context) {
    return MediaQuery.of(context).padding.top;
  }
  
  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }
  
  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }
  
  // Responsive padding with platform considerations
  static EdgeInsets getPadding(BuildContext context) {
    final basePadding = isSmallScreen(context) ? 12.0 : 16.0;
    final multiplier = isTablet(context) ? 1.5 : isDesktop(context) ? 2.0 : 1.0;
    final padding = basePadding * multiplier;
    
    return EdgeInsets.all(padding);
  }

  // Screen-specific padding
  static EdgeInsets getScreenPadding(BuildContext context) {
    if (isSmallScreen(context)) {
      return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
    } else if (isMobile(context)) {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
    } else if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
    } else {
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 20);
    }
  }
  
  // Responsive spacing
  static double getSpacing(BuildContext context) {
    if (isSmallScreen(context)) {
      return 6.0;
    } else if (isMobile(context)) {
      return 8.0;
    } else if (isTablet(context)) {
      return 12.0;
    } else {
      return 16.0;
    }
  }

  // Large spacing for sections
  static double getLargeSpacing(BuildContext context) {
    return getSpacing(context) * 2;
  }
  
  // Responsive card padding
  static EdgeInsets getCardPadding(BuildContext context) {
    if (isSmallScreen(context)) {
      return const EdgeInsets.all(12);
    } else if (isMobile(context)) {
      return const EdgeInsets.all(16);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(20);
    } else {
      return const EdgeInsets.all(24);
    }
  }

  // Navigation bar height
  static double getNavBarHeight(BuildContext context) {
    final baseHeight = isIOS(context) ? 80.0 : 70.0;
    return baseHeight + getBottomSafeArea(context);
  }

  // App bar height
  static double getAppBarHeight(BuildContext context) {
    final baseHeight = isIOS(context) ? 56.0 : 48.0;
    return baseHeight + getTopSafeArea(context);
  }
  
  // Responsive font sizes
  static double getTitleFontSize(BuildContext context) {
    if (isSmallScreen(context)) {
      return 18.0;
    } else if (isMobile(context)) {
      return 20.0;
    } else if (isTablet(context)) {
      return 24.0;
    } else {
      return 28.0;
    }
  }

  static double getSubtitleFontSize(BuildContext context) {
    if (isSmallScreen(context)) {
      return 14.0;
    } else if (isMobile(context)) {
      return 16.0;
    } else if (isTablet(context)) {
      return 18.0;
    } else {
      return 20.0;
    }
  }

  static double getBodyFontSize(BuildContext context) {
    if (isSmallScreen(context)) {
      return 12.0;
    } else if (isMobile(context)) {
      return 14.0;
    } else if (isTablet(context)) {
      return 16.0;
    } else {
      return 18.0;
    }
  }

  static double getCaptionFontSize(BuildContext context) {
    if (isSmallScreen(context)) {
      return 10.0;
    } else if (isMobile(context)) {
      return 12.0;
    } else if (isTablet(context)) {
      return 14.0;
    } else {
      return 16.0;
    }
  }
  
  // Responsive grid columns
  static int getGridColumns(BuildContext context) {
    if (isSmallScreen(context)) {
      return 1;
    } else if (isMobile(context)) {
      return 1;
    } else if (isTablet(context)) {
      return 2;
    } else {
      return 3;
    }
  }

  // Card width for different screens
  static double getCardWidth(BuildContext context) {
    if (isSmallScreen(context)) {
      return getScreenWidth(context) - 24;
    } else if (isMobile(context)) {
      return getScreenWidth(context) - 32;
    } else if (isTablet(context)) {
      return (getScreenWidth(context) - 48) / 2;
    } else {
      return (getScreenWidth(context) - 64) / 3;
    }
  }
  
  // Responsive button sizing
  static double getButtonHeight(BuildContext context) {
    if (isSmallScreen(context)) {
      return 40.0;
    } else if (isMobile(context)) {
      return 48.0;
    } else if (isTablet(context)) {
      return 52.0;
    } else {
      return 56.0;
    }
  }

  static double getButtonWidth(BuildContext context) {
    if (isMobile(context)) {
      return double.infinity;
    } else {
      return 200;
    }
  }

  // Icon sizes
  static double getIconSize(BuildContext context) {
    if (isSmallScreen(context)) {
      return 20.0;
    } else if (isMobile(context)) {
      return 24.0;
    } else if (isTablet(context)) {
      return 28.0;
    } else {
      return 32.0;
    }
  }

  // Border radius
  static double getBorderRadius(BuildContext context) {
    if (isSmallScreen(context)) {
      return 8.0;
    } else if (isMobile(context)) {
      return 12.0;
    } else if (isTablet(context)) {
      return 16.0;
    } else {
      return 20.0;
    }
  }

  // Large border radius for cards
  static double getCardBorderRadius(BuildContext context) {
    return getBorderRadius(context) + 4;
  }
}
