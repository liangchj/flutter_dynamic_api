import 'api_key_desc_model.dart';
import 'validate_result_model.dart';

class ValidateFieldModel<T> {
  final ApiKeyDescModel fieldDesc;
  final String fieldType;
  final T Function(Map<String, dynamic>)? fromJson;
  final ValidateResultModel Function(Map<String, dynamic>)? validateField;

  ValidateFieldModel({
    required this.fieldDesc,
    required this.fieldType,
    this.fromJson,
    this.validateField,
  });
}
