import 'package:flutter/material.dart';
import '../../../core/utils/responsive_utils.dart';
import 'max_width_container.dart';

/// Scaffold adaptativo que muda navegação conforme screen size
class ResponsiveScaffold extends StatelessWidget {
  final String? title;
  final Widget body;
  final List<Widget>? actions;
  final FloatingActionButton? floatingActionButton;
  final int? currentNavIndex;
  final Function(int)? onNavIndexChanged;
  final List<NavigationDestination>? navigationDestinations;
  final bool useMaxWidth;
  final PreferredSizeWidget? appBar;

  const ResponsiveScaffold({
    super.key,
    this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.currentNavIndex,
    this.onNavIndexChanged,
    this.navigationDestinations,
    this.useMaxWidth = true,
    this.appBar,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);
    final isDesktop = ResponsiveUtils.isDesktop(context);

    // Desktop: NavigationRail + MaxWidth content
    if (isDesktop && navigationDestinations != null) {
      return Scaffold(
        body: Row(
          children: [
            // Navigation Rail
            NavigationRail(
              selectedIndex: currentNavIndex ?? 0,
              onDestinationSelected: onNavIndexChanged,
              extended: true,
              labelType: NavigationRailLabelType.none,
              destinations: navigationDestinations!
                  .map((dest) => NavigationRailDestination(
                        icon: dest.icon,
                        selectedIcon: dest.selectedIcon ?? dest.icon,
                        label: Text(dest.label),
                      ))
                  .toList(),
            ),
            const VerticalDivider(thickness: 1, width: 1),
            // Main content
            Expanded(
              child: Column(
                children: [
                  // AppBar (sem back button)
                  if (appBar != null)
                    appBar!
                  else if (title != null)
                    AppBar(
                      title: Text(title!),
                      automaticallyImplyLeading: false,
                      actions: actions,
                    ),
                  // Body
                  Expanded(
                    child: useMaxWidth
                        ? MaxWidthContainer(child: body)
                        : body,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Mobile/Tablet: Standard scaffold
    return Scaffold(
      appBar: appBar ??
          (title != null
              ? AppBar(
                  title: Text(title!),
                  actions: actions,
                )
              : null),
      body: useMaxWidth ? MaxWidthContainer(child: body) : body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: navigationDestinations != null && isMobile
          ? NavigationBar(
              selectedIndex: currentNavIndex ?? 0,
              onDestinationSelected: onNavIndexChanged,
              destinations: navigationDestinations!,
            )
          : null,
    );
  }
}
