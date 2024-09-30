// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'base_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BaseModel _$BaseModelFromJson(Map<String, dynamic> json) => BaseModel(
      id: (json['id'] as num?)?.toInt(),
      source: json['source'] as String,
      nameFile: json['nameFile'] as String,
      format: $enumDecode(_$ModelFormatEnumMap, json['format']),
      sourceType: $enumDecode(_$ModelSourceTypeEnumMap, json['sourceType']),
    );

Map<String, dynamic> _$BaseModelToJson(BaseModel instance) => <String, dynamic>{
      'id': instance.id,
      'source': instance.source,
      'nameFile': instance.nameFile,
      'format': _$ModelFormatEnumMap[instance.format]!,
      'sourceType': _$ModelSourceTypeEnumMap[instance.sourceType]!,
    };

const _$ModelFormatEnumMap = {
  ModelFormat.tflite: 'tflite',
  ModelFormat.onnx: 'onnx',
};

const _$ModelSourceTypeEnumMap = {
  ModelSourceType.local: 'local',
  ModelSourceType.network: 'network',
};
