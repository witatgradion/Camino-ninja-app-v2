import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:camino_ninja_flutter/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Result returned from [StageNoteBottomSheet].
sealed class StageNoteResult {
  const StageNoteResult();
  const factory StageNoteResult.clear() = StageNoteClearResult;
  const factory StageNoteResult.save(String text) = StageNoteSaveResult;
}

final class StageNoteClearResult extends StageNoteResult {
  const StageNoteClearResult();
}

final class StageNoteSaveResult extends StageNoteResult {
  const StageNoteSaveResult(this.text);
  final String text;
}

/// Open the stage-note editor as a modal bottom sheet.
///
/// Returns `null` when the user cancels, [StageNoteResult.clear] when the
/// user taps "Clear note" (or saves empty text), or
/// [StageNoteResult.save] with the trimmed text when the user saves a
/// non-empty note.
Future<StageNoteResult?> showStageNoteBottomSheet(
  BuildContext context, {
  String? initialNote,
}) {
  return showModalBottomSheet<StageNoteResult?>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) => StageNoteBottomSheet(initialNote: initialNote),
  );
}

class StageNoteBottomSheet extends StatefulWidget {
  const StageNoteBottomSheet({this.initialNote, super.key});

  /// Maximum allowed length for a stage note.
  static const int maxLength = 500;

  final String? initialNote;

  @override
  State<StageNoteBottomSheet> createState() => _StageNoteBottomSheetState();
}

class _StageNoteBottomSheetState extends State<StageNoteBottomSheet> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialNote ?? '');
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSave() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      context.pop(const StageNoteResult.clear());
      return;
    }
    context.pop(StageNoteResult.save(text));
  }

  void _onClear() {
    _controller.clear();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final primaryColor = isDark ? AppColors.primary80 : AppColors.primary40;
    final l10n = AppLocalizations.of(context);
    final viewInsets = MediaQuery.of(context).viewInsets;

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.gray800 : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.gray600 : AppColors.gray300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              l10n.stageNoteTitle,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.stageNoteDescription,
              style: context.textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              focusNode: _focusNode,
              maxLength: StageNoteBottomSheet.maxLength,
              minLines: 3,
              maxLines: 6,
              textInputAction: TextInputAction.newline,
              keyboardType: TextInputType.multiline,
              style: context.textTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: l10n.addANote,
                filled: true,
                fillColor: isDark ? Colors.black : AppColors.gray100,
                counterStyle: context.textTheme.bodySmall?.copyWith(
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryColor.withValues(alpha: 0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryColor.withValues(alpha: 0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryColor, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ListenableBuilder(
                  listenable: _controller,
                  builder: (context, _) {
                    final hasText = _controller.text.trim().isNotEmpty;
                    return _ClearNoteButton(
                      enabled: hasText,
                      onPressed: hasText ? _onClear : null,
                    );
                  },
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => context.pop(),
                  child: Text(
                    l10n.cancel,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: isDark ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 96,
                  child: CustomButton(
                    height: 44,
                    text: l10n.save,
                    onTap: _onSave,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ClearNoteButton extends StatelessWidget {
  const _ClearNoteButton({required this.enabled, required this.onPressed});

  final bool enabled;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final color = enabled ? AppColors.red700 : AppColors.gray400;
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
      child: Text(
        AppLocalizations.of(context).clearNote,
        style: context.textTheme.bodyMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
