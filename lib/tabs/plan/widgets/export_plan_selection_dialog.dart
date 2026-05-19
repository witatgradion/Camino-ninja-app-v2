import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:camino_ninja_flutter/utils/model_extensions.dart';
import 'package:camino_ninja_flutter/widgets/custom_button.dart';
import 'package:camino_ninja_flutter/widgets/route_name_text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:repository/repository.dart';

class ExportPlanSelectionDialog extends StatelessWidget {
  const ExportPlanSelectionDialog({required this.plans, super.key});
  final List<StagePlanModel> plans;

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height / 3 * 2;
    return AlertDialog(
      backgroundColor: context.isDarkMode ? AppColors.gray800 : Colors.white,
      contentPadding: EdgeInsets.zero,
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: maxHeight,
          minWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        child: _ExportPlanSelectionBody(plans: plans),
      ),
    );
  }
}

class _ExportPlanSelectionBody extends StatefulWidget {
  const _ExportPlanSelectionBody({required this.plans});
  final List<StagePlanModel> plans;

  @override
  State<_ExportPlanSelectionBody> createState() =>
      __ExportPlanSelectionBodyState();
}

class __ExportPlanSelectionBodyState extends State<_ExportPlanSelectionBody> {
  int? _selectedPlanId;

  @override
  Widget build(BuildContext context) {
    final bgColor = context.isDarkMode ? AppColors.gray800 : Colors.white;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            AppLocalizations.of(context).selectPlansToShare,
            style: context.textTheme.bodyMedium,
          ),
        ),
        const SizedBox(height: 16),
        Flexible(
          child: ClipRect(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: widget.plans
                    .map(
                      (plan) => Material(
                        color: bgColor,
                        child: _buildRadioTile(
                          planId: plan.id,
                          title: RouteNameText(
                            routeName: plan.route.routeName,
                            routeSubName: plan.route.routeSubName ?? '',
                            textStyle: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: context.isDarkMode
                                      ? AppColors.primary80
                                      : AppColors.primary40,
                                ),
                          ),
                          subtitle: plan.getPlanSubtitle(context, plan),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: CustomButton(
            text: AppLocalizations.of(context).share,
            onTap: _onShare,
            isDisabled: _selectedPlanId == null,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: TextButton(
            onPressed: () => context.pop(),
            child: Text(
              AppLocalizations.of(context).cancel,
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildRadioTile({
    required int planId,
    required Widget title,
    required String subtitle,
  }) {
    final radioColor =
        context.isDarkMode ? AppColors.primary80 : AppColors.primary40;
    return RadioListTile<int>(
      value: planId,
      groupValue: _selectedPlanId,
      onChanged: (value) => setState(() => _selectedPlanId = value),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      fillColor: WidgetStateProperty.all(radioColor),
      title: title,
      subtitle: Text(
        subtitle,
        style: context.textTheme.bodySmall,
      ),
    );
  }

  void _onShare() {
    if (_selectedPlanId == null) return;
    final selectedPlan = widget.plans.firstWhere(
      (plan) => plan.id == _selectedPlanId,
    );
    context.pop([selectedPlan]);
  }
}
