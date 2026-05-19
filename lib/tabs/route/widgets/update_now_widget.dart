import 'package:analytics_services/analytics_services.dart';
import 'package:camino_ninja_flutter/app/cubit/app_cubit.dart';
import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

class UpdateNowWidget extends StatelessWidget {
  const UpdateNowWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: const Color(0xFFFFD231),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: ExpansionTile(
              title: Text(
                AppLocalizations.of(context).newDataAvailable,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
              ),
              iconColor: Colors.black,
              collapsedIconColor: Colors.black,
              minTileHeight: 1,
              tilePadding: EdgeInsets.zero,
              shape: Border.all(color: Colors.transparent),
              children: [
                Text(
                  AppLocalizations.of(context).newDataAvailableDescription,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.black,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 30,
            child: FilledButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all<Color>(
                  Colors.black,
                ),
              ),
              onPressed: () {
                GetIt.instance<IAnalyticsService>().track(
                  UpdateNowPressedEvent(),
                );

                context.read<AppCubit>().onFetchRoutes();
              },
              child: Text(
                AppLocalizations.of(context).updateNow,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
