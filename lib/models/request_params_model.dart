import 'dart:convert';

import 'package:flutter_dynamic_api/models/validate_result_model.dart';

import '../utils/data_type_convert_utils.dart';
import '../utils/json_to_model_utils.dart';
import '../utils/model_validate_factory_utils.dart';
import 'api_key_desc_model.dart';

/// 请求参数
class RequestParamsModel {
  /// 请求头
  final Map<String, dynamic>? headerParams;

  /// 静态参数
  final Map<String, dynamic>? staticParams;

  /// 动态参数
  final Map<String, dynamic>? dynamicParams;

  RequestParamsModel({
    required this.headerParams,
    required this.staticParams,
    required this.dynamicParams,
  });

  factory RequestParamsModel.fromJson(Map<String, dynamic> map) {
    ValidateResultModel validateResult = RequestParamsModel.validateField(map);
    if (validateResult.msgMap.isNotEmpty) {
      throw Exception(validateResult.msgMap);
    }
    return RequestParamsModel(
      headerParams: JsonToModelUtils.getMapStrToTFromJson<dynamic>(
        map,
        "headerParams",
      ),
      staticParams: JsonToModelUtils.getMapStrToTFromJson<dynamic>(
        map,
        "staticParams",
      ),
      dynamicParams: JsonToModelUtils.getMapStrToTFromJson<dynamic>(
        map,
        "dynamicParams",
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "headerParams": headerParams == null ? null : json.encode(headerParams),
      "staticParams": staticParams == null ? null : json.encode(staticParams),
      "dynamicParams": dynamicParams == null
          ? null
          : json.encode(dynamicParams),
    };
  }

  // 验证方法
  static ValidateResultModel validateField(Map<String, dynamic> map) {
    if (ModelValidateFactoryUtils.isRegisterFactory<RequestParamsModel>()) {
      ModelValidateFactoryUtils.register<RequestParamsModel>(
        validator: RequestParamsModel.validateField,
        factory: RequestParamsModel.fromJson,
      );
    }
    if (ModelValidateFactoryUtils.isRegisterValidator<RequestParamsModel>()) {
      ModelValidateFactoryUtils.registerValidator<RequestParamsModel>(
        RequestParamsModel.validateField,
      );
    }
    ValidateResultModel validateResult = ValidateResultModel(
      key: "requestParams",
      msgMap: {},
      childValidateResultMap: {},
    );
    if (map.isEmpty) {
      validateResult.msgMap["json"] = "接收传入的json数据为空";
      validateResult.flag = false;
      return validateResult;
    }

    JsonToModelUtils.validateField<Map<String, dynamic>?>(
      map,
      apiKeyDescModel: headerParamsKey,
      validateResult: validateResult,
      converter: (value) {
        if (value is Map<String, dynamic>? || value is Map<String, dynamic>) {
          return true;
        }
        // 尝试转换类型
        try {
          DataTypeConvertUtils.toMapStrDyMap(value);
        } catch (e) {
          validateResult.msgMap[headerParamsKey.key] =
              "${headerParamsKey.desc}（${headerParamsKey.key}）数据转换时报错：$e";
          return false;
        }
        return true;
      },
    );

    JsonToModelUtils.validateField<Map<String, dynamic>?>(
      map,
      apiKeyDescModel: staticParamsKey,
      validateResult: validateResult,
      converter: (value) {
        if (value is Map<String, dynamic>? || value is Map<String, dynamic>) {
          return true;
        }
        // 尝试转换类型
        try {
          DataTypeConvertUtils.toMapStrDyMap(value);
        } catch (e) {
          validateResult.msgMap[staticParamsKey.key] =
              "${staticParamsKey.desc}（${staticParamsKey.key}）数据转换时报错：$e";
          return false;
        }
        return true;
      },
    );
    JsonToModelUtils.validateField<Map<String, dynamic>?>(
      map,
      apiKeyDescModel: dynamicParamsKey,
      validateResult: validateResult,
      converter: (value) {
        if (value is Map<String, dynamic>? || value is Map<String, dynamic>) {
          return true;
        }
        // 尝试转换类型
        try {
          DataTypeConvertUtils.toMapStrDyMap(value);
        } catch (e) {
          validateResult.msgMap[dynamicParamsKey.key] =
              "${dynamicParamsKey.desc}（${dynamicParamsKey.key}）数据转换时报错：$e";
          return false;
        }
        return true;
      },
    );
    if (validateResult.flag) {
      validateResult.flag = validateResult.msgMap.isEmpty;
    }
    return validateResult;
  }

  static final ApiKeyDescModel headerParamsKey = ApiKeyDescModel(
    key: "headerParams",
    desc: "请求头",
    isRequired: false,
  );
  static final ApiKeyDescModel staticParamsKey = ApiKeyDescModel(
    key: "staticParams",
    desc: "请求静态参数",
    isRequired: false,
  );
  static final ApiKeyDescModel dynamicParamsKey = ApiKeyDescModel(
    key: "dynamicParams",
    desc: "请求动态参数",
    isRequired: false,
  );
}
