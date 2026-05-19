import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    this.hintText,
    this.maxLines = 1,
    this.onChanged,
    this.errorText,
    this.focusNode,
    this.textInputAction,
    this.controller,
  });
  final String? hintText;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    return TextField(
      focusNode: focusNode,
      controller: controller,
      onChanged: onChanged,
      maxLines: maxLines,
      style: context.textTheme.bodyLarge,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        errorText: errorText,
        contentPadding: const EdgeInsets.all(16),
        hintText: hintText,
        hintStyle: context.textTheme.bodyLarge?.copyWith(
          color: AppColors.gray500,
        ),
        errorStyle: context.textTheme.bodySmall?.copyWith(
          color: AppColors.error60,
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(
            color: AppColors.error60,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(
            color: AppColors.error60,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(
            color: isDark ? AppColors.neutral50 : AppColors.gray400,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(
            color: isDark ? AppColors.primary80 : AppColors.primary40,
          ),
        ),
      ),
    );
  }
}
