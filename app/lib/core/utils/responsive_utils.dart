import 'package:flutter/material.dart';

/// Utility class for responsive design across platforms
class ResponsiveUtils {
  // Breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;
  static const double largeDesktopBreakpoint = 1600;

  /// Check if current platform is mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  /// Check if current platform is tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < desktopBreakpoint;
  }

  /// Check if current platform is desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopBreakpoint;
  }

  /// Check if current platform is large desktop
  static bool isLargeDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= largeDesktopBreakpoint;
  }

  /// Get screen type
  static ScreenType getScreenType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) return ScreenType.mobile;
    if (width < desktopBreakpoint) return ScreenType.tablet;
    if (width < largeDesktopBreakpoint) return ScreenType.desktop;
    return ScreenType.largeDesktop;
  }

  /// Get responsive value based on screen size
  static T valueByScreen<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
    T? largeDesktop,
  }) {
    final screenType = getScreenType(context);
    switch (screenType) {
      case ScreenType.mobile:
        return mobile;
      case ScreenType.tablet:
        return tablet ?? mobile;
      case ScreenType.desktop:
        return desktop ?? tablet ?? mobile;
      case ScreenType.largeDesktop:
        return largeDesktop ?? desktop ?? tablet ?? mobile;
    }
  }

  /// Get responsive padding
  static EdgeInsets responsivePadding(BuildContext context) {
    return EdgeInsets.all(valueByScreen(
      context: context,
      mobile: 16.0,
      tablet: 24.0,
      desktop: 32.0,
      largeDesktop: 48.0,
    ));
  }

  /// Get responsive font size
  static double responsiveFontSize(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    return valueByScreen(
      context: context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }

  /// Get grid columns count based on screen size
  static int getGridColumns(BuildContext context) {
    return valueByScreen(
      context: context,
      mobile: 1,
      tablet: 2,
      desktop: 3,
      largeDesktop: 4,
    );
  }

  /// Get max content width (for centering content on large screens)
  static double getMaxContentWidth(BuildContext context) {
    return valueByScreen(
      context: context,
      mobile: double.infinity,
      tablet: 800,
      desktop: 1200,
      largeDesktop: 1400,
    );
  }

  /// Check if should use side navigation (drawer/rail)
  static bool shouldUseSideNavigation(BuildContext context) {
    return !isMobile(context);
  }

  /// Get responsive card elevation
  static double getCardElevation(BuildContext context) {
    return valueByScreen(
      context: context,
      mobile: 2.0,
      tablet: 4.0,
      desktop: 6.0,
    );
  }

  /// Get responsive border radius
  static double getBorderRadius(BuildContext context) {
    return valueByScreen(
      context: context,
      mobile: 12.0,
      tablet: 16.0,
      desktop: 20.0,
    );
  }

  /// Get responsive spacing
  static double getSpacing(BuildContext context, {double multiplier = 1.0}) {
    return valueByScreen(
      context: context,
      mobile: 8.0 * multiplier,
      tablet: 12.0 * multiplier,
      desktop: 16.0 * multiplier,
    );
  }

  /// Check if device is in landscape mode
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Get safe padding (considering notches, etc.)
  static EdgeInsets getSafePadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  /// Get responsive dialog width
  static double getDialogWidth(BuildContext context) {
    return valueByScreen(
      context: context,
      mobile: MediaQuery.of(context).size.width * 0.9,
      tablet: 500,
      desktop: 600,
    );
  }

  /// Get content padding based on screen size
  static EdgeInsets getContentPadding(BuildContext context) {
    return EdgeInsets.all(valueByScreen(
      context: context,
      mobile: 16.0,
      tablet: 24.0,
      desktop: 32.0,
    ));
  }

  /// Get card padding based on screen size
  static EdgeInsets getCardPadding(BuildContext context) {
    return EdgeInsets.all(valueByScreen(
      context: context,
      mobile: 16.0,
      tablet: 20.0,
      desktop: 24.0,
    ));
  }

  /// Get optimal grid columns for dashboard
  static int getDashboardColumns(BuildContext context) {
    return valueByScreen(
      context: context,
      mobile: 1,
      tablet: 2,
      desktop: 3,
      largeDesktop: 4,
    );
  }

  /// Check if should show FAB or toolbar button
  static bool shouldShowFAB(BuildContext context) {
    return isMobile(context);
  }

  /// Get optimal chart height
  static double getChartHeight(BuildContext context) {
    return valueByScreen(
      context: context,
      mobile: 250.0,
      tablet: 300.0,
      desktop: 350.0,
    );
  }
}

/// Screen type enum
enum ScreenType {
  mobile,
  tablet,
  desktop,
  largeDesktop,
}

/// Responsive builder widget
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, ScreenType screenType) builder;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final screenType = ResponsiveUtils.getScreenType(context);
    return builder(context, screenType);
  }
}

/// Responsive widget that shows different widgets based on screen size
class ResponsiveWidget extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? largeDesktop;

  const ResponsiveWidget({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.largeDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, screenType) {
        switch (screenType) {
          case ScreenType.mobile:
            return mobile;
          case ScreenType.tablet:
            return tablet ?? mobile;
          case ScreenType.desktop:
            return desktop ?? tablet ?? mobile;
          case ScreenType.largeDesktop:
            return largeDesktop ?? desktop ?? tablet ?? mobile;
        }
      },
    );
  }
}

/// Responsive layout with max width constraint
class ResponsiveLayout extends StatelessWidget {
  final Widget child;
  final bool centerContent;
  final EdgeInsets? padding;

  const ResponsiveLayout({
    super.key,
    required this.child,
    this.centerContent = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final maxWidth = ResponsiveUtils.getMaxContentWidth(context);
    final defaultPadding = ResponsiveUtils.responsivePadding(context);

    Widget content = Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      padding: padding ?? defaultPadding,
      child: child,
    );

    if (centerContent && maxWidth != double.infinity) {
      content = Center(child: content);
    }

    return content;
  }
}

/// Responsive grid view
class ResponsiveGridView extends StatelessWidget {
  final List<Widget> children;
  final double? spacing;
  final double? runSpacing;
  final int? mobileColumns;
  final int? tabletColumns;
  final int? desktopColumns;
  final double? childAspectRatio;

  const ResponsiveGridView({
    super.key,
    required this.children,
    this.spacing,
    this.runSpacing,
    this.mobileColumns,
    this.tabletColumns,
    this.desktopColumns,
    this.childAspectRatio,
  });

  @override
  Widget build(BuildContext context) {
    final columns = ResponsiveUtils.valueByScreen(
      context: context,
      mobile: mobileColumns ?? 1,
      tablet: tabletColumns ?? 2,
      desktop: desktopColumns ?? 3,
    );

    final defaultSpacing = ResponsiveUtils.getSpacing(context);

    return GridView.count(
      crossAxisCount: columns,
      crossAxisSpacing: spacing ?? defaultSpacing,
      mainAxisSpacing: runSpacing ?? defaultSpacing,
      childAspectRatio: childAspectRatio ?? 1.0,
      children: children,
    );
  }
}

/// Responsive column that changes to row on larger screens
class ResponsiveFlexLayout extends StatelessWidget {
  final List<Widget> children;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;

  const ResponsiveFlexLayout({
    super.key,
    required this.children,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.max,
  });

  @override
  Widget build(BuildContext context) {
    if (ResponsiveUtils.isMobile(context)) {
      return Column(
        crossAxisAlignment: crossAxisAlignment,
        mainAxisAlignment: mainAxisAlignment,
        mainAxisSize: mainAxisSize,
        children: children,
      );
    }

    return Row(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: children.map((child) => Expanded(child: child)).toList(),
    );
  }
}
