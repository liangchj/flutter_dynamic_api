import '../utils/json_to_model_utils.dart';
import 'api_key_desc_model.dart';
import 'validate_field_model.dart';
import 'validate_result_model.dart';

class ApiBaseModel {
  /// 资源基本链接
  final String baseUrl;

  /// 资源中文名称
  final String name;

  /// 资源英文名称
  final String enName;

  ApiBaseModel({
    required this.baseUrl,
    required this.name,
    required this.enName,
  });

  factory ApiBaseModel.fromJson(Map<String, dynamic> map) {
    ValidateResultModel validateResult = ApiBaseModel.validateField(map);
    if (validateResult.msgMap.isNotEmpty) {
      throw Exception(validateResult.msgMap);
    }
    return ApiBaseModel(
      baseUrl: map["baseUrl"],
      name: map["name"],
      enName: map["enName"],
    );
  }

  Map<String, dynamic> toJson() => {
    "baseUrl": baseUrl,
    "name": name,
    "enName": enName,
  };

  // 验证方法
  static ValidateResultModel validateField(Map<String, dynamic> map) {
    ValidateResultModel validateResult =
        JsonToModelUtils.baseValidate<ApiBaseModel>(
          map,
          key: "apiBaseInfo",
          fromJson: ApiBaseModel.fromJson,
          validateFieldFn: ApiBaseModel.validateField,
        );
    if (!validateResult.flag) {
      return validateResult;
    }

    JsonToModelUtils.validateModelJson(
      map,
      validateResult: validateResult,
      validateFieldList: [
        ValidateFieldModel<ApiBaseModel>(
          fieldDesc: ApiKeyDescModel(
            key: "baseUrl",
            desc: "资源基本链接",
            isRequired: true,
          ),
          fieldType: "string",
        ),
        ValidateFieldModel<String>(
          fieldDesc: ApiKeyDescModel(
            key: "name",
            desc: "资源中文名称",
            isRequired: true,
          ),
          fieldType: "string",
        ),
        ValidateFieldModel<String>(
          fieldDesc: ApiKeyDescModel(
            key: "enName",
            desc: "资源英文名称",
            isRequired: true,
          ),
          fieldType: "string",
        ),
      ],
    );

    return validateResult;
  }
}
