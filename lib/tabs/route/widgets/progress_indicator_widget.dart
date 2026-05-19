import 'package:camino_ninja_flutter/app/cubit/app_cubit.dart';
import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/widgets/loading_widget.dart';
import 'package:flutter/material.dart';

class ProgressIndicatorWidget extends StatelessWidget {
  const ProgressIndicatorWidget({required this.state, super.key});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RepaintBoundary(
            child: LoadingProgressWidget(
              loadingProgress: state.loadingProgress,
              loadingTotal: state.loadingTotal,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              state.loadingData
                  ? AppLocalizations.of(context).loadingMessage
                  : AppLocalizations.of(context).updatingMessage,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
