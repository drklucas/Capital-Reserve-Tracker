import 'package:flutter/material.dart';
import '../../core/utils/responsive_utils.dart';

/// Navigation destination model for adaptive navigation
class AdaptiveNavigationDestination {
  final Widget icon;
  final Widget? selectedIcon;
  final String label;
  final String? tooltip;

  const AdaptiveNavigationDestination({
    required this.icon,
    this.selectedIcon,
    required this.label,
    this.tooltip,
  });
}

/// Adaptive navigation that switches between bottom bar and side navigation
class AdaptiveNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onDestinationSelected;
  final List<AdaptiveNavigationDestination> destinations;
  final Widget child;
  final String? title;

  const AdaptiveNavigation({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.destinations,
    required this.child,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    if (ResponsiveUtils.isMobile(context)) {
      return _MobileNavigation(
        currentIndex: currentIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: destinations,
        title: title,
        child: child,
      );
    }

    return _DesktopNavigation(
      currentIndex: currentIndex,
      onDestinationSelected: onDestinationSelected,
      destinations: destinations,
      title: title,
      child: child,
    );
  }
}

/// Mobile navigation with bottom navigation bar
class _MobileNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onDestinationSelected;
  final List<AdaptiveNavigationDestination> destinations;
  final Widget child;
  final String? title;

  const _MobileNavigation({
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.destinations,
    required this.child,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: title != null
          ? AppBar(
              title: Text(title!),
              centerTitle: false,
            )
          : null,
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: destinations.map((dest) {
          return NavigationDestination(
            icon: dest.icon,
            selectedIcon: dest.selectedIcon,
            label: dest.label,
          );
        }).toList(),
      ),
    );
  }
}

/// Desktop navigation with navigation rail or drawer
class _DesktopNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onDestinationSelected;
  final List<AdaptiveNavigationDestination> destinations;
  final Widget child;
  final String? title;

  const _DesktopNavigation({
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.destinations,
    required this.child,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveUtils.isDesktop(context);

    return Scaffold(
      body: Row(
        children: [
          // Navigation Rail
          NavigationRail(
            selectedIndex: currentIndex,
            onDestinationSelected: onDestinationSelected,
            extended: isDesktop,
            labelType: isDesktop
                ? NavigationRailLabelType.none
                : NavigationRailLabelType.all,
            destinations: destinations.map((dest) {
              return NavigationRailDestination(
                icon: dest.icon,
                selectedIcon: dest.selectedIcon ?? dest.icon,
                label: Text(dest.label),
              );
            }).toList(),
            leading: isDesktop && title != null
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      title!,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  )
                : null,
          ),
          const VerticalDivider(thickness: 1, width: 1),
          // Main content
          Expanded(
            child: child,
          ),
        ],
      ),
    );
  }
}


/// Adaptive app bar that changes based on screen size
class AdaptiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final PreferredSizeWidget? bottom;

  const AdaptiveAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);

    return AppBar(
      title: Text(title),
      centerTitle: isMobile,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      actions: actions,
      bottom: bottom,
      toolbarHeight: ResponsiveUtils.valueByScreen(
        context: context,
        mobile: 56.0,
        tablet: 64.0,
        desktop: 72.0,
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        ResponsiveUtils.valueByScreen(
          context: NavigationToolbar as BuildContext,
          mobile: 56.0,
          tablet: 64.0,
          desktop: 72.0,
        ),
      );
}

/// Adaptive dialog that adjusts size based on screen
class AdaptiveDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget>? actions;

  const AdaptiveDialog({
    super.key,
    required this.title,
    required this.content,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: ResponsiveUtils.getDialogWidth(context),
        ),
        child: Padding(
          padding: ResponsiveUtils.responsivePadding(context),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: ResponsiveUtils.getSpacing(context)),
              content,
              if (actions != null) ...[
                SizedBox(height: ResponsiveUtils.getSpacing(context, multiplier: 2)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: actions!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget content,
    List<Widget>? actions,
  }) {
    return showDialog<T>(
      context: context,
      builder: (context) => AdaptiveDialog(
        title: title,
        content: content,
        actions: actions,
      ),
    );
  }
}

/// Adaptive card with responsive elevation and border radius
class AdaptiveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;

  const AdaptiveCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: ResponsiveUtils.getCardElevation(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getBorderRadius(context),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getBorderRadius(context),
        ),
        child: Padding(
          padding: padding ??
              EdgeInsets.all(ResponsiveUtils.getSpacing(context, multiplier: 2)),
          child: child,
        ),
      ),
    );
  }
}

/// Adaptive list tile with responsive padding
class AdaptiveListTile extends StatelessWidget {
  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const AdaptiveListTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: leading,
      title: title,
      subtitle: subtitle,
      trailing: trailing,
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.getSpacing(context, multiplier: 2),
        vertical: ResponsiveUtils.getSpacing(context),
      ),
    );
  }
}

/// Responsive form field with adaptive sizing
class AdaptiveTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final Widget? prefix;
  final Widget? suffix;
  final int? maxLines;

  const AdaptiveTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
    this.prefix,
    this.suffix,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      maxLines: maxLines,
      style: TextStyle(
        fontSize: ResponsiveUtils.responsiveFontSize(
          context,
          mobile: 14,
          tablet: 15,
          desktop: 16,
        ),
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefix,
        suffixIcon: suffix,
        contentPadding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.getSpacing(context, multiplier: 2),
          vertical: ResponsiveUtils.getSpacing(context, multiplier: 1.5),
        ),
      ),
    );
  }
}

/// Adaptive button with responsive sizing
class AdaptiveButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isPrimary;
  final IconData? icon;

  const AdaptiveButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isPrimary = true,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final buttonChild = isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: 8),
              ],
              Text(label),
            ],
          );

    final buttonStyle = isPrimary
        ? ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.getSpacing(context, multiplier: 3),
              vertical: ResponsiveUtils.getSpacing(context, multiplier: 2),
            ),
          )
        : OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.getSpacing(context, multiplier: 3),
              vertical: ResponsiveUtils.getSpacing(context, multiplier: 2),
            ),
          );

    if (isPrimary) {
      return ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: buttonStyle,
        child: buttonChild,
      );
    }

    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: buttonStyle,
      child: buttonChild,
    );
  }
}
