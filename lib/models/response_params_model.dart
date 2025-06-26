import 'dart:convert';

import 'package:flutter_dynamic_api/models/validate_result_model.dart';

import '../utils/data_type_convert_utils.dart';
import '../utils/json_to_model_utils.dart';
import '../utils/model_validate_factory_utils.dart';
import 'api_key_desc_model.dart';

/// 响应参数
class ResponseParamsModel {
  /// 响应状态码key
  final String statusCodeKey;

  /// 响应成功状态码
  final String successStatusCode;

  /// 响应读取值的key
  final String resDataKey;

  /// 响应说明信息
  final String? resMsgKey;

  /// 响应结果映射key
  final Map<String, String> resultKeyMap;

  /// 用于将结果转换为需要的数据结构
  /// 因flutter不支持动态，因此 使用js函数
  final String? resultConvertJsFn;

  ResponseParamsModel({
    required this.statusCodeKey,
    required this.successStatusCode,
    required this.resDataKey,
    required this.resMsgKey,
    required this.resultKeyMap,
    required this.resultConvertJsFn,
  });

  factory ResponseParamsModel.fromJson(Map<String, dynamic> map) {
    ValidateResultModel validateResult = ResponseParamsModel.validateField(map);
    if (validateResult.msgMap.isNotEmpty) {
      throw Exception(validateResult.msgMap);
    }
    return ResponseParamsModel(
      statusCodeKey: map["statusCodeKey"],
      successStatusCode: map["successStatusCode"],
      resDataKey: map["resDataKey"],
      resMsgKey: map["resMsgKey"],
      resultKeyMap:
          JsonToModelUtils.getMapStrToTFromJson<String>(map, "resultKeyMap") ??
          {},
      resultConvertJsFn: map["resultConvertJsFn"],
    );
  }

  Map<String, dynamic> toJson() => {
    "statusCodeKey": statusCodeKey,
    "successStatusCode": successStatusCode,
    "resDataKey": resDataKey,
    "resMsgKey": resMsgKeyField,
    "resultKeyMap": json.encode(resultKeyMap),
    "resultConvertJsFn": resultConvertJsFn,
  };

  // 验证方法
  static ValidateResultModel validateField(Map<String, dynamic> map) {
    if (ModelValidateFactoryUtils.isRegisterFactory<ResponseParamsModel>()) {
      ModelValidateFactoryUtils.register<ResponseParamsModel>(
        validator: ResponseParamsModel.validateField,
        factory: ResponseParamsModel.fromJson,
      );
    }
    if (ModelValidateFactoryUtils.isRegisterValidator<ResponseParamsModel>()) {
      ModelValidateFactoryUtils.registerValidator<ResponseParamsModel>(
        ResponseParamsModel.validateField,
      );
    }
    ValidateResultModel validateResult = ValidateResultModel(
      key: "responseParams",
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
      apiKeyDescModel: statusCodeKeyField,
      validateResult: validateResult,
    );

    JsonToModelUtils.validateFieldStr(
      map,
      apiKeyDescModel: apiBaseModelField,
      validateResult: validateResult,
    );

    JsonToModelUtils.validateFieldStr(
      map,
      apiKeyDescModel: resDataKeyField,
      validateResult: validateResult,
    );

    JsonToModelUtils.validateFieldStr(
      map,
      apiKeyDescModel: resMsgKeyField,
      validateResult: validateResult,
    );

    JsonToModelUtils.validateField<Map<String, String>>(
      map,
      apiKeyDescModel: resultKeyMapField,
      validateResult: validateResult,
      converter: (value) {
        if (value is Map<String, String>) {
          return true;
        }
        // 尝试转换类型
        try {
          DataTypeConvertUtils.toMapStrDyMap(value);
        } catch (e) {
          validateResult.msgMap[resultKeyMapField.key] =
              "${resultKeyMapField.desc}（${resultKeyMapField.key}）数据转换时报错：$e";
          return false;
        }
        return true;
      },
    );

    JsonToModelUtils.validateFieldStr(
      map,
      apiKeyDescModel: resultConvertJsFnField,
      validateResult: validateResult,
    );

    if (validateResult.flag) {
      validateResult.flag = validateResult.msgMap.isEmpty;
    }
    return validateResult;
  }

  static final ApiKeyDescModel statusCodeKeyField = ApiKeyDescModel(
    key: "statusCodeKey",
    desc: "响应状态码key",
    isRequired: true,
  );
  static final ApiKeyDescModel apiBaseModelField = ApiKeyDescModel(
    key: "successStatusCode",
    desc: "响应成功状态码",
    isRequired: true,
  );
  static final ApiKeyDescModel resDataKeyField = ApiKeyDescModel(
    key: "resDataKey",
    desc: "响应读取值的key",
    isRequired: true,
  );
  static final ApiKeyDescModel resMsgKeyField = ApiKeyDescModel(
    key: "resMsgKey",
    desc: "响应说明信息",
    isRequired: false,
  );
  static final ApiKeyDescModel resultKeyMapField = ApiKeyDescModel(
    key: "resultKeyMap",
    desc: "响应结果映射key",
    isRequired: false,
  );
  static final ApiKeyDescModel resultConvertJsFnField = ApiKeyDescModel(
    key: "resultConvertJsFn",
    desc: "用于将结果转换为需要的数据结构的js方法",
    isRequired: false,
  );
}
