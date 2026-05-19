import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/utils/safe_launcher.dart';

import 'package:camino_ninja_flutter/widgets/camino_ninja_title.dart';
import 'package:camino_ninja_flutter/widgets/settings_list_item.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';

class UsefulLinksScreen extends StatelessWidget {
  const UsefulLinksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CaminoNinjaAppBar(),
      body: ListView(
        children: [
          SettingsListItem(
            title: AppLocalizations.of(context).sendLuggage,
            subtitle: 'elcaminoconcorreos.com',
            trailing: const Icon(CommunityMaterialIcons.webpack),
            onClick: () async {
              await launchUrlSafely(
                'https://www.elcaminoconcorreos.com/en/transfer-luggage',
              );
            },
          ),
          const Divider(),
        ],
      ),
    );
  }
}
