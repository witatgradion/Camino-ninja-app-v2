import 'dart:convert';
import 'dart:typed_data';

import 'package:remote_data/src/proto/proto.dart' as proto;

int? _b(bool? v) => v == null ? null : (v ? 1 : 0);

/// Parses AlbergueListResponse proto bytes to table-keyed lists of DB-shaped maps. Top-level for isolate/compute.
Map<String, List<Map<String, dynamic>>> parseAlberguesProtoToMaps(
    Uint8List bytes,) {
  final resp = proto.AlbergueListResponse.fromBuffer(bytes);
  final albergues = <Map<String, dynamic>>[];
  final albergueFacilities = <Map<String, dynamic>>[];
  final albergueImages = <Map<String, dynamic>>[];
  final alberguePhones = <Map<String, dynamic>>[];
  final albergueEmails = <Map<String, dynamic>>[];
  final albergueSocialMedias = <Map<String, dynamic>>[];
  final albergueOperatingHours = <Map<String, dynamic>>[];
  final alberguePrices = <Map<String, dynamic>>[];
  final albergueWifis = <Map<String, dynamic>>[];
  final albergueReviews = <Map<String, dynamic>>[];

  for (final a in resp.items) {
    final gp = a.hasGeoPoint() ? a.geoPoint : null;
    albergues.add(<String, dynamic>{
      'id': a.id,
      'order_key': a.hasOrderKey() ? a.orderKey : null,
      'name': a.name,
      'slug': a.hasSlug() ? a.slug : null,
      'city_slug': a.hasCityName() ? a.cityName : null,
      'status': a.hasStatus() ? a.status : null,
      'is_municipal': _b(a.hasIsMunicipal() ? a.isMunicipal : null),
      'is_albergue': _b(a.hasIsAlbergue() ? a.isAlbergue : null),
      'address': a.hasAddress() ? a.address : null,
      'postal_code': a.hasPostalCode() ? a.postalCode : null,
      'province': a.hasProvince() ? a.province : null,
      'region': a.hasRegion() ? a.region : null,
      'country': a.hasCountry() ? a.country : null,
      'share_url': a.hasShareUrl() ? a.shareUrl : null,
      'reservation_translation_id':
          a.hasReservationTranslationId() ? a.reservationTranslationId : null,
      'open_season_translation_id':
          a.hasOpenSeasonTranslationId() ? a.openSeasonTranslationId : null,
      'city_id': a.cityId,
      'city_name': a.hasCityName() ? a.cityName : null,
      'web': a.hasWeb() ? a.web : null,
      'booking_com_url':
          a.hasBookingComUrl() ? a.bookingComUrl : null,
      'dist_costa': a.hasDistCosta() ? a.distCosta.toDouble() : null,
      'dist_litoral': a.hasDistLitoral() ? a.distLitoral.toDouble() : null,
      'reserve_url': a.hasReserverUrl() ? a.reserverUrl : null,
      'places_in_dormitory':
          a.hasPlacesInDormitory() ? a.placesInDormitory : null,
      'number_of_dormitories':
          a.hasNumberOfDormitories() ? a.numberOfDormitories : null,
      'latitude': gp?.lat ?? 0.0,
      'longitude': gp?.lon ?? 0.0,
      'booking_price': a.hasBookingPrice() ? a.bookingPrice : null,
      'booking_price_updated_at':
          a.hasBookingPriceUpdatedAt() ? a.bookingPriceUpdatedAt : null,
    });

    final f = a.hasFacilities() ? a.facilities : null;
    if (f != null) {
      albergueFacilities.add(<String, dynamic>{
        'id': f.id,
        'albergue_id': f.hasAlbergueId() ? f.albergueId : a.id,
        'has_kitchen': _b(f.hasHasKitchen() ? f.hasKitchen : null),
        'has_cooktops': _b(f.hasHasCooktops() ? f.hasCooktops : null),
        'has_microwave': _b(f.hasHasMicrowave() ? f.hasMicrowave : null),
        'has_water_boiler': _b(f.hasHasWaterBoiler() ? f.hasWaterBoiler : null),
        'has_plates_utensils':
            _b(f.hasHasPlatesUtensils() ? f.hasPlatesUtensils : null),
        'has_cooking_pots': _b(f.hasHasCookingPots() ? f.hasCookingPots : null),
        'has_breakfast': _b(f.hasHasBreakfast() ? f.hasBreakfast : null),
        'is_breakfast_included':
            _b(f.hasIsBreakfastIncluded() ? f.isBreakfastIncluded : null),
        'has_clothes_line':
            _b(f.hasHasClothesLine() ? f.hasClothesLine : null),
        'has_wifi': _b(f.hasHasWifi() ? f.hasWifi : null),
        'has_tv': _b(f.hasHasTv() ? f.hasTv : null),
        'has_restaurant':
            _b(f.hasHasRestaurant() ? f.hasRestaurant : null),
        'has_community_dinner':
            _b(f.hasHasCommunityDinner() ? f.hasCommunityDinner : null),
        'has_dinner': _b(f.hasHasDinner() ? f.hasDinner : null),
        'has_washing_machine':
            _b(f.hasHasWashingMachine() ? f.hasWashingMachine : null),
        'has_spin_dryer': _b(f.hasHasSpinDryer() ? f.hasSpinDryer : null),
        'has_hand_washing_sink':
            _b(f.hasHasHandWashingSink() ? f.hasHandWashingSink : null),
        'has_tumble_dryer':
            _b(f.hasHasTumbleDryer() ? f.hasTumbleDryer : null),
        'has_individual_powerplug':
            _b(f.hasHasIndividualPowerplug()
                ? f.hasIndividualPowerplug
                : null,),
        'has_private_lockers':
            _b(f.hasHasPrivateLockers() ? f.hasPrivateLockers : null),
        'has_curtains': _b(f.hasHasCurtains() ? f.hasCurtains : null),
        'has_oven': _b(f.hasHasOven() ? f.hasOven : null),
        'has_vending_machine':
            _b(f.hasHasVendingMachine() ? f.hasVendingMachine : null),
        'has_full_laundry_service':
            _b(f.hasHasFullLaundryService() ? f.hasFullLaundryService : null),
        'has_fridge': _b(f.hasHasFridge() ? f.hasFridge : null),
        'has_lunch': _b(f.hasHasLunch() ? f.hasLunch : null),
        'has_vegetarian_option':
            _b(f.hasHasVegetarianOption() ? f.hasVegetarianOption : null),
        'has_swimming_pool':
            _b(f.hasHasSwimmingPool() ? f.hasSwimmingPool : null),
        'has_donativo_breakfast':
            _b(f.hasHasDonativoBreakfast() ? f.hasDonativoBreakfast : null),
        'has_cube_beds': _b(f.hasHasCubeBeds() ? f.hasCubeBeds : null),
        'has_community_lunch':
            _b(f.hasHasCommunityLunch() ? f.hasCommunityLunch : null),
        'is_vegetarian': _b(f.hasIsVegetarian() ? f.isVegetarian : null),
        'is_vegan': _b(f.hasIsVegan() ? f.isVegan : null),
        'is_organic': _b(f.hasIsOrganic() ? f.isOrganic : null),
        'pets_allowed': _b(f.hasPetsAllowed() ? f.petsAllowed : null),
        'has_vegan_option':
            _b(f.hasHasVeganOption() ? f.hasVeganOption : null),
        'has_cotton_sheets':
            _b(f.hasHasCottonSheets() ? f.hasCottonSheets : null),
        'is_dinner_included':
            _b(f.hasIsDinnerIncluded() ? f.isDinnerIncluded : null),
      });
    }

    for (final img in a.albergueImages) {
      albergueImages.add(<String, dynamic>{
        'id': img.id,
        'albergue_id': img.hasAlbergueId() ? img.albergueId : a.id,
        'file_name': img.hasFileKey() ? img.fileKey : null,
        'title': null,
        'type': null,
        'width': null,
        'height': null,
      });
    }
    for (final p in a.phones) {
      alberguePhones.add(<String, dynamic>{
        'id': p.id,
        'albergue_id': p.hasAlbergueId() ? p.albergueId : a.id,
        'phone_number': p.hasPhoneNumber() ? p.phoneNumber : null,
        'whatsapp': _b(p.whatsapp),
        'private': _b(p.private),
        'signal': _b(p.signal),
      });
    }
    for (final e in a.emails) {
      albergueEmails.add(<String, dynamic>{
        'id': e.id,
        'albergue_id': e.hasAlbergueId() ? e.albergueId : a.id,
        'email_address': e.hasEmailAddress() ? e.emailAddress : null,
      });
    }
    if (a.hasSocialMedia()) {
      final s = a.socialMedia;
      albergueSocialMedias.add(<String, dynamic>{
        'id': s.id,
        'albergue_id': s.hasAlbergueId() ? s.albergueId : a.id,
        'facebook_url': s.hasFacebookUrl() ? s.facebookUrl : null,
        'facebook_id': s.hasFacebookId() ? s.facebookId : null,
        'instagram_handle':
            s.hasInstagramHandle() ? s.instagramHandle : null,
        'messenger': s.hasMessenger() ? s.messenger : null,
      });
    }
    if (a.hasOperatingHours()) {
      final o = a.operatingHours;
      albergueOperatingHours.add(<String, dynamic>{
        'id': o.id,
        'albergue_id': o.hasAlbergueId() ? o.albergueId : a.id,
        'checkin_time': o.hasCheckinTime() ? o.checkinTime : null,
        'checkout_time': o.hasCheckoutTime() ? o.checkoutTime : null,
        'close_time': o.hasCloseTime() ? o.closeTime : null,
        'open_from': o.hasOpenFrom() ? o.openFrom : null,
        'open_to': o.hasOpenTo() ? o.openTo : null,
        'open_from_ex': o.hasOpenFromEx() ? o.openFromEx : null,
        'open_to_ex': o.hasOpenToEx() ? o.openToEx : null,
        'open_from_ex2': o.hasOpenFromEx2() ? o.openFromEx2 : null,
        'open_to_ex2': o.hasOpenToEx2() ? o.openToEx2 : null,
        'opens': o.hasOpens() ? o.opens : null,
        'open_additional_information': o.openAdditionalInformation.isEmpty
            ? null
            : jsonEncode(Map<String, String>.from(o.openAdditionalInformation)),
        'unknown_open_season':
            _b(o.hasUnknownOpenSeason() ? o.unknownOpenSeason : null),
        'opens_all_year': _b(o.opensAllYear),
      });
    }
    if (a.hasPrices()) {
      final pr = a.prices;
      alberguePrices.add(<String, dynamic>{
        'id': pr.id,
        'albergue_id': pr.hasAlbergueId() ? pr.albergueId : a.id,
        'price_from_dormitory':
            pr.hasPriceFromDormitory() ? pr.priceFromDormitory : null,
        'price_to_dormitory':
            pr.hasPriceToDormitory() ? pr.priceToDormitory : null,
        'price_from_double_room':
            pr.hasPriceFromDoubleRoom() ? pr.priceFromDoubleRoom : null,
        'price_to_double_room':
            pr.hasPriceToDoubleRoom() ? pr.priceToDoubleRoom : null,
        'price_from_single_room':
            pr.hasPriceFromSingleRoom() ? pr.priceFromSingleRoom : null,
        'price_to_single_room':
            pr.hasPriceToSingleRoom() ? pr.priceToSingleRoom : null,
        'price_from_bed_shared_room': pr.hasPriceFromBedSharedRoom()
            ? pr.priceFromBedSharedRoom
            : null,
        'price_to_bed_shared_room':
            pr.hasPriceToBedSharedRoom() ? pr.priceToBedSharedRoom : null,
        'price_from_apartment':
            pr.hasPriceFromApartament() ? pr.priceFromApartament : null,
        'price_to_apartment':
            pr.hasPriceToApartament() ? pr.priceToApartament : null,
        'price_from_triple_room':
            pr.hasPriceFromTripleRoom() ? pr.priceFromTripleRoom : null,
        'price_to_triple_room':
            pr.hasPriceToTripleRoom() ? pr.priceToTripleRoom : null,
        'price_from_quatro_room':
            pr.hasPriceFromQuatroRoom() ? pr.priceFromQuatroRoom : null,
        'price_to_quatro_room':
            pr.hasPriceToQuatroRoom() ? pr.priceToQuatroRoom : null,
      });
    }
    for (final w in a.wifis) {
      albergueWifis.add(<String, dynamic>{
        'id': w.id,
        'albergue_id': w.hasAlbergueId() ? w.albergueId : a.id,
        'url': w.hasUrl() ? w.url : null,
      });
    }
    if (a.hasReviews()) {
      final r = a.reviews;
      albergueReviews.add(<String, dynamic>{
        'id': r.id,
        'albergue_id': r.hasAlbergueId() ? r.albergueId : a.id,
        'g_rating': r.hasGRating() ? r.gRating : null,
        'b_review_score': r.hasBReviewScore() ? r.bReviewScore : null,
        'b_id': r.hasBId() ? r.bId : null,
      });
    }
  }

  return <String, List<Map<String, dynamic>>>{
    'albergues': albergues,
    'albergue_facilities': albergueFacilities,
    'albergue_images': albergueImages,
    'albergue_phones': alberguePhones,
    'albergue_emails': albergueEmails,
    'albergue_social_medias': albergueSocialMedias,
    'albergue_operating_hours': albergueOperatingHours,
    'albergue_prices': alberguePrices,
    'albergue_wifis': albergueWifis,
    'albergue_reviews': albergueReviews,
  };
}
