import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:camino_ninja_flutter/widgets/custom_button.dart';
import 'package:camino_ninja_flutter/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ManualAddStayDialog extends StatefulWidget {
  const ManualAddStayDialog({super.key, this.initialValue});
  final String? initialValue;

  @override
  State<ManualAddStayDialog> createState() => _ManualAddStayDialogState();
}

class _ManualAddStayDialogState extends State<ManualAddStayDialog> {
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      _textController.text = widget.initialValue!;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: context.isDarkMode ? AppColors.gray800 : Colors.white,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context).letUsKnowStay,
              style: context.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _textController,
              hintText: AppLocalizations.of(context).enterSomething,
              maxLines: 3,
              onChanged: (value) {},
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: AppLocalizations.of(context).submit,
              onTap: () {
                context.pop(_textController.text);
              },
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                context.pop();
              },
              child: Text(
                AppLocalizations.of(context).selectFromTheList,
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
