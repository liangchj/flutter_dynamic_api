import 'dart:convert';

import '../utils/data_type_convert_utils.dart';
import '../utils/json_to_model_utils.dart';
import 'api_key_desc_model.dart';
import 'dynamic_params_model.dart';
import 'validate_field_model.dart';
import 'validate_result_model.dart';

/// 请求参数
class RequestParamsModel {
  /// 请求头
  final Map<String, dynamic>? headerParams;

  /// 静态参数
  final Map<String, dynamic>? staticParams;

  /// 动态参数
  final Map<String, DynamicParamsModel>? dynamicParams;

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
    List<String> errorList = [];
    var dynamicParamsVar = map["dynamicParams"];
    Map<String, dynamic>? dynamicParamsMap;
    Map<String, DynamicParamsModel>? dynamicParams;
    if (dynamicParamsVar != null) {
      try {
        dynamicParamsMap = DataTypeConvertUtils.toMapStrDyMap(dynamicParamsVar);
        dynamicParams = {};
        for (var entry in dynamicParamsMap.entries) {
          dynamicParams[entry.key] = DynamicParamsModel.fromJson(
            DataTypeConvertUtils.toMapStrDyMap(entry.value),
          );
        }
      } catch (e) {
        errorList.add("读取配置dynamicParams转换类型时报错：$e");
      }
    }
    if (errorList.isNotEmpty) {
      throw Exception(errorList.join("\n"));
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
      dynamicParams: dynamicParams,
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, Map<String, dynamic>> dynamicParamsToJson = {};
    if (dynamicParams != null) {
      for (var entry in dynamicParams!.entries) {
        dynamicParamsToJson[entry.key] = entry.value.toJson();
      }
    }
    return {
      "headerParams": headerParams == null ? null : json.encode(headerParams),
      "staticParams": staticParams == null ? null : json.encode(staticParams),
      "dynamicParams": dynamicParamsToJson,
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
        ValidateFieldModel<DynamicParamsModel>(
          fieldDesc: ApiKeyDescModel(
            key: "dynamicParams",
            desc: "请求动态参数",
            isRequired: false,
          ),
          fieldType: "mapStrToClass",
          fromJson: DynamicParamsModel.fromJson,
          validateField: DynamicParamsModel.validateField,
        ),
      ],
    );
    return validateResult;
  }
}
