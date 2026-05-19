import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    required this.text,
    required this.onTap,
    super.key,
    this.isLoading = false,
    this.prefixIcon,
    this.isDisabled = false,
    this.backgroundColor,
    this.textColor,
    this.padding,
    this.height,
  });
  final String text;
  final VoidCallback onTap;
  final bool isLoading;
  final bool isDisabled;
  final Widget Function(Color)? prefixIcon;
  final Color? backgroundColor;
  final Color? textColor;
  final EdgeInsets? padding;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: height ?? 48,
      ),
      child: Opacity(
        opacity: isDisabled ? 0.5 : 1,
        child: Material(
          color: Colors.transparent,
          child: Ink(
            decoration: BoxDecoration(
              color: backgroundColor ??
                  (isDark ? AppColors.primary80 : AppColors.primary40),
              borderRadius: BorderRadius.circular(100),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(100),
              onTap: () {
                if (isLoading || isDisabled) return;
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
                                    isDark ? Colors.black : Colors.white,
                                  ),
                                ),
                                const WidgetSpan(child: SizedBox(width: 8)),
                              ],
                              TextSpan(
                                text: text,
                                style: context.textTheme.bodyMedium?.copyWith(
                                  color: textColor ??
                                      (isDark ? Colors.black : Colors.white),
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
      ),
    );
  }
}
