import 'package:flutter/material.dart';
import '../../../core/utils/responsive_utils.dart';

/// Container que limita largura máxima e centraliza conteúdo
class MaxWidthContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsets? padding;
  final bool centerContent;

  const MaxWidthContainer({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
    this.centerContent = true,
  });

  @override
  Widget build(BuildContext context) {
    final defaultMaxWidth = ResponsiveUtils.getMaxContentWidth(context);
    final effectiveMaxWidth = maxWidth ?? defaultMaxWidth;

    Widget content = Container(
      constraints: BoxConstraints(maxWidth: effectiveMaxWidth),
      padding: padding ?? ResponsiveUtils.responsivePadding(context),
      child: child,
    );

    if (centerContent && effectiveMaxWidth != double.infinity) {
      content = Center(child: content);
    }

    return content;
  }
}
