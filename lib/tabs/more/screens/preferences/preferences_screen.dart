import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/services/notification_service.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';

import 'package:camino_ninja_flutter/widgets/camino_ninja_title.dart';
import 'package:camino_ninja_flutter/widgets/settings_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

class PreferencesScreen extends StatelessWidget {
  const PreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dividerColor =
        context.isDarkMode ? const Color(0xFF48454E) : AppColors.gray200;
    final iconColor = context.isDarkMode ? Colors.white : Colors.black;
    final titleColor =
        context.isDarkMode ? AppColors.primary80 : AppColors.primary40;
    return Scaffold(
      appBar: CaminoNinjaAppBar(
        title: AppLocalizations.of(context).preferences,
      ),
      body: ListView(
        children: [
          SettingsListItem(
            titleColor: titleColor,
            title: AppLocalizations.of(context).language,
            trailing: SvgPicture.asset(
              'assets/ic_language.svg',
              colorFilter: ColorFilter.mode(
                iconColor,
                BlendMode.srcIn,
              ),
            ),
            onClick: () {
              context.push('/more/select-language');
            },
          ),
          Divider(
            color: dividerColor,
            height: 1,
          ),
          SettingsListItem(
            titleColor: titleColor,
            title: AppLocalizations.of(context).theme,
            subtitle: AppLocalizations.of(context).lightDark,
            trailing: SvgPicture.asset(
              'assets/ic_theme.svg',
              colorFilter: ColorFilter.mode(
                iconColor,
                BlendMode.srcIn,
              ),
            ),
            onClick: () {
              context.push('/more/select-theme');
            },
          ),
          Divider(
            color: dividerColor,
            height: 1,
          ),
          SettingsListItem(
            titleColor: titleColor,
            title: AppLocalizations.of(context).switchUnit,
            subtitle: AppLocalizations.of(context).kmMiles,
            trailing: SvgPicture.asset(
              'assets/ic_switch_unit.svg',
              colorFilter: ColorFilter.mode(
                iconColor,
                BlendMode.srcIn,
              ),
            ),
            onClick: () {
              context.push('/more/select-unit');
            },
          ),
          Divider(
            color: dividerColor,
            height: 1,
          ),
          if (GetIt.instance.isRegistered<NotificationService>()) ...[
            SettingsListItem(
              titleColor: titleColor,
              title: AppLocalizations.of(context).notificationSettings,
              trailing: const Icon(
                Icons.notifications_outlined,
              ),
              onClick: () {
                context.push('/more/notification-settings');
              },
            ),
            Divider(
              color: dividerColor,
              height: 1,
            ),
          ],
        ],
      ),
    );
  }
}
