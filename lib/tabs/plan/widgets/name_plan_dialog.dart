import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:camino_ninja_flutter/widgets/custom_button.dart';
import 'package:camino_ninja_flutter/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NamePlanDialog extends StatefulWidget {
  const NamePlanDialog({this.initialName, super.key});
  final String? initialName;

  @override
  State<NamePlanDialog> createState() => _NamePlanDialogState();
}

class _NamePlanDialogState extends State<NamePlanDialog> {
  late final TextEditingController _textController;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialName);
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: SizedBox(
        width: double.maxFinite,
        child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: context.isDarkMode ? AppColors.gray800 : Colors.white,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context).namePlanTitle,
              style: context.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _textController,
              focusNode: _focusNode,
              hintText: AppLocalizations.of(context).namePlanHint,
              maxLines: 2,
              onChanged: (value) {},
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: AppLocalizations.of(context).proceedWithName,
              onTap: () {
                final name = _textController.text.trim();
                context.pop(name.isEmpty ? '' : name);
              },
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                context.pop('');
              },
              child: Text(
                AppLocalizations.of(context).nameItLater,
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
