import 'package:remote_data/remote_data.dart';
import 'package:remote_data/src/proto/proto.dart' as proto;

/// Utility class to convert between protobuf models and JSON models
class ProtoConverter {
  /// Convert a protobuf Albergue to AlbergueResponse
  static AlbergueResponse albergueFromProto(proto.Albergue proto) {
    return AlbergueResponse(
      id: proto.id,
      orderKey: proto.hasOrderKey() ? proto.orderKey : null,
      name: proto.name,
      slug: proto.hasSlug() ? proto.slug : null,
      citySlug: proto.hasCityName() ? proto.cityName : null,
      status: proto.hasStatus() ? proto.status : null,
      isMunicipal: proto.hasIsMunicipal() ? proto.isMunicipal : null,
      isAlbergue: proto.hasIsAlbergue() ? proto.isAlbergue : null,
      geom: proto.hasGeoPoint()
          ? GeometryResponse(lat: proto.geoPoint.lat, lon: proto.geoPoint.lon)
          : null,
      address: proto.hasAddress() ? proto.address : null,
      postalCode: proto.hasPostalCode() ? proto.postalCode : null,
      province: proto.hasProvince() ? proto.province : null,
      region: proto.hasRegion() ? proto.region : null,
      country: proto.hasCountry() ? proto.country : null,
      shareUrl: proto.hasShareUrl() ? proto.shareUrl : null,
      reservationTranslationId: proto.hasReservationTranslationId()
          ? proto.reservationTranslationId
          : null,
      openSeasonTranslationId: proto.hasOpenSeasonTranslationId()
          ? proto.openSeasonTranslationId
          : null,
      cityId: proto.cityId,
      cityName: proto.hasCityName() ? proto.cityName : null,
      web: proto.hasWeb() ? proto.web : null,
      bookingComUrl: proto.hasBookingComUrl() ? proto.bookingComUrl : null,
      distCosta: proto.hasDistCosta() ? proto.distCosta.toDouble() : null,
      distLitoral: proto.hasDistLitoral() ? proto.distLitoral.toDouble() : null,
      reserveUrl: proto.hasReserverUrl() ? proto.reserverUrl : null,
      placesInDormitory:
          proto.hasPlacesInDormitory() ? proto.placesInDormitory : null,
      numberOfDormitories:
          proto.hasNumberOfDormitories() ? proto.numberOfDormitories : null,
      facilities: _facilitiesFromProto(proto.facilities),
      images: proto.albergueImages.map(albergueImageFromProto).toList(),
      operatingHours: proto.hasOperatingHours()
          ? _operatingHoursFromProto(proto.operatingHours)
          : null,
      prices: _pricesFromProto(proto.prices),
      wifis: proto.wifis.map(_wifiFromProto).toList(),
      reviews: proto.hasReviews() ? _reviewsFromProto(proto.reviews) : null,
      phones: proto.phones.map(_phoneFromProto).toList(),
      emails: proto.emails.map(_emailFromProto).toList(),
      socialMedias: proto.hasSocialMedia()
          ? _socialMediaFromProto(proto.socialMedia)
          : null,
      bookingPrice: proto.hasBookingPrice() ? proto.bookingPrice : null,
      bookingPriceUpdatedAt:
          proto.hasBookingPriceUpdatedAt() ? proto.bookingPriceUpdatedAt : null,
    );
  }

  // Convert AlbergueListResponse to a List of AlbergueResponse
  static List<AlbergueResponse> albergueListFromProto(
    proto.AlbergueListResponse protoList,
  ) {
    return protoList.items.map(albergueFromProto).toList();
  }

  // Helper methods for nested objects
  static FacilityResponse _facilitiesFromProto(proto.AlbergueFacilities proto) {
    return FacilityResponse(
      id: proto.id,
      albergueId: proto.albergueId,
      hasKitchen: proto.hasHasKitchen() ? proto.hasKitchen : null,
      hasCooktops: proto.hasHasCooktops() ? proto.hasCooktops : null,
      hasMicrowave: proto.hasHasMicrowave() ? proto.hasMicrowave : null,
      hasWaterBoiler: proto.hasHasWaterBoiler() ? proto.hasWaterBoiler : null,
      hasPlatesUtensils:
          proto.hasHasPlatesUtensils() ? proto.hasPlatesUtensils : null,
      hasCookingPots: proto.hasHasCookingPots() ? proto.hasCookingPots : null,
      hasBreakfast: proto.hasHasBreakfast() ? proto.hasBreakfast : null,
      isBreakfastIncluded:
          proto.hasIsBreakfastIncluded() ? proto.isBreakfastIncluded : null,
      hasClothesLine: proto.hasHasClothesLine() ? proto.hasClothesLine : null,
      hasWifi: proto.hasHasWifi() ? proto.hasWifi : null,
      hasTv: proto.hasHasTv() ? proto.hasTv : null,
      hasRestaurant: proto.hasHasRestaurant() ? proto.hasRestaurant : null,
      hasCommunityDinner:
          proto.hasHasCommunityDinner() ? proto.hasCommunityDinner : null,
      hasDinner: proto.hasHasDinner() ? proto.hasDinner : null,
      hasWashingMachine:
          proto.hasHasWashingMachine() ? proto.hasWashingMachine : null,
      hasSpinDryer: proto.hasHasSpinDryer() ? proto.hasSpinDryer : null,
      hasHandWashingSink:
          proto.hasHasHandWashingSink() ? proto.hasHandWashingSink : null,
      hasTumbleDryer: proto.hasHasTumbleDryer() ? proto.hasTumbleDryer : null,
      hasIndividualPowerplug: proto.hasHasIndividualPowerplug()
          ? proto.hasIndividualPowerplug
          : null,
      hasPrivateLockers:
          proto.hasHasPrivateLockers() ? proto.hasPrivateLockers : null,
      hasCurtains: proto.hasHasCurtains() ? proto.hasCurtains : null,
      hasOven: proto.hasHasOven() ? proto.hasOven : null,
      hasVendingMachine:
          proto.hasHasVendingMachine() ? proto.hasVendingMachine : null,
      hasFullLaundryService:
          proto.hasHasFullLaundryService() ? proto.hasFullLaundryService : null,
      hasFridge: proto.hasHasFridge() ? proto.hasFridge : null,
      hasLunch: proto.hasHasLunch() ? proto.hasLunch : null,
      hasVegetarianOption:
          proto.hasHasVegetarianOption() ? proto.hasVegetarianOption : null,
      hasSwimmingPool:
          proto.hasHasSwimmingPool() ? proto.hasSwimmingPool : null,
      hasDonativoBreakfast:
          proto.hasHasDonativoBreakfast() ? proto.hasDonativoBreakfast : null,
      hasCubeBeds: proto.hasHasCubeBeds() ? proto.hasCubeBeds : null,
      hasCommunityLunch:
          proto.hasHasCommunityLunch() ? proto.hasCommunityLunch : null,
      isVegetarian: proto.hasIsVegetarian() ? proto.isVegetarian : null,
      isVegan: proto.hasIsVegan() ? proto.isVegan : null,
      isOrganic: proto.hasIsOrganic() ? proto.isOrganic : null,
      petsAllowed: proto.hasPetsAllowed() ? proto.petsAllowed : null,
      hasVeganOption: proto.hasHasVeganOption() ? proto.hasVeganOption : null,
      hasCottonSheets:
          proto.hasHasCottonSheets() ? proto.hasCottonSheets : null,
      isDinnerIncluded:
          proto.hasIsDinnerIncluded() ? proto.isDinnerIncluded : null,
    );
  }

  static OperatingHoursResponse _operatingHoursFromProto(
    proto.AlbergueOperatingHours proto,
  ) {
    return OperatingHoursResponse(
      id: proto.id,
      albergueId: proto.albergueId,
      checkinTime: proto.hasCheckinTime() ? proto.checkinTime : null,
      checkoutTime: proto.hasCheckoutTime() ? proto.checkoutTime : null,
      closeTime: proto.hasCloseTime() ? proto.closeTime : null,
      openFrom: proto.hasOpenFrom() ? proto.openFrom : null,
      openTo: proto.hasOpenTo() ? proto.openTo : null,
      openFromEx: proto.hasOpenFromEx() ? proto.openFromEx : null,
      openToEx: proto.hasOpenToEx() ? proto.openToEx : null,
      openFromEx2: proto.hasOpenFromEx2() ? proto.openFromEx2 : null,
      openToEx2: proto.hasOpenToEx2() ? proto.openToEx2 : null,
      opens: proto.hasOpens() ? proto.opens : null,
      openAdditionalInformation: proto.openAdditionalInformation,
      unknownOpenSeason:
          proto.hasUnknownOpenSeason() ? proto.unknownOpenSeason : null,
      opensAllYear: proto.hasOpensAllYear() ? proto.opensAllYear : null,
    );
  }

  static PriceResponse _pricesFromProto(proto.AlberguePrices proto) {
    return PriceResponse(
      id: proto.id,
      albergueId: proto.albergueId,
      // Only use price values if they were actually set by backend, otherwise use null
      priceFromDormitory:
          proto.hasPriceFromDormitory() ? proto.priceFromDormitory : null,
      priceToDormitory:
          proto.hasPriceToDormitory() ? proto.priceToDormitory : null,
      priceFromDoubleroom:
          proto.hasPriceFromDoubleRoom() ? proto.priceFromDoubleRoom : null,
      priceToDoubleroom:
          proto.hasPriceToDoubleRoom() ? proto.priceToDoubleRoom : null,
      priceFromSingleroom:
          proto.hasPriceFromSingleRoom() ? proto.priceFromSingleRoom : null,
      priceToSingleroom:
          proto.hasPriceToSingleRoom() ? proto.priceToSingleRoom : null,
      priceFromBedSharedRoom: proto.hasPriceFromBedSharedRoom()
          ? proto.priceFromBedSharedRoom
          : null,
      priceToBedSharedRoom:
          proto.hasPriceToBedSharedRoom() ? proto.priceToBedSharedRoom : null,
      priceFromQuatroroom:
          proto.hasPriceFromQuatroRoom() ? proto.priceFromQuatroRoom : null,
      priceToQuatroroom:
          proto.hasPriceToQuatroRoom() ? proto.priceToQuatroRoom : null,
      priceFromApartment:
          proto.hasPriceFromApartament() ? proto.priceFromApartament : null,
      priceToApartment:
          proto.hasPriceToApartament() ? proto.priceToApartament : null,
      priceFromTripleroom:
          proto.hasPriceFromTripleRoom() ? proto.priceFromTripleRoom : null,
      priceToTripleroom:
          proto.hasPriceToTripleRoom() ? proto.priceToTripleRoom : null,
    );
  }

  static ReviewResponse _reviewsFromProto(proto.AlbergueReviews proto) {
    return ReviewResponse(
      id: proto.id,
      albergueId: proto.albergueId,
      gRating: proto.hasGRating() ? proto.gRating : null,
      bReviewScore: proto.hasBReviewScore() ? proto.bReviewScore : null,
      bId: proto.hasBId() ? proto.bId : null,
    );
  }

  static AlbergueImageResponse albergueImageFromProto(
    proto.AlbergueImage proto,
  ) {
    return AlbergueImageResponse(
      id: proto.id,
      albergueId: proto.albergueId,
      fileKey: proto.fileKey,
    );
  }

  // Convert AlbergueUserImagesListResponse to a List of AlbergueImageResponse
  static List<AlbergueImageResponse> albergueUserImageListFromProto(
    proto.AlbergueUserImagesListResponse protoList,
  ) {
    return protoList.items
        .map(
          (e) => AlbergueImageResponse(
            id: e.id,
            albergueId: e.albergueId,
            fileKey: e.fileKey,
          ),
        )
        .toList();
  }

  static WifiResponse _wifiFromProto(proto.AlbergueWifi proto) {
    return WifiResponse(
      id: proto.id,
      albergueId: proto.albergueId,
      name: '',
      url: proto.url,
    );
  }

  static AlberguePhoneResponse _phoneFromProto(proto.AlberguePhone proto) {
    return AlberguePhoneResponse(
      id: proto.id,
      albergueId: proto.albergueId,
      phoneNumber: proto.phoneNumber,
      whatsapp: proto.whatsapp,
      private: proto.private,
      signal: proto.signal,
    );
  }

  static AlbergueEmailResponse _emailFromProto(proto.AlbergueEmail proto) {
    return AlbergueEmailResponse(
      id: proto.id,
      albergueId: proto.albergueId,
      emailAddress: proto.emailAddress,
    );
  }

  static AlbergueSocialMediaResponse _socialMediaFromProto(
    proto.AlbergueSocialMedia proto,
  ) {
    return AlbergueSocialMediaResponse(
      id: proto.id,
      albergueId: proto.albergueId,
      facebookUrl: proto.hasFacebookUrl() ? proto.facebookUrl : null,
      facebookId: proto.hasFacebookId() ? proto.facebookId : null,
      instagramHandle:
          proto.hasInstagramHandle() ? proto.instagramHandle : null,
      messenger: proto.hasMessenger() ? proto.messenger : null,
    );
  }

  static RouteResponse routeFromProto(proto.Route proto) {
    // backend may send '' for unset short_name; treat as null.
    final shortName = proto.hasShortName() && proto.shortName.isNotEmpty
        ? proto.shortName
        : null;
    return RouteResponse(
      id: proto.id,
      orderKey: proto.orderKey,
      routeName: proto.routeName,
      routeSubName: proto.hasRouteSubName() ? proto.routeSubName : null,
      legendColor: proto.hasLegendColor() ? proto.legendColor : null,
      lightLegendColor:
          proto.hasLightLegendColor() ? proto.lightLegendColor : null,
      darkLegendColor:
          proto.hasDarkLegendColor() ? proto.darkLegendColor : null,
      shortName: shortName,
    );
  }

  // Convert AlbergueListResponse to a List of AlbergueResponse
  static List<RouteResponse> routeListFromProto(
    proto.RouteListResponse protoList,
  ) {
    return protoList.items.map(routeFromProto).toList();
  }

  static RoutePointResponse routePointFromProto(proto.RoutePoints proto) {
    return RoutePointResponse(
      id: proto.id,
      routeId: proto.hasRouteId() ? proto.routeId : null,
      orderKey: proto.orderKey,
      geom: GeometryResponse(lat: proto.geoPoint.lat, lon: proto.geoPoint.lon),
      elevation: proto.elevation,
    );
  }

  // Convert RoutePointsListResponse to a List of RoutePointResponse
  static List<RoutePointResponse> routePointListFromProto(
    proto.RoutePointsListResponse protoList,
  ) {
    return protoList.items.map(routePointFromProto).toList();
  }

  static AltRoutePointResponse altRoutePointFromProto(
    proto.AltRoutePoints proto,
  ) {
    return AltRoutePointResponse(
      id: proto.id,
      routeId: proto.routeId,
      orderKey: proto.orderKey,
      color: proto.color,
      dotted: proto.dotted,
      altRoutePointValues: proto.altRoutePointsValues
          .map(
            (e) => AltRoutePointValueResponse(
              id: e.id,
              orderKey: e.orderKey,
              geom: GeometryResponse(lat: e.geoPoint.lat, lon: e.geoPoint.lon),
              altRoutePointId: e.altRoutePointsId,
            ),
          )
          .toList(),
    );
  }

  // Convert AltRoutePointsListResponse to a List of AltRoutePointResponse
  static List<AltRoutePointResponse> altRoutePointListFromProto(
    proto.AltRoutePointsListResponse protoList,
  ) {
    return protoList.items.map(altRoutePointFromProto).toList();
  }

  static LatestDataUpdateResponse latestDataUpdateFromProto(
    proto.LatestUpdated proto,
  ) {
    return LatestDataUpdateResponse(
      albergues: DateTime.tryParse(proto.alberguesUpdatedAt),
      albergueUserImages: DateTime.tryParse(proto.albergueUserImagesUpdatedAt),
      cities: DateTime.tryParse(proto.citiesUpdatedAt),
      routes: DateTime.tryParse(proto.routesUpdatedAt),
      routePoints: DateTime.tryParse(proto.routePointsUpdatedAt),
      altRoutePoints: DateTime.tryParse(proto.altRoutePointsUpdatedAt),
    );
  }

  static AlbergueRatingResponse albergueUserRatingFromProto(
    proto.AlbergueUserRatings proto,
  ) {
    return AlbergueRatingResponse(
      albergueId: proto.albergueId,
      rating: proto.hasRating() ? proto.rating : null,
      totalApprovedReviews:
          proto.hasTotalApprovedReviews() ? proto.totalApprovedReviews : null,
    );
  }

  // Convert AlbergueUserRatingsListResponse to a List of AlbergueRatingResponse
  static List<AlbergueRatingResponse> albergueUserRatingListFromProto(
    proto.AlbergueUserRatingsListResponse protoList,
  ) {
    return protoList.items.map(albergueUserRatingFromProto).toList();
  }

  static CityResponse cityFromProto(proto.City proto) {
    return CityResponse(
      id: proto.id,
      orderKey: 1,
      name: proto.name,
      country: proto.hasCountry() ? proto.country : null,
      region: proto.hasRegion() ? proto.region : null,
      province: proto.hasProvince() ? proto.province : null,
      slug: proto.slug,
      km: proto.hasKm() ? proto.km : null,
      hasAtm: proto.hasHasAtm() ? proto.hasAtm : null,
      hasBarCafe: proto.hasHasBarCafe() ? proto.hasBarCafe : null,
      hasShop: proto.hasHasShop() ? proto.hasShop : null,
      hasMedClinic: proto.hasHasMedClinic() ? proto.hasMedClinic : null,
      hasPharmacy: proto.hasHasPharmacy() ? proto.hasPharmacy : null,
      hasFountain: proto.hasHasFountain() ? proto.hasFountain : null,
      hasPostOffice: proto.hasHasPostOffice() ? proto.hasPostOffice : null,
      hasTrainStation:
          proto.hasHasTrainStation() ? proto.hasTrainStation : null,
      etapeCity: proto.hasEtapeCity() ? proto.etapeCity : null,
      geom: GeometryResponse(lat: proto.geoPoint.lat, lon: proto.geoPoint.lon),
      shareUrl: proto.hasShareUrl() ? proto.shareUrl : null,
      search: proto.hasSearch() ? proto.search : null,
      hasTobaccoStore:
          proto.hasHasTobaccoStore() ? proto.hasTobaccoStore : null,
      hasAirport: proto.hasHasAirport() ? proto.hasAirport : null,
      hasBusStation: proto.hasHasBusStation() ? proto.hasBusStation : null,
      hasRestaurant: proto.hasHasRestaurant() ? proto.hasRestaurant : null,
      route: proto.routes
          .map(
            (e) => CityNestedObject(
              id: e.id,
            ),
          )
          .toList(),
      routePoint: proto.routePoints
          .map(
            (e) => CityNestedObject(
              id: e.id,
            ),
          )
          .toList(),
    );
  }

  // Convert CityListResponse to a List of CityResponse
  static List<CityResponse> cityListFromProto(
    proto.CityListResponse protoList,
  ) {
    return protoList.items.map(cityFromProto).toList();
  }

  static AlbergueUserReviewResponse albergueUserReviewFromProto(
    proto.AlbergueUserReviews proto,
  ) {
    return AlbergueUserReviewResponse(
      id: proto.hasId() ? proto.id : null,
      status: proto.hasStatus() ? proto.status : null,
      albergueId: proto.hasAlbergueId() ? proto.albergueId : null,
      name: proto.hasName() ? proto.name : null,
      email: proto.hasEmail() ? proto.email : null,
      userComment: proto.hasUserComment() ? proto.userComment : null,
      userRating: proto.hasUserRating() ? proto.userRating.toInt() : null,
      createdAt:
          proto.hasCreatedAt() ? DateTime.tryParse(proto.createdAt) : null,
      updatedAt:
          proto.hasUpdatedAt() ? DateTime.tryParse(proto.updatedAt) : null,
      translatedComment:
          proto.hasTranslatedComment() ? proto.translatedComment : null,
      displayLang: proto.hasDisplayLang() ? proto.displayLang : null,
      sourceLang: proto.hasSourceLang() ? proto.sourceLang : null,
      isTranslated: proto.hasIsTranslated() ? proto.isTranslated : null,
      images: proto.images.isNotEmpty
          ? proto.images
              .map(
                (e) => AlbergueImageReviewResponse(
                  id: e.hasId() ? e.id : null,
                  albergueUserReviewsId: e.hasAlbergueUserReviewsId()
                      ? e.albergueUserReviewsId
                      : null,
                  fileKey: e.hasFileKey() ? e.fileKey : null,
                  createdAt:
                      e.hasCreatedAt() ? DateTime.tryParse(e.createdAt) : null,
                  updatedAt:
                      e.hasUpdatedAt() ? DateTime.tryParse(e.updatedAt) : null,
                ),
              )
              .toList()
          : null,
    );
  }

  // Convert AlbergueUserReviewsListResponse to a List of AlbergueUserReviewResponse
  static AlbergueReviewResponse albergueUserReviewListFromProto(
    proto.AlbergueUserReviewsByAlbergueId proto,
  ) {
    return AlbergueReviewResponse(
      total: proto.total.toInt(),
      albergueUserReviews:
          proto.albergueUserReviews.map(albergueUserReviewFromProto).toList(),
    );
  }

  static List<AlbergueUserReviewResponse> albergueUserReviewListFromJson(
      proto.AlbergueUserReviewsListResponse protoResponse) {
    return protoResponse.albergueUserReviews
        .map(albergueUserReviewFromProto)
        .toList();
  }

  static CityPairsExportResponse cityPairsExportFromProto(
      proto.CityPairsExport protoResponse) {
    return CityPairsExportResponse(
      calculatedAt: protoResponse.hasCalculatedAt()
          ? protoResponse.calculatedAt.toInt()
          : null,
      totalPairs:
          protoResponse.hasTotalPairs() ? protoResponse.totalPairs : null,
      pairs: protoResponse.pairs.map(
          (key, value) => MapEntry(key, cityPairsForStartCityFromProto(value))),
    );
  }

  static CityPairsForStartCityResponse cityPairsForStartCityFromProto(
      proto.CityPairsForStartCity value) {
    return CityPairsForStartCityResponse(
      startCityId: value.hasStartCityId() ? value.startCityId : null,
      startCityName: value.hasStartCityName() ? value.startCityName : null,
      totalPlans: value.hasTotalPlans() ? value.totalPlans : null,
      pairs: value.pairs.map((e) {
        return CityPairDetailResponse(
          endCityId: e.hasEndCityId() ? e.endCityId : null,
          endCityName: e.hasEndCityName() ? e.endCityName : null,
          percentage: e.hasPercentage() ? e.percentage : null,
          pairCount: e.hasPairCount() ? e.pairCount : null,
          distanceKm: e.hasDistanceKm() ? e.distanceKm : null,
        );
      }).toList(),
    );
  }
}
