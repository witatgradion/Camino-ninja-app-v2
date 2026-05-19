import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomOutlineButton extends StatelessWidget {
  const CustomOutlineButton({
    required this.text,
    required this.onTap,
    super.key,
    this.isLoading = false,
    this.height,
    this.width,
    this.textColor,
    this.borderColor,
    this.prefixIcon,
    this.backgroundColor,
    this.padding,
  });
  final String text;
  final VoidCallback onTap;
  final bool isLoading;
  final double? height;
  final double? width;
  final Color? textColor;
  final Color? borderColor;
  final Color? backgroundColor;
  final Widget Function(Color)? prefixIcon;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    return Container(
      constraints: BoxConstraints(
        minHeight: height ?? 48,
      ),
      width: width,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.transparent,
            border: Border.all(
              color: borderColor ??
                  (isDark ? AppColors.primary80 : AppColors.primary40),
            ),
            borderRadius: BorderRadius.circular(100),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(100),
            onTap: () {
              if (isLoading) return;
              onTap();
            },
            child: Builder(
              builder: (context) {
                final content = isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(8),
                        child: CupertinoActivityIndicator(),
                      )
                    : RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            if (prefixIcon != null) ...[
                              WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: prefixIcon!(
                                  isDark
                                      ? AppColors.primary80
                                      : AppColors.primary40,
                                ),
                              ),
                              const WidgetSpan(child: SizedBox(width: 8)),
                            ],
                            TextSpan(
                              text: text,
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: textColor ??
                                    (isDark
                                        ? AppColors.primary80
                                        : AppColors.primary40),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                if (padding != null) {
                  return Padding(
                    padding: padding!,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        content,
                      ],
                    ),
                  );
                }
                return Center(
                  child: content,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
