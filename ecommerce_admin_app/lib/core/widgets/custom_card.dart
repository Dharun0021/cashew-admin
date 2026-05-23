import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class CustomCard extends StatefulWidget {
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
  State<CustomCard> createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final hoverOffset = widget.enableHoverEffect && _isHovered ? const Offset(0, -6) : Offset.zero;
    final hoverShadow = widget.enableHoverEffect && _isHovered
        ? [
            BoxShadow(
              color: widget.color == AppColors.primary
                  ? AppColors.primary.withOpacity(0.25)
                  : Colors.black.withOpacity(0.12),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ]
        : const [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 16,
              offset: Offset(0, 4),
            ),
          ];

    Widget cardContent = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      transform: Matrix4.translationValues(hoverOffset.dx, hoverOffset.dy, 0),
      width: widget.width,
      height: widget.height,
      padding: widget.padding,
      decoration: BoxDecoration(
        color: widget.gradientColors == null ? (widget.color ?? AppColors.surface) : null,
        gradient: widget.gradientColors != null
            ? LinearGradient(
                colors: widget.gradientColors!,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        borderRadius: BorderRadius.circular(16),
        border: widget.borderSide != null
            ? Border.fromBorderSide(widget.borderSide!)
            : Border.all(
                color: widget.enableHoverEffect && _isHovered
                    ? AppColors.primary.withOpacity(0.5)
                    : AppColors.border,
                width: 1,
              ),
        boxShadow: hoverShadow,
      ),
      child: widget.child,
    );

    if (widget.onTap != null || widget.enableHoverEffect) {
      return MouseRegion(
        cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onEnter: (_) {
          if (widget.enableHoverEffect) {
            setState(() {
              _isHovered = true;
            });
          }
        },
        onExit: (_) {
          if (widget.enableHoverEffect) {
            setState(() {
              _isHovered = false;
            });
          }
        },
        child: GestureDetector(
          onTap: widget.onTap,
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }
}
