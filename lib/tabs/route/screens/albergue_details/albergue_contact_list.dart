import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';

import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:camino_ninja_flutter/utils/safe_launcher.dart';
import 'package:collection/collection.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:storage/storage.dart';

class AlbergueContactList extends StatelessWidget {
  const AlbergueContactList({
    required this.phones,
    required this.emails,
    this.socialMedia,
    this.website,
    super.key,
  });

  final List<PhoneEntity> phones;
  final List<EmailEntity> emails;
  final SocialMediaEntity? socialMedia;
  final String? website;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final instagramHandle = socialMedia?.instagramHandle;
    final facebookUrl = socialMedia?.facebookUrl;
    final messenger = socialMedia?.messenger;
    final whatsapp = phones.firstWhereOrNull((e) => e.whatsapp);
    final haveOtherChannels =
        (instagramHandle != null && instagramHandle.isNotEmpty) ||
            (facebookUrl != null && facebookUrl.isNotEmpty) ||
            (messenger != null && messenger.isNotEmpty) ||
            (whatsapp != null && whatsapp.phoneNumber.isNotEmpty);
    final shouldShowContact = phones.isNotEmpty ||
        emails.isNotEmpty ||
        (website != null && website!.isNotEmpty);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (shouldShowContact) ...[
          Text(
            '${AppLocalizations.of(context).contact}:',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
        ],
        if (phones.isNotEmpty) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SvgPicture.asset(
                'assets/ic_phone.svg',
                width: 24,
                color: isDark ? Colors.white : Colors.black,
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppLocalizations.of(context).phone),
                  ...phones.map(
                    (phone) => InkWell(
                      onTap: () {
                        _launchPhone(phone);
                      },
                      child: Text(
                        phone.phoneNumber,
                        style: context.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.primary80
                              : AppColors.primary40,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        if (emails.isNotEmpty) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SvgPicture.asset(
                'assets/ic_mail.svg',
                width: 24,
                color: isDark ? Colors.white : Colors.black,
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppLocalizations.of(context).email),
                  ...emails.map(
                    (email) => InkWell(
                      onTap: () {
                        launchUrlSafely(
                          'mailto:${email.emailAddress}',
                        );
                      },
                      child: Text(
                        email.emailAddress,
                        style: context.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.primary80
                              : AppColors.primary40,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        if (website != null && website!.isNotEmpty) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                CommunityMaterialIcons.web,
                size: 24,
                color: isDark ? Colors.white : Colors.black,
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppLocalizations.of(context).website),
                  InkWell(
                    onTap: () {
                      launchUrlSafely(website!);
                    },
                    child: Text(
                      normalizeUrl(website!),
                      style: context.textTheme.bodyMedium?.copyWith(
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.bold,
                        color:
                            isDark ? AppColors.primary80 : AppColors.primary40,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
        if (shouldShowContact) ...[
          const SizedBox(height: 16),
        ],
        if (haveOtherChannels) ...[
          Text(
            '${AppLocalizations.of(context).otherChannels}:',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (whatsapp != null && whatsapp.phoneNumber.isNotEmpty) ...[
                InkWell(
                  borderRadius: BorderRadius.circular(100),
                  onTap: () {
                    launchWhatsApp(whatsapp.phoneNumber);
                  },
                  child: SvgPicture.asset(
                    'assets/ic_whatsapp.svg',
                    width: 32,
                  ),
                ),
                const SizedBox(width: 10),
              ],
              if (messenger != null && messenger.isNotEmpty) ...[
                InkWell(
                  borderRadius: BorderRadius.circular(100),
                  onTap: () {
                    launchUrlSafely(
                      'https://www.messenger.com/t/$messenger/',
                    );
                  },
                  child: SvgPicture.asset(
                    'assets/ic_messenger.svg',
                    width: 32,
                  ),
                ),
                const SizedBox(width: 10),
              ],
              if (instagramHandle != null && instagramHandle.isNotEmpty) ...[
                InkWell(
                  borderRadius: BorderRadius.circular(100),
                  onTap: () {
                    launchUrlSafely(
                      'https://www.instagram.com/$instagramHandle/',
                    );
                  },
                  child: SvgPicture.asset(
                    'assets/ic_instagram.svg',
                    width: 32,
                  ),
                ),
                const SizedBox(width: 10),
              ],
              if (facebookUrl != null && facebookUrl.isNotEmpty) ...[
                InkWell(
                  borderRadius: BorderRadius.circular(100),
                  onTap: () {
                    launchUrlSafely(facebookUrl);
                  },
                  child: SvgPicture.asset(
                    'assets/ic_facebook.svg',
                    width: 32,
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }

  // Launch WhatsApp
  Future<void> launchWhatsApp(String phoneNumber) async {
    final whatsappUrl =
        'whatsapp://send?phone=${phoneNumber.replaceAll(RegExp(r'\D+'), '')}';
    final whatsappUri = Uri.tryParse(whatsappUrl);
    if (whatsappUri == null) return;

    final isSuccess = await launchUrlSafely(whatsappUrl);
    if (!isSuccess) {
      await launchUrlSafely(
        'https://api.whatsapp.com/send?text=&phone='
        '${phoneNumber.replaceAll(RegExp(r'\D+'), '')}',
      );
    }
  }

  // Launch Signal
  Future<void> launchSignal(String phoneNumber) async {
    final signalUrl =
        'sgnl://signal.me/#p/+${phoneNumber.replaceAll(RegExp(r'\D+'), '')}';
    final signalUri = Uri.tryParse(signalUrl);

    if (signalUri == null) return;

    final isSuccess = await launchUrlSafely(signalUrl);
    if (!isSuccess) {
      await launchUrlSafely(
        'https://signal.me/#p/+'
        '${phoneNumber.replaceAll(RegExp(r'\D+'), '')}',
      );
    }
  }

  void _launchPhone(PhoneEntity phone) {
    if (phone.whatsapp) {
      launchWhatsApp(phone.phoneNumber);
      return;
    }

    if (phone.signal) {
      launchSignal(phone.phoneNumber);
      return;
    }

    launchUrlSafely('tel:${phone.phoneNumber}');
  }

  String normalizeUrl(String url) {
    var newUrl = url;
    newUrl = newUrl.replaceAll('http://', '');
    newUrl = newUrl.replaceAll('https://', '');
    newUrl = newUrl.replaceAll('www.', '');
    if (newUrl.indexOf('/') > 0) {
      newUrl = newUrl.substring(0, newUrl.indexOf('/'));
    }
    return newUrl;
  }
}
