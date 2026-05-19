import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/albergue_details/cubit/albergue_details_cubit.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:camino_ninja_flutter/widgets/settings_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:storage/storage.dart';

class AlbergueSettingSection extends StatelessWidget {
  const AlbergueSettingSection({
    required this.albergue,
    required this.supportedMaps,
    required this.onRateAccommodationClick,
    required this.onUploadPhotosClick,
    required this.onHelpUsImproveCaminoNinjaClick,
    required this.onTellYourFriendAboutThisPlaceClick,
    required this.onLocateOnOtherMapsClick,
    required this.onViewOnMapClick,
    super.key,
  });
  final AlbergueEntity albergue;
  final List<SupportedMaps> supportedMaps;
  final VoidCallback onRateAccommodationClick;
  final VoidCallback onUploadPhotosClick;
  final VoidCallback onHelpUsImproveCaminoNinjaClick;
  final VoidCallback onTellYourFriendAboutThisPlaceClick;
  final VoidCallback onLocateOnOtherMapsClick;
  final VoidCallback onViewOnMapClick;

  @override
  Widget build(BuildContext context) {
    final iconColor = context.isDarkMode ? Colors.white : Colors.black;
    final dividerColor =
        context.isDarkMode ? const Color(0xFF48454E) : AppColors.gray200;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        SettingsListItem(
          title: AppLocalizations.of(context).rateThisAccommodation,
          subtitle:
              AppLocalizations.of(context).giveARatingForThisAccommodation,
          trailing: SvgPicture.asset(
            'assets/ic_star_fill.svg',
            color: iconColor,
            width: 24,
          ),
          onClick: onRateAccommodationClick,
        ),
        Divider(color: dividerColor),
        SettingsListItem(
          title: AppLocalizations.of(context).uploadPhotos,
          subtitle:
              AppLocalizations.of(context).shareYourPhotosOfThisAccommodation,
          trailing: SvgPicture.asset(
            'assets/ic_upload.svg',
            color: iconColor,
            width: 24,
          ),
          onClick: onUploadPhotosClick,
        ),
        Divider(color: dividerColor),
        SettingsListItem(
          title: AppLocalizations.of(context).helpUsImproveCaminoNinja,
          subtitle:
              AppLocalizations.of(context).letUsKnowIfAnyInformationIsIncorrect,
          trailing: SvgPicture.asset(
            'assets/ic_warning_info.svg',
            color: iconColor,
            width: 24,
          ),
          onClick: onHelpUsImproveCaminoNinjaClick,
        ),
        Divider(color: dividerColor),
        if (albergue.shareUrl != null &&
            (albergue.shareUrl?.isNotEmpty ?? false)) ...[
          SettingsListItem(
            title: AppLocalizations.of(context).tellYourFriendAboutThisPlace,
            subtitle: AppLocalizations.of(context).shareMessageSocial,
            trailing: SvgPicture.asset(
              'assets/ic_share_all.svg',
              color: iconColor,
              width: 24,
            ),
            onClick: onTellYourFriendAboutThisPlaceClick,
          ),
          Divider(color: dividerColor),
        ],
        SettingsListItem(
          title: AppLocalizations.of(context).locateOnOtherMaps,
          subtitle: supportedMaps.map((e) => e.label).join(', '),
          trailing: SvgPicture.asset(
            'assets/ic_map_fill.svg',
            color: iconColor,
            width: 24,
          ),
          onClick: onLocateOnOtherMapsClick,
        ),
        Divider(color: dividerColor),
        SettingsListItem(
          title: AppLocalizations.of(context).viewOnMap,
          subtitle: AppLocalizations.of(context).locationRouteDestination,
          trailing: SvgPicture.asset(
            'assets/ic_map_pin_fill.svg',
            color: iconColor,
            width: 24,
          ),
          onClick: onViewOnMapClick,
        ),
      ],
    );
  }
}
