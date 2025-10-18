import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final bool isFullWidth;
  final bool isOutlined;
  final bool isLoading;
  final IconData? icon;
  final Color? color;
  final Color? textColor;
  final double? height;
  final double? fontSize;
  final EdgeInsetsGeometry? padding;

  const CustomButton({
    Key? key,
    required this.onPressed,
    required this.text,
    this.isFullWidth = false,
    this.isOutlined = false,
    this.isLoading = false,
    this.icon,
    this.color,
    this.textColor,
    this.height = 50,
    this.fontSize = 16,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonColor = color ?? theme.primaryColor;
    final buttonTextColor = textColor ??
        (isOutlined ? buttonColor : Colors.white);

    Widget button = isOutlined
        ? OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: buttonTextColor,
              minimumSize: Size.fromHeight(height ?? 50),
              padding: padding ??
                  const EdgeInsets.symmetric(
                    horizontal: AppConstants.defaultPadding,
                    vertical: 12,
                  ),
              side: BorderSide(
                color: buttonColor,
                width: 2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppConstants.defaultBorderRadius,
                ),
              ),
            ),
            child: _buildButtonContent(buttonTextColor),
          )
        : ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              foregroundColor: buttonTextColor,
              minimumSize: Size.fromHeight(height ?? 50),
              padding: padding ??
                  const EdgeInsets.symmetric(
                    horizontal: AppConstants.defaultPadding,
                    vertical: 12,
                  ),
              elevation: AppConstants.defaultElevation,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppConstants.defaultBorderRadius,
                ),
              ),
            ),
            child: _buildButtonContent(buttonTextColor),
          );

    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }

  Widget _buildButtonContent(Color textColor) {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(textColor),
        ),
      );
    }

    final textWidget = Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
    );

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          textWidget,
        ],
      );
    }

    return textWidget;
  }
}