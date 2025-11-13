import 'package:json_annotation/json_annotation.dart';

/// Use this when a field can be either a string or int from the backend, but may be null.
class NullableIntConverter implements JsonConverter<int?, dynamic> {
  const NullableIntConverter();

  @override
  int? fromJson(dynamic json) {
    if (json == null) return null;
    if (json is int) return json;
    if (json is String) return int.tryParse(json);
    return null;
  }

  @override
  dynamic toJson(int? object) => object;
}

/// Use this when the field is required and must always return an int, even if the input is a string or null.
class StringToIntConverter implements JsonConverter<int, dynamic> {
  const StringToIntConverter();

  @override
  int fromJson(dynamic json) => int.tryParse(json.toString()) ?? 0;

  @override
  dynamic toJson(int value) => value;
}
