import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final List<Color>? gradientColors;
  final double? width;
  final double? height;
  final BorderSide? borderSide;
  final VoidCallback? onTap;
  final bool enableHoverEffect;

  const CustomCard({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(20.0),
    this.color,
    this.gradientColors,
    this.width,
    this.height,
    this.borderSide,
    this.onTap,
    this.enableHoverEffect = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget cardContent = Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: gradientColors == null ? (color ?? AppColors.surface) : null,
        gradient: gradientColors != null
            ? LinearGradient(
                colors: gradientColors!,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        borderRadius: BorderRadius.circular(16),
        border: borderSide != null
            ? Border.fromBorderSide(borderSide!)
            : Border.all(color: AppColors.border, width: 1),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }
}
