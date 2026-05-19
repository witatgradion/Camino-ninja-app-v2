import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:storage/storage.dart';

class ServiceIcon extends StatelessWidget {
  const ServiceIcon({
    required this.serviceType,
    this.size = 24,
    super.key,
  });

  final AvailableService serviceType;
  final double size;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.isDarkMode;
    switch (serviceType) {
      case AvailableService.hotel:
        return Icon(
          Icons.home,
          size: size,
        );
      case AvailableService.atm:
        return Icon(
          Icons.local_atm,
          size: size,
        );
      case AvailableService.cafe:
        return Icon(
          Icons.local_cafe,
          size: size,
        );
      case AvailableService.restaurant:
        return Icon(
          Icons.restaurant,
          size: size,
        );
      case AvailableService.shopping:
        return Icon(
          Icons.local_grocery_store,
          size: size,
        );
      case AvailableService.tobacco:
        return Image.asset(
          'assets/tabacos-lightgray.png',
          width: size,
          height: size,
          color: isDarkMode ? Colors.white : Colors.black,
        );
      case AvailableService.clinic:
        return Icon(
          Icons.local_hospital,
          size: size,
        );
      case AvailableService.pharmacy:
        return Icon(
          Icons.local_pharmacy,
          size: size,
        );
      case AvailableService.fountain:
        return Icon(
          CupertinoIcons.drop_fill,
          size: size,
        );
      case AvailableService.postOffice:
        return Icon(
          Icons.local_post_office,
          size: size,
        );
      case AvailableService.busStation:
        return Icon(
          CommunityMaterialIcons.bus,
          size: size,
        );
      case AvailableService.trainStation:
        return Icon(
          FontAwesomeIcons.train,
          size: size,
        );
      case AvailableService.airport:
        return Icon(
          Icons.local_airport,
          size: size,
        );
    }
  }
}
