import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';

import 'package:flutter/material.dart';
import 'package:storage/storage.dart';

extension ServiceExtension on AvailableService {
  String getServiceName(BuildContext context) {
    switch (this) {
      case AvailableService.hotel:
        return AppLocalizations.of(context).facility_hotel;
      case AvailableService.atm:
        return AppLocalizations.of(context).facility_atm;
      case AvailableService.cafe:
        return AppLocalizations.of(context).facility_cafe;
      case AvailableService.restaurant:
        return AppLocalizations.of(context).facility_restaurant;
      case AvailableService.shopping:
        return AppLocalizations.of(context).facility_shopping_stores;
      case AvailableService.tobacco:
        return AppLocalizations.of(context).facility_tobacco_shop;
      case AvailableService.pharmacy:
        return AppLocalizations.of(context).facility_pharmacy;
      case AvailableService.clinic:
        return AppLocalizations.of(context).facility_clinic;
      case AvailableService.fountain:
        return AppLocalizations.of(context).facility_fountain;
      case AvailableService.postOffice:
        return AppLocalizations.of(context).facility_post_office;
      case AvailableService.busStation:
        return AppLocalizations.of(context).facility_bus_station;
      case AvailableService.trainStation:
        return AppLocalizations.of(context).facility_train_station;
      case AvailableService.airport:
        return AppLocalizations.of(context).facility_airport;
    }
  }
}
