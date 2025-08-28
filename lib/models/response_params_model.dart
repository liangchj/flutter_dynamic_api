import 'dart:convert';

import '../utils/data_type_convert_utils.dart';
import '../utils/json_to_model_utils.dart';
import 'api_key_desc_model.dart';
import 'dynamic_function_model.dart';
import 'validate_field_model.dart';
import 'validate_result_model.dart';

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
  /// 因flutter不支持动态，因此 使用js或dart_eval函数
  final DynamicFunctionModel? resultConvertDyFn;

  ResponseParamsModel({
    required this.statusCodeKey,
    required this.successStatusCode,
    required this.resDataKey,
    this.resMsgKey,
    required this.resultKeyMap,
    this.resultConvertDyFn,
  });

  factory ResponseParamsModel.fromJson(Map<String, dynamic> map) {
    ValidateResultModel validateResult = ResponseParamsModel.validateField(map);
    if (validateResult.msgMap.isNotEmpty) {
      throw Exception(validateResult.msgMap);
    }
    Map<String, dynamic>? resultConvertDyFnMap;
    var resultConvertDyFn = map["resultConvertDyFn"];
    if (resultConvertDyFn != null) {
      resultConvertDyFnMap = DataTypeConvertUtils.toMapStrDyMap(resultConvertDyFn);
    }
    return ResponseParamsModel(
      statusCodeKey: map["statusCodeKey"],
      successStatusCode: map["successStatusCode"],
      resDataKey: map["resDataKey"],
      resMsgKey: map["resMsgKey"],
      resultKeyMap:
          JsonToModelUtils.getMapStrToTFromJson<String>(map, "resultKeyMap") ??
          {},
      resultConvertDyFn: resultConvertDyFnMap == null
          ? null
          : DynamicFunctionModel.fromJson(resultConvertDyFnMap),
    );
  }

  Map<String, dynamic> toJson() => {
    "statusCodeKey": statusCodeKey,
    "successStatusCode": successStatusCode,
    "resDataKey": resDataKey,
    "resMsgKey": resMsgKey,
    "resultKeyMap": json.encode(resultKeyMap),
    "resultConvertDyFn": resultConvertDyFn?.toJson(),
  };

  // 验证方法
  static ValidateResultModel validateField(Map<String, dynamic> map) {
    ValidateResultModel validateResult =
        JsonToModelUtils.baseValidate<ResponseParamsModel>(
          map,
          key: "responseParams",
          fromJson: ResponseParamsModel.fromJson,
          validateFieldFn: ResponseParamsModel.validateField,
        );
    if (!validateResult.flag) {
      return validateResult;
    }

    JsonToModelUtils.validateModelJson(
      map,
      validateResult: validateResult,
      validateFieldList: [
        ValidateFieldModel<String>(
          fieldDesc: ApiKeyDescModel(
            key: "statusCodeKey",
            desc: "响应状态码key",
            isRequired: true,
          ),
          fieldType: "string",
        ),

        ValidateFieldModel<String>(
          fieldDesc: ApiKeyDescModel(
            key: "successStatusCode",
            desc: "响应成功状态码",
            isRequired: true,
          ),
          fieldType: "string",
        ),
        ValidateFieldModel<String>(
          fieldDesc: ApiKeyDescModel(
            key: "resDataKey",
            desc: "响应读取值的key",
            isRequired: true,
          ),
          fieldType: "string",
        ),
        ValidateFieldModel<String>(
          fieldDesc: ApiKeyDescModel(
            key: "resMsgKey",
            desc: "响应说明信息key",
            isRequired: false,
          ),
          fieldType: "string",
        ),

        ValidateFieldModel<Map<String, String>>(
          fieldDesc: ApiKeyDescModel(
            key: "resultKeyMap",
            desc: "响应结果映射key",
            isRequired: true,
          ),
          fieldType: "mapStrTody",
        ),

        ValidateFieldModel<DynamicFunctionModel>(
          fieldDesc: ApiKeyDescModel(
            key: "resultConvertDyFn",
            desc: "用于将结果转换为需要的数据结构的动态方法",
            isRequired: false,
          ),
          fieldType: "class",
          fromJson: DynamicFunctionModel.fromJson,
          validateField: DynamicFunctionModel.validateField,
        ),
      ],
    );

    return validateResult;
  }
}
