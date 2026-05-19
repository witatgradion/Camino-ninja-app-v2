// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'facility_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FacilityEntity _$FacilityEntityFromJson(Map<String, dynamic> json) =>
    FacilityEntity(
      id: (json['facility_id'] as num).toInt(),
      hasKitchen: intToBool((json['has_kitchen'] as num?)?.toInt()),
      hasCooktops: intToBool((json['has_cooktops'] as num?)?.toInt()),
      hasMicrowave: intToBool((json['has_microwave'] as num?)?.toInt()),
      hasWaterBoiler: intToBool((json['has_water_boiler'] as num?)?.toInt()),
      hasPlatesUtensils:
          intToBool((json['has_plates_utensils'] as num?)?.toInt()),
      hasCookingPots: intToBool((json['has_cooking_pots'] as num?)?.toInt()),
      hasBreakfast: intToBool((json['has_breakfast'] as num?)?.toInt()),
      isBreakfastIncluded:
          intToBool((json['is_breakfast_included'] as num?)?.toInt()),
      hasClothesLine: intToBool((json['has_clothes_line'] as num?)?.toInt()),
      hasWifi: intToBool((json['has_wifi'] as num?)?.toInt()),
      hasTv: intToBool((json['has_tv'] as num?)?.toInt()),
      hasRestaurant: intToBool((json['has_restaurant'] as num?)?.toInt()),
      hasCommunityDinner:
          intToBool((json['has_community_dinner'] as num?)?.toInt()),
      hasDinner: intToBool((json['has_dinner'] as num?)?.toInt()),
      hasWashingMachine:
          intToBool((json['has_washing_machine'] as num?)?.toInt()),
      hasSpinDryer: intToBool((json['has_spin_dryer'] as num?)?.toInt()),
      hasHandWashingSink:
          intToBool((json['has_hand_washing_sink'] as num?)?.toInt()),
      hasTumbleDryer: intToBool((json['has_tumble_dryer'] as num?)?.toInt()),
      hasIndividualPowerplug:
          intToBool((json['has_individual_powerplug'] as num?)?.toInt()),
      hasPrivateLockers:
          intToBool((json['has_private_lockers'] as num?)?.toInt()),
      hasCurtains: intToBool((json['has_curtains'] as num?)?.toInt()),
      hasOven: intToBool((json['has_oven'] as num?)?.toInt()),
      hasVendingMachine:
          intToBool((json['has_vending_machine'] as num?)?.toInt()),
      hasFullLaundryService:
          intToBool((json['has_full_laundry_service'] as num?)?.toInt()),
      hasFridge: intToBool((json['has_fridge'] as num?)?.toInt()),
      hasLunch: intToBool((json['has_lunch'] as num?)?.toInt()),
      hasVegetarianOption:
          intToBool((json['has_vegetarian_option'] as num?)?.toInt()),
      hasSwimmingPool: intToBool((json['has_swimming_pool'] as num?)?.toInt()),
      hasDonativoBreakfast:
          intToBool((json['has_donativo_breakfast'] as num?)?.toInt()),
      hasCubeBeds: intToBool((json['has_cube_beds'] as num?)?.toInt()),
      hasCommunityLunch:
          intToBool((json['has_community_lunch'] as num?)?.toInt()),
      isVegetarian: intToBool((json['is_vegetarian'] as num?)?.toInt()),
      isVegan: intToBool((json['is_vegan'] as num?)?.toInt()),
      isOrganic: intToBool((json['is_organic'] as num?)?.toInt()),
      petsAllowed: intToBool((json['pets_allowed'] as num?)?.toInt()),
      albergueId: (json['albergue_id'] as num?)?.toInt(),
      hasVeganOption: intToBool((json['has_vegan_option'] as num?)?.toInt()),
      hasCottonSheets: intToBool((json['has_cotton_sheets'] as num?)?.toInt()),
      isDinnerIncluded:
          intToBool((json['is_dinner_included'] as num?)?.toInt()),
    );

Map<String, dynamic> _$FacilityEntityToJson(FacilityEntity instance) =>
    <String, dynamic>{
      'facility_id': instance.id,
      'has_kitchen': instance.hasKitchen,
      'has_cooktops': instance.hasCooktops,
      'has_microwave': instance.hasMicrowave,
      'has_water_boiler': instance.hasWaterBoiler,
      'has_plates_utensils': instance.hasPlatesUtensils,
      'has_cooking_pots': instance.hasCookingPots,
      'has_breakfast': instance.hasBreakfast,
      'is_breakfast_included': instance.isBreakfastIncluded,
      'has_clothes_line': instance.hasClothesLine,
      'has_wifi': instance.hasWifi,
      'has_tv': instance.hasTv,
      'has_restaurant': instance.hasRestaurant,
      'has_community_dinner': instance.hasCommunityDinner,
      'has_dinner': instance.hasDinner,
      'has_washing_machine': instance.hasWashingMachine,
      'has_spin_dryer': instance.hasSpinDryer,
      'has_hand_washing_sink': instance.hasHandWashingSink,
      'has_tumble_dryer': instance.hasTumbleDryer,
      'has_individual_powerplug': instance.hasIndividualPowerplug,
      'has_private_lockers': instance.hasPrivateLockers,
      'has_curtains': instance.hasCurtains,
      'has_oven': instance.hasOven,
      'has_vending_machine': instance.hasVendingMachine,
      'has_full_laundry_service': instance.hasFullLaundryService,
      'has_fridge': instance.hasFridge,
      'has_lunch': instance.hasLunch,
      'has_vegetarian_option': instance.hasVegetarianOption,
      'has_swimming_pool': instance.hasSwimmingPool,
      'has_donativo_breakfast': instance.hasDonativoBreakfast,
      'has_cube_beds': instance.hasCubeBeds,
      'has_community_lunch': instance.hasCommunityLunch,
      'is_vegetarian': instance.isVegetarian,
      'is_vegan': instance.isVegan,
      'is_organic': instance.isOrganic,
      'pets_allowed': instance.petsAllowed,
      'albergue_id': instance.albergueId,
      'has_vegan_option': instance.hasVeganOption,
      'has_cotton_sheets': instance.hasCottonSheets,
      'is_dinner_included': instance.isDinnerIncluded,
    };
