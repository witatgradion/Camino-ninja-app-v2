import 'package:analytics_services/analytics_services.dart';
import 'package:camino_ninja_flutter/app/cubit/app_cubit.dart';
import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:camino_ninja_flutter/utils/unit_converter.dart';

import 'package:camino_ninja_flutter/widgets/camino_ninja_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';

class SelectUnitScreen extends StatelessWidget {
  const SelectUnitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      builder: (context, appState) {
        final isDarkMode = context.isDarkMode;

        return Scaffold(
          appBar: CaminoNinjaAppBar(
            title: AppLocalizations.of(context).selectUnit,
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  AppLocalizations.of(context).switchUnitKmMiles,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                  ),
                  itemBuilder: (context, index) {
                    final unit = UnitEnum.values[index];
                    final isSelected = appState.unit == unit;
                    return InkWell(
                      onTap: () {
                        context.read<AppCubit>().onChangeUnit(unit: unit);
                        GetIt.instance<IAnalyticsService>().track(
                          UnitChangedEvent(unit: unit.name),
                        );
                      },
                      child: SizedBox(
                        height: 52,
                        child: Row(
                          children: [
                            const SizedBox(width: 24),
                            Expanded(
                              child: Text(
                                unit.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w400,
                                    ),
                              ),
                            ),
                            if (isSelected)
                              SvgPicture.asset(
                                'assets/ic_check_circle.svg',
                                width: 24,
                                color: isDarkMode
                                    ? AppColors.primary80
                                    : AppColors.primary40,
                              ),
                            const SizedBox(width: 16),
                          ],
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return Container(
                      height: 1,
                      color: isDarkMode
                          ? const Color(0xFF48454E)
                          : const Color(0xFFE5E7EB),
                    );
                  },
                  itemCount: UnitEnum.values.length,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
