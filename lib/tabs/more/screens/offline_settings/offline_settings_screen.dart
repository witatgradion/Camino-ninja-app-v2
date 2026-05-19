import 'package:camino_ninja_flutter/widgets/camino_ninja_title.dart';
import 'package:flutter/material.dart';

class OfflineSettingsScreen extends StatelessWidget {
  const OfflineSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CaminoNinjaAppBar(),
      body: Center(child: Text('Offline Settings Screen')),
    );
  }
}
