import 'dart:convert';

import '../utils/json_to_model_utils.dart';
import 'api_key_desc_model.dart';
import 'validate_field_model.dart';
import 'validate_result_model.dart';

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
    ValidateResultModel validateResult =
        JsonToModelUtils.baseValidate<RequestParamsModel>(
          map,
          key: "requestParams",
          fromJson: RequestParamsModel.fromJson,
          validateFieldFn: RequestParamsModel.validateField,
        );
    if (!validateResult.flag) {
      return validateResult;
    }

    JsonToModelUtils.validateModelJson(
      map,
      validateResult: validateResult,
      validateFieldList: [
        ValidateFieldModel<Map<String, dynamic>?>(
          fieldDesc: ApiKeyDescModel(
            key: "headerParams",
            desc: "请求头参数",
            isRequired: false,
          ),
          fieldType: "mapStrTody",
        ),

        ValidateFieldModel<Map<String, dynamic>?>(
          fieldDesc: ApiKeyDescModel(
            key: "staticParams",
            desc: "请求静态参数",
            isRequired: false,
          ),
          fieldType: "mapStrTody",
        ),
        ValidateFieldModel<Map<String, dynamic>?>(
          fieldDesc: ApiKeyDescModel(
            key: "dynamicParams",
            desc: "请求动态参数",
            isRequired: false,
          ),
          fieldType: "mapStrTody",
        ),
      ],
    );
    return validateResult;
  }
}
