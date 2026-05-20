import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

enum CustomButtonType { primary, secondary, outlined, text }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final CustomButtonType type;
  final bool isLoading;
  final IconData? icon;
  final Color? customColor;
  final Color? customTextColor;
  final double? width;
  final double height;

  const CustomButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.type = CustomButtonType.primary,
    this.isLoading = false,
    this.icon,
    this.customColor,
    this.customTextColor,
    this.width,
    this.height = 48.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = onPressed != null && !isLoading;

    Color buttonColor;
    Color textColor;
    BorderSide borderSide = BorderSide.none;

    switch (type) {
      case CustomButtonType.primary:
        buttonColor = customColor ?? AppColors.primary;
        textColor = customTextColor ?? Colors.white;
        break;
      case CustomButtonType.secondary:
        buttonColor = customColor ?? AppColors.secondary;
        textColor = customTextColor ?? AppColors.textPrimary;
        break;
      case CustomButtonType.outlined:
        buttonColor = Colors.transparent;
        textColor = customTextColor ?? AppColors.primary;
        borderSide = BorderSide(color: customColor ?? AppColors.primary, width: 1.5);
        break;
      case CustomButtonType.text:
        buttonColor = Colors.transparent;
        textColor = customTextColor ?? AppColors.primary;
        break;
    }

    if (!isEnabled) {
      buttonColor = type == CustomButtonType.primary || type == CustomButtonType.secondary
          ? AppColors.border
          : Colors.transparent;
      textColor = AppColors.textLight;
      borderSide = type == CustomButtonType.outlined
          ? const BorderSide(color: AppColors.border, width: 1.5)
          : BorderSide.none;
    }

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(textColor),
            ),
          ),
          const SizedBox(width: 10),
        ] else if (icon != null) ...[
          Icon(icon, size: 20, color: textColor),
          const SizedBox(width: 8),
        ],
        Text(
          text,
          style: theme.textTheme.titleMedium?.copyWith(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );

    if (type == CustomButtonType.text) {
      return TextButton(
        onPressed: isEnabled ? onPressed : null,
        style: TextButton.styleFrom(
          minimumSize: Size(width ?? 0, height),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: content,
      );
    }

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: borderSide,
          ),
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
        ),
        child: content,
      ),
    );
  }
}
