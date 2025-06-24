import 'package:flutter_dynamic_api/models/validate_result_model.dart';

import '../utils/json_to_model_utils.dart';
import '../utils/model_validate_factory_utils.dart';
import 'api_key_desc_model.dart';

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
    if (ModelValidateFactoryUtils.isRegisterFactory<ApiBaseModel>()) {
      ModelValidateFactoryUtils.register<ApiBaseModel>(
        validator: ApiBaseModel.validateField,
        factory: ApiBaseModel.fromJson,
      );
    }
    if (ModelValidateFactoryUtils.isRegisterValidator<ApiBaseModel>()) {
      ModelValidateFactoryUtils.registerValidator<ApiBaseModel>(
        ApiBaseModel.validateField,
      );
    }
    ValidateResultModel validateResult = ValidateResultModel(
      key: "apiBase",
      msgMap: {},
      childValidateResultMap: {},
    );
    if (map.isEmpty) {
      validateResult.msgMap["json"] = "接收传入的json数据为空";
      validateResult.flag = false;
      return validateResult;
    }

    JsonToModelUtils.validateFieldStr(
      map,
      apiKeyDescModel: baseUrlField,
      validateResult: validateResult,
    );

    JsonToModelUtils.validateFieldStr(
      map,
      apiKeyDescModel: nameField,
      validateResult: validateResult,
    );

    JsonToModelUtils.validateFieldStr(
      map,
      apiKeyDescModel: enNameField,
      validateResult: validateResult,
    );
    if (validateResult.flag) {
      validateResult.flag = validateResult.msgMap.isEmpty;
    }
    return validateResult;
  }

  static final ApiKeyDescModel baseUrlField = ApiKeyDescModel(
    key: "baseUrl",
    desc: "资源基本链接",
    isRequired: true,
  );
  static final ApiKeyDescModel nameField = ApiKeyDescModel(
    key: "name",
    desc: "资源中文名称",
    isRequired: true,
  );
  static final ApiKeyDescModel enNameField = ApiKeyDescModel(
    key: "enName",
    desc: "资源英文名称",
    isRequired: true,
  );
}
