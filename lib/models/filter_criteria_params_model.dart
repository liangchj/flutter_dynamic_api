import 'dart:convert';

import '../utils/json_to_model_utils.dart';
import 'api_key_desc_model.dart';
import 'validate_field_model.dart';
import 'validate_result_model.dart';

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
    this.parentValue,
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
    ValidateResultModel validateResult =
        JsonToModelUtils.baseValidate<FilterCriteriaParamsModel>(
          map,
          key: "filterCriteriaParams",
          fromJson: FilterCriteriaParamsModel.fromJson,
          validateFieldFn: FilterCriteriaParamsModel.validateField,
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
            key: "value",
            desc: "传入的值",
            isRequired: true,
          ),
          fieldType: "string",
        ),

        ValidateFieldModel<String>(
          fieldDesc: ApiKeyDescModel(
            key: "label",
            desc: "显示的值",
            isRequired: true,
          ),
          fieldType: "string",
        ),

        ValidateFieldModel<String?>(
          fieldDesc: ApiKeyDescModel(
            key: "parentValue",
            desc: "父级value",
            isRequired: false,
          ),
          fieldType: "string",
        ),
      ],
    );

    return validateResult;
  }
}
