import 'package:camino_ninja_flutter/tabs/route/screens/albergue_details/cubit/albergue_details_cubit.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

Future<bool?> showMapOptionsBottomSheet(
  BuildContext context, {
  required List<SupportedMaps> supportedMaps,
  required ValueChanged<SupportedMaps> onMapSelected,
}) {
  return showModalBottomSheet<bool?>(
    context: context,
    backgroundColor: context.isDarkMode ? AppColors.gray800 : Colors.white,
    builder: (context) => MapOptionsBottomSheet(
      supportedMaps: supportedMaps,
      onMapSelected: onMapSelected,
    ),
  );
}

class MapOptionsBottomSheet extends StatelessWidget {
  const MapOptionsBottomSheet({
    required this.supportedMaps,
    required this.onMapSelected,
    super.key,
  });
  final List<SupportedMaps> supportedMaps;
  final ValueChanged<SupportedMaps> onMapSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: GestureDetector(
                onTap: () {
                  context.pop();
                },
                child: SvgPicture.asset(
                  'assets/ic_close.svg',
                  colorFilter: ColorFilter.mode(
                    context.isDarkMode
                        ? AppColors.primary80
                        : AppColors.primary40,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ],
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemBuilder: (context, index) => ListTile(
            title: Text(
              supportedMaps[index].label,
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            onTap: () => onMapSelected(supportedMaps[index]),
            trailing: const Icon(
              Icons.chevron_right,
              size: 32,
            ),
          ),
          separatorBuilder: (context, index) => const Divider(),
          itemCount: supportedMaps.length,
        ),
        const SizedBox(
          height: 8,
        ),
      ],
    );
  }
}
