import 'package:flutter/material.dart';
import 'package:storage/storage.dart';

class AlbergueAddressSection extends StatelessWidget {
  const AlbergueAddressSection({required this.albergue, super.key});
  final AlbergueEntity albergue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        Text(
          albergue.address!,
          textAlign: TextAlign.center,
        ),
        if (albergue.postalCode != null)
          Text(
            '${albergue.postalCode} '
            '${albergue.cityName}',
            textAlign: TextAlign.center,
          ),
        if (albergue.province != null)
          Text(
            albergue.province!,
            textAlign: TextAlign.center,
          ),
        if (albergue.country != null)
          Text(
            albergue.country!,
            textAlign: TextAlign.center,
          ),
      ],
    );
  }
}
