import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/safe_launcher.dart';

import 'package:camino_ninja_flutter/widgets/camino_ninja_title.dart';
import 'package:camino_ninja_flutter/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

const String _namePlaceholder = '{name}';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CaminoNinjaAppBar(
        title: AppLocalizations.of(context).contact,
      ),
      body: ListView(
        children: [
          _ContactCard(
            showAnimation: true,
            shortName: 'Peter',
            fullName: 'Peter Eich',
            title: AppLocalizations.of(context).headOfCaminoNinja,
            contactEmail: 'info@caminoninja.com',
            description:
                AppLocalizations.of(context).peterDescription(_namePlaceholder),
            imagePath: 'assets/avatar_peter.webp',
            cardColor: AppColors.primary20,
          ),
          const SizedBox(height: 8),
          _ContactCard(
            shortName: 'Merlin',
            fullName: 'Merlin',
            title: AppLocalizations.of(context).headOfData,
            contactEmail: 'update@caminoninja.com',
            description: AppLocalizations.of(context)
                .merlinDescription(_namePlaceholder),
            imagePath: 'assets/avatar_merlin.webp',
            cardColor: AppColors.gray800,
          ),
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.title,
    required this.shortName,
    required this.fullName,
    required this.contactEmail,
    required this.description,
    required this.imagePath,
    required this.cardColor,
    this.showAnimation = false,
  });
  final bool showAnimation;
  final String title;
  final String shortName;
  final String fullName;
  final String contactEmail;
  final String description;
  final String imagePath;
  final Color cardColor;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          color: cardColor,
          margin: EdgeInsets.only(top: showAnimation ? 50 : 0),
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
          ),
          child: Column(
            children: [
              SizedBox(height: showAnimation ? 24 : 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: context.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          contactEmail,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: AppColors.primary80,
                          ),
                        ),
                        const SizedBox(height: 16),
                        CustomButton(
                          height: 32,
                          text: AppLocalizations.of(context)
                              .contactPerson(shortName),
                          onTap: () {
                            launchUrlSafely(
                              'mailto:$contactEmail',
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 4,
                    child: Column(
                      children: [
                        AspectRatio(
                          aspectRatio: 1,
                          child: Image.asset(
                            imagePath,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _styleDescription(context),
              const SizedBox(height: 20),
            ],
          ),
        ),
        if (showAnimation) ...[
          Positioned(
            top: 0,
            left: 0,
            child: SizedBox(
              width: 110,
              child: Lottie.asset('assets/lottie/sending_email.json'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _styleDescription(BuildContext context) {
    final parts = description.split(_namePlaceholder);
    return RichText(
      text: TextSpan(
        style: context.textTheme.bodyMedium?.copyWith(color: Colors.white),
        children: [
          TextSpan(text: parts[0]),
          TextSpan(
            text: fullName,
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          if (parts.length > 1) TextSpan(text: parts[1]),
        ],
      ),
    );
  }
}
