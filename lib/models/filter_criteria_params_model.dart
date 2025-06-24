import 'dart:convert';

import 'package:flutter_dynamic_api/models/validate_result_model.dart';

import '../utils/json_to_model_utils.dart';
import '../utils/model_validate_factory_utils.dart';
import 'api_key_desc_model.dart';

List<FilterCriteriaParamsModel> filterCriteriaParamsModelListFromJsonStr(
  String str,
) => List<FilterCriteriaParamsModel>.from(
  json.decode(str).map((x) => FilterCriteriaParamsModel.fromJson(x)),
);

List<FilterCriteriaParamsModel> filterCriteriaParamsModelListFromListJson(
  List<Map<String, dynamic>> list,
) => List<FilterCriteriaParamsModel>.from(
  list.map((x) => FilterCriteriaParamsModel.fromJson(x)),
);

String filterCriteriaParamsModelListToJson(
  List<FilterCriteriaParamsModel> data,
) => json.encode(List<Map<String, dynamic>>.from(data.map((e) => e.toJson())));

/// 过滤参数
class FilterCriteriaParamsModel {
  /// 传入的值
  final String value;

  /// 显示的值
  final String label;

  /// 父级value
  final String? parentValue;

  FilterCriteriaParamsModel({
    required this.value,
    required this.label,
    required this.parentValue,
  });

  factory FilterCriteriaParamsModel.fromJson(Map<String, dynamic> map) {
    ValidateResultModel validateResult =
        FilterCriteriaParamsModel.validateField(map);
    if (validateResult.msgMap.isNotEmpty) {
      throw Exception(validateResult.msgMap);
    }

    return FilterCriteriaParamsModel(
      value: map["value"],
      label: map["label"],
      parentValue: map["parentValue"],
    );
  }
  Map<String, dynamic> toJson() => {
    "value": value,
    "label": label,
    "parentValue": parentValue,
  };

  // 验证方法
  static ValidateResultModel validateField(Map<String, dynamic> map) {
    if (ModelValidateFactoryUtils.isRegisterFactory<
      FilterCriteriaParamsModel
    >()) {
      ModelValidateFactoryUtils.register<FilterCriteriaParamsModel>(
        validator: FilterCriteriaParamsModel.validateField,
        factory: FilterCriteriaParamsModel.fromJson,
      );
    }
    if (ModelValidateFactoryUtils.isRegisterValidator<
      FilterCriteriaParamsModel
    >()) {
      ModelValidateFactoryUtils.registerValidator<FilterCriteriaParamsModel>(
        FilterCriteriaParamsModel.validateField,
      );
    }
    ValidateResultModel validateResult = ValidateResultModel(
      key: "filterCriteriaParams",
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
      apiKeyDescModel: valueField,
      validateResult: validateResult,
    );

    JsonToModelUtils.validateFieldStr(
      map,
      apiKeyDescModel: labelField,
      validateResult: validateResult,
    );

    JsonToModelUtils.validateFieldStr(
      map,
      apiKeyDescModel: parentValueField,
      validateResult: validateResult,
    );
    if (validateResult.flag) {
      validateResult.flag = validateResult.msgMap.isEmpty;
    }
    return validateResult;
  }

  static final ApiKeyDescModel valueField = ApiKeyDescModel(
    key: "value",
    desc: "传入的值",
    isRequired: true,
  );
  static final ApiKeyDescModel labelField = ApiKeyDescModel(
    key: "label",
    desc: "显示的值",
    isRequired: true,
  );
  static final ApiKeyDescModel parentValueField = ApiKeyDescModel(
    key: "parentValue",
    desc: "父级value",
    isRequired: false,
  );
}
