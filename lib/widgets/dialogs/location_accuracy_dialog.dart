import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:flutter/material.dart';

class LocationAccuracyDialog extends StatefulWidget {
  const LocationAccuracyDialog(
      {required this.onAllow, required this.onDeny, super.key,});

  final VoidCallback onAllow;
  final void Function(bool doNotShowAgain) onDeny;

  @override
  State<LocationAccuracyDialog> createState() => _LocationAccuracyDialogState();
}

class _LocationAccuracyDialogState extends State<LocationAccuracyDialog> {
  bool _doNotShowAgain = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context).enableLocationAccuracy),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${AppLocalizations.of(context).locationAccuracyIntro}'
            '${AppLocalizations.of(context).locationAccuracyDetail}',
          ),
          InkWell(
            onTap: () {
              setState(() {
                _doNotShowAgain = !_doNotShowAgain;
              });
            },
            child: Row(
              children: [
                Checkbox(
                  value: _doNotShowAgain,
                  onChanged: (checked) {
                    setState(() {
                      _doNotShowAgain = checked ?? false;
                    });
                  },
                ),
                Text(AppLocalizations.of(context).doNotAskMeAgain),
              ],
            ),
          ),
        ],
      ),
      contentPadding: const EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
      ),
      actions: <Widget>[
        TextButton(
          child: Text(AppLocalizations.of(context).allow),
          onPressed: () {
            widget.onAllow();
            Navigator.of(context).pop(true);
          },
        ),
        TextButton(
          child: Text(AppLocalizations.of(context).deny),
          onPressed: () async {
            widget.onDeny(_doNotShowAgain);
            Navigator.of(context).pop(false);
          },
        ),
      ],
    );
  }
}
