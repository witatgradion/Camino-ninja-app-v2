import 'package:camino_ninja_flutter/app/cubit/app_cubit.dart';
import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OfflineNoDataWidget extends StatelessWidget {
  const OfflineNoDataWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'You need to be online to load route information.\n'
              'After the first load, you can use the app offline.\n'
              'Please turn on your internet connection '
              'and try again.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AppCubit>().onFetchRoutes();
            },
            child: Text(AppLocalizations.of(context).retry),
          ),
        ],
      ),
    );
  }
}
