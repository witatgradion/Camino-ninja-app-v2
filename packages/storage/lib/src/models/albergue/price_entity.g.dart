// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'price_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PriceEntity _$PriceEntityFromJson(Map<String, dynamic> json) => PriceEntity(
      id: (json['price_id'] as num).toInt(),
      albergueId: (json['albergue_id'] as num?)?.toInt(),
      priceFromDormitory: (json['price_from_dormitory'] as num?)?.toDouble(),
      priceFromDoubleroom: (json['price_from_double_room'] as num?)?.toDouble(),
      priceFromSingleroom: (json['price_from_single_room'] as num?)?.toDouble(),
      priceFromBedSharedRoom:
          (json['price_from_bed_shared_room'] as num?)?.toDouble(),
      priceToDormitory: (json['price_to_dormitory'] as num?)?.toDouble(),
      priceToDoubleroom: (json['price_to_double_room'] as num?)?.toDouble(),
      priceToSingleroom: (json['price_to_single_room'] as num?)?.toDouble(),
      priceToQuatroroom: (json['price_to_quatro_room'] as num?)?.toDouble(),
      priceFromApartment: (json['price_from_apartment'] as num?)?.toDouble(),
      priceToApartment: (json['price_to_apartment'] as num?)?.toDouble(),
      priceFromTripleroom: (json['price_from_triple_room'] as num?)?.toDouble(),
      priceFromQuatroroom: (json['price_from_quatro_room'] as num?)?.toDouble(),
      priceToTripleroom: (json['price_to_triple_room'] as num?)?.toDouble(),
      priceToBedSharedRoom:
          (json['price_to_bed_shared_room'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$PriceEntityToJson(PriceEntity instance) =>
    <String, dynamic>{
      'price_from_dormitory': instance.priceFromDormitory,
      'price_from_double_room': instance.priceFromDoubleroom,
      'price_id': instance.id,
      'albergue_id': instance.albergueId,
      'price_from_single_room': instance.priceFromSingleroom,
      'price_from_bed_shared_room': instance.priceFromBedSharedRoom,
      'price_to_dormitory': instance.priceToDormitory,
      'price_to_double_room': instance.priceToDoubleroom,
      'price_to_single_room': instance.priceToSingleroom,
      'price_to_quatro_room': instance.priceToQuatroroom,
      'price_from_apartment': instance.priceFromApartment,
      'price_to_apartment': instance.priceToApartment,
      'price_from_triple_room': instance.priceFromTripleroom,
      'price_from_quatro_room': instance.priceFromQuatroroom,
      'price_to_triple_room': instance.priceToTripleroom,
      'price_to_bed_shared_room': instance.priceToBedSharedRoom,
    };
