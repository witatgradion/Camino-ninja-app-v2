import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/utils/location_service.dart';
import 'package:camino_ninja_flutter/widgets/location_permission_guide.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:repository/repository.dart';

class LocationServiceDialog extends StatefulWidget {
  const LocationServiceDialog({
    super.key,
    this.shouldShowDoNotShowAgain = true,
  });
  final bool shouldShowDoNotShowAgain;

  @override
  State<LocationServiceDialog> createState() => _LocationServiceDialogState();
}

class _LocationServiceDialogState extends State<LocationServiceDialog> {

  bool _doNotShowAgain = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context).locationRequired),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const LocationPermissionGuide(textAlign: TextAlign.left),
          if (widget.shouldShowDoNotShowAgain) ...[
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
        ],
      ),
      contentPadding: const EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
      ),
      actions: <Widget>[
        if (Platform.isAndroid)
          TextButton(
            child: Text(AppLocalizations.of(context).openSettings),
            onPressed: () async {
              Navigator.of(context).pop();

              var isServiceEnable = false;
              try {
                isServiceEnable = await LocationService.isServiceEnabled();
              } catch (ignore) {}

              if (isServiceEnable) {
                // Open app setting in case location services enable
                await LocationService.openAppSettings();
                return;
              }

              // // Else, open location services setting
              await AppSettings.openAppSettings(
                type: AppSettingsType.location,
              );
            },
          ),
        TextButton(
          child: Text(AppLocalizations.of(context).later),
          onPressed: () {
            if(_doNotShowAgain) {
              GetIt.instance<Repository>().setDoNotAskLocationRequired(true);
            }
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
