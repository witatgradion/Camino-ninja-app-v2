import 'dart:async';

import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';

import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SearchField extends StatefulWidget {
  const SearchField({
    super.key, 
    this.onChanged, 
    this.onSubmit,
    this.enableDebouncer = false,
    this.debounceDuration = const Duration(milliseconds: 500),
  });
  final ValueChanged<String>? onChanged;
  final void Function(String)? onSubmit;
  final bool enableDebouncer;
  final Duration debounceDuration;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (widget.enableDebouncer) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(widget.debounceDuration, () {
        widget.onChanged?.call(value);
      });
    } else {
      widget.onChanged?.call(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.isDarkMode;
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        height: 45,
        child: TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          onTapOutside: (event) {
            FocusScope.of(context).unfocus();
          },
          onSubmitted: (value) {
            widget.onSubmit?.call(value);
          },
          decoration: InputDecoration(
            hintText: '${AppLocalizations.of(context).search}...',
            hintStyle: Theme.of(context).textTheme.bodyMedium,
            filled: true,
            fillColor:
                isDarkMode ? const Color(0xFF1F2A37) : const Color(0xFFE5E7EB),
            contentPadding: const EdgeInsets.symmetric(horizontal: 28),
            suffixIcon: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () {
                  widget.onSubmit?.call(_searchController.text);
                },
                child: Container(
                  width: 48,
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    'assets/ic_search.svg',
                    width: 24,
                    color:
                        isDarkMode ? AppColors.primary80 : AppColors.primary40,
                  ),
                ),
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide: BorderSide.none,
            ),
          ),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
