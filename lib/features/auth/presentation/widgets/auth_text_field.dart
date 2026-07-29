import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';

class AuthTextField extends StatelessWidget {
  final String label;
  final String hint;
  final String? errorText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final FocusNode? focusNode;
  final FocusNode? nextFocusNode;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;

  const AuthTextField({
    super.key,
    required this.label,
    required this.hint,
    this.errorText,
    this.controller,
    this.onChanged,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.focusNode,
    this.nextFocusNode,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          label: label,
          child: Text(
            label,
            style: AppTypography.titleMedium(isDark: isDark).copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            focusNode: focusNode,
            enabled: enabled,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            onSubmitted: (_) {
              if (nextFocusNode != null) {
                FocusScope.of(context).requestFocus(nextFocusNode);
              }
            },
            style: AppTypography.bodyLarge(isDark: isDark),
            decoration: InputDecoration(
              hintText: hint,
              errorText: errorText,
              prefixIcon: prefixIcon != null
                  ? Icon(
                      prefixIcon,
                      size: 20,
                      color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                    )
                  : null,
              suffixIcon: suffixIcon,
            ),
          ),
        ),
      ],
    );
  }
}
