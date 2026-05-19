import 'package:json_annotation/json_annotation.dart';
import 'package:storage/src/models/bool_mapper.dart';

part 'facility_entity.g.dart';

@JsonSerializable()
class FacilityEntity {
  const FacilityEntity({
    required this.id,
    this.hasKitchen,
    this.hasCooktops,
    this.hasMicrowave,
    this.hasWaterBoiler,
    this.hasPlatesUtensils,
    this.hasCookingPots,
    this.hasBreakfast,
    this.isBreakfastIncluded,
    this.hasClothesLine,
    this.hasWifi,
    this.hasTv,
    this.hasRestaurant,
    this.hasCommunityDinner,
    this.hasDinner,
    this.hasWashingMachine,
    this.hasSpinDryer,
    this.hasHandWashingSink,
    this.hasTumbleDryer,
    this.hasIndividualPowerplug,
    this.hasPrivateLockers,
    this.hasCurtains,
    this.hasOven,
    this.hasVendingMachine,
    this.hasFullLaundryService,
    this.hasFridge,
    this.hasLunch,
    this.hasVegetarianOption,
    this.hasSwimmingPool,
    this.hasDonativoBreakfast,
    this.hasCubeBeds,
    this.hasCommunityLunch,
    this.isVegetarian,
    this.isVegan,
    this.isOrganic,
    this.petsAllowed,
    required this.albergueId,
    this.hasVeganOption,
    this.hasCottonSheets,
    this.isDinnerIncluded,
  });

  @JsonKey(name: 'facility_id')
  final int id;
  @JsonKey(name: 'has_kitchen', fromJson: intToBool)
  final bool? hasKitchen;
  @JsonKey(name: 'has_cooktops', fromJson: intToBool)
  final bool? hasCooktops;
  @JsonKey(name: 'has_microwave', fromJson: intToBool)
  final bool? hasMicrowave;
  @JsonKey(name: 'has_water_boiler', fromJson: intToBool)
  final bool? hasWaterBoiler;
  @JsonKey(name: 'has_plates_utensils', fromJson: intToBool)
  final bool? hasPlatesUtensils;
  @JsonKey(name: 'has_cooking_pots', fromJson: intToBool)
  final bool? hasCookingPots;
  @JsonKey(name: 'has_breakfast', fromJson: intToBool)
  final bool? hasBreakfast;
  @JsonKey(name: 'is_breakfast_included', fromJson: intToBool)
  final bool? isBreakfastIncluded;
  @JsonKey(name: 'has_clothes_line', fromJson: intToBool)
  final bool? hasClothesLine;
  @JsonKey(name: 'has_wifi', fromJson: intToBool)
  final bool? hasWifi;
  @JsonKey(name: 'has_tv', fromJson: intToBool)
  final bool? hasTv;
  @JsonKey(name: 'has_restaurant', fromJson: intToBool)
  final bool? hasRestaurant;
  @JsonKey(name: 'has_community_dinner', fromJson: intToBool)
  final bool? hasCommunityDinner;
  @JsonKey(name: 'has_dinner', fromJson: intToBool)
  final bool? hasDinner;
  @JsonKey(name: 'has_washing_machine', fromJson: intToBool)
  final bool? hasWashingMachine;
  @JsonKey(name: 'has_spin_dryer', fromJson: intToBool)
  final bool? hasSpinDryer;
  @JsonKey(name: 'has_hand_washing_sink', fromJson: intToBool)
  final bool? hasHandWashingSink;
  @JsonKey(name: 'has_tumble_dryer', fromJson: intToBool)
  final bool? hasTumbleDryer;
  @JsonKey(name: 'has_individual_powerplug', fromJson: intToBool)
  final bool? hasIndividualPowerplug;
  @JsonKey(name: 'has_private_lockers', fromJson: intToBool)
  final bool? hasPrivateLockers;
  @JsonKey(name: 'has_curtains', fromJson: intToBool)
  final bool? hasCurtains;
  @JsonKey(name: 'has_oven', fromJson: intToBool)
  final bool? hasOven;
  @JsonKey(name: 'has_vending_machine', fromJson: intToBool)
  final bool? hasVendingMachine;
  @JsonKey(name: 'has_full_laundry_service', fromJson: intToBool)
  final bool? hasFullLaundryService;
  @JsonKey(name: 'has_fridge', fromJson: intToBool)
  final bool? hasFridge;
  @JsonKey(name: 'has_lunch', fromJson: intToBool)
  final bool? hasLunch;
  @JsonKey(name: 'has_vegetarian_option', fromJson: intToBool)
  final bool? hasVegetarianOption;
  @JsonKey(name: 'has_swimming_pool', fromJson: intToBool)
  final bool? hasSwimmingPool;
  @JsonKey(name: 'has_donativo_breakfast', fromJson: intToBool)
  final bool? hasDonativoBreakfast;
  @JsonKey(name: 'has_cube_beds', fromJson: intToBool)
  final bool? hasCubeBeds;
  @JsonKey(name: 'has_community_lunch', fromJson: intToBool)
  final bool? hasCommunityLunch;
  @JsonKey(name: 'is_vegetarian', fromJson: intToBool)
  final bool? isVegetarian;
  @JsonKey(name: 'is_vegan', fromJson: intToBool)
  final bool? isVegan;
  @JsonKey(name: 'is_organic', fromJson: intToBool)
  final bool? isOrganic;
  @JsonKey(name: 'pets_allowed', fromJson: intToBool)
  final bool? petsAllowed;
  @JsonKey(name: 'albergue_id')
  final int? albergueId;
  @JsonKey(name: 'has_vegan_option', fromJson: intToBool)
  final bool? hasVeganOption;
  @JsonKey(name: 'has_cotton_sheets', fromJson: intToBool)
  final bool? hasCottonSheets;
  @JsonKey(name: 'is_dinner_included', fromJson: intToBool)
  final bool? isDinnerIncluded;

  factory FacilityEntity.fromJson(Map<String, dynamic> json) =>
      _$FacilityEntityFromJson(json);

  Map<String, dynamic> toJson() => _$FacilityEntityToJson(this);
}
