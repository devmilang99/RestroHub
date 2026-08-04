// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gemini_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeminiModelList _$GeminiModelListFromJson(Map<String, dynamic> json) =>
    GeminiModelList(
      models: (json['models'] as List<dynamic>)
          .map((e) => GeminiModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GeminiModelListToJson(GeminiModelList instance) =>
    <String, dynamic>{'models': instance.models};

GeminiModel _$GeminiModelFromJson(Map<String, dynamic> json) => GeminiModel(
  name: json['name'] as String,
  version: json['version'] as String?,
  displayName: json['displayName'] as String?,
  description: json['description'] as String?,
  inputTokenLimit: (json['inputTokenLimit'] as num?)?.toInt(),
  outputTokenLimit: (json['outputTokenLimit'] as num?)?.toInt(),
  supportedGenerationMethods:
      (json['supportedGenerationMethods'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
);

Map<String, dynamic> _$GeminiModelToJson(GeminiModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'version': instance.version,
      'displayName': instance.displayName,
      'description': instance.description,
      'inputTokenLimit': instance.inputTokenLimit,
      'outputTokenLimit': instance.outputTokenLimit,
      'supportedGenerationMethods': instance.supportedGenerationMethods,
    };
