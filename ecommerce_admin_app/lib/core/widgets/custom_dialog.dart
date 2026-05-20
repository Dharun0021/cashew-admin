import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'custom_button.dart';

class CustomDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final String primaryButtonText;
  final VoidCallback? onPrimaryPressed;
  final String secondaryButtonText;
  final VoidCallback? onSecondaryPressed;
  final bool isDestructive;
  final bool isLoading;

  const CustomDialog({
    Key? key,
    required this.title,
    required this.content,
    this.primaryButtonText = 'Confirm',
    this.onPrimaryPressed,
    this.secondaryButtonText = 'Cancel',
    this.onSecondaryPressed,
    this.isDestructive = false,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      backgroundColor: AppColors.surface,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: content,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomButton(
                    text: secondaryButtonText,
                    type: CustomButtonType.text,
                    onPressed: isLoading ? null : (onSecondaryPressed ?? () => Navigator.pop(context)),
                  ),
                  const SizedBox(width: 12),
                  CustomButton(
                    text: primaryButtonText,
                    isLoading: isLoading,
                    customColor: isDestructive ? AppColors.error : null,
                    onPressed: onPrimaryPressed,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
