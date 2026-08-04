import 'package:json_annotation/json_annotation.dart';

part 'gemini_models.g.dart';

@JsonSerializable()
class GeminiModelList {
  final List<GeminiModel> models;

  GeminiModelList({required this.models});

  factory GeminiModelList.fromJson(Map<String, dynamic> json) =>
      _$GeminiModelListFromJson(json);
  Map<String, dynamic> toJson() => _$GeminiModelListToJson(this);
}

@JsonSerializable()
class GeminiModel {
  final String name;
  final String? version;
  final String? displayName;
  final String? description;
  final int? inputTokenLimit;
  final int? outputTokenLimit;
  final List<String>? supportedGenerationMethods;

  GeminiModel({
    required this.name,
    this.version,
    this.displayName,
    this.description,
    this.inputTokenLimit,
    this.outputTokenLimit,
    this.supportedGenerationMethods,
  });

  factory GeminiModel.fromJson(Map<String, dynamic> json) =>
      _$GeminiModelFromJson(json);
  Map<String, dynamic> toJson() => _$GeminiModelToJson(this);
}
