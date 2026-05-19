import 'package:json_annotation/json_annotation.dart';

part 'price_entity.g.dart';

@JsonSerializable()
class PriceEntity {
  const PriceEntity({
    required this.id,
    required this.albergueId,
    this.priceFromDormitory,
    this.priceFromDoubleroom,
    this.priceFromSingleroom,
    this.priceFromBedSharedRoom,
    this.priceToDormitory,
    this.priceToDoubleroom,
    this.priceToSingleroom,
    this.priceToQuatroroom,
    this.priceFromApartment,
    this.priceToApartment,
    this.priceFromTripleroom,
    this.priceFromQuatroroom,
    this.priceToTripleroom,
    this.priceToBedSharedRoom,
  });

  @JsonKey(name: 'price_from_dormitory')
  final double? priceFromDormitory;
  @JsonKey(name: 'price_from_double_room')
  final double? priceFromDoubleroom;
  @JsonKey(name: 'price_id')
  final int id;
  @JsonKey(name: 'albergue_id')
  final int? albergueId;
  @JsonKey(name: 'price_from_single_room')
  final double? priceFromSingleroom;
  @JsonKey(name: 'price_from_bed_shared_room')
  final double? priceFromBedSharedRoom;
  @JsonKey(name: 'price_to_dormitory')
  final double? priceToDormitory;
  @JsonKey(name: 'price_to_double_room')
  final double? priceToDoubleroom;
  @JsonKey(name: 'price_to_single_room')
  final double? priceToSingleroom;
  @JsonKey(name: 'price_to_quatro_room')
  final double? priceToQuatroroom;
  @JsonKey(name: 'price_from_apartment')
  final double? priceFromApartment;
  @JsonKey(name: 'price_to_apartment')
  final double? priceToApartment;
  @JsonKey(name: 'price_from_triple_room')
  final double? priceFromTripleroom;
  @JsonKey(name: 'price_from_quatro_room')
  final double? priceFromQuatroroom;
  @JsonKey(name: 'price_to_triple_room')
  final double? priceToTripleroom;
  @JsonKey(name: 'price_to_bed_shared_room')
  final double? priceToBedSharedRoom;

  factory PriceEntity.fromJson(Map<String, dynamic> json) =>
      _$PriceEntityFromJson(json);

  Map<String, dynamic> toJson() => _$PriceEntityToJson(this);
}

extension PriceEntityX on PriceEntity {
  bool get hasPrice {
    return priceFromDormitory != null ||
        priceToDormitory != null ||
        priceFromDoubleroom != null ||
        priceToDoubleroom != null ||
        priceFromSingleroom != null ||
        priceToSingleroom != null ||
        priceFromBedSharedRoom != null ||
        priceToBedSharedRoom != null ||
        priceFromApartment != null ||
        priceToApartment != null ||
        priceFromTripleroom != null ||
        priceToTripleroom != null ||
        priceFromQuatroroom != null ||
        priceToQuatroroom != null;
  }
}
