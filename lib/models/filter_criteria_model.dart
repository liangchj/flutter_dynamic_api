import 'dart:convert';

import '../utils/data_type_convert_utils.dart';
import '../utils/json_to_model_utils.dart';
import 'api_key_desc_model.dart';
import 'net_api_model.dart';
import 'filter_criteria_params_model.dart';
import 'validate_field_model.dart';
import 'validate_result_model.dart';

List<FilterCriteriaModel> filterCriteriaModelListFromJsonStr(String str) =>
    List<FilterCriteriaModel>.from(
      json.decode(str).map((x) => FilterCriteriaModel.fromJson(x)),
    );

List<FilterCriteriaModel> filterCriteriaModelListFromListJson(
  List<Map<String, dynamic>> list,
) => List<FilterCriteriaModel>.from(
  list.map((x) => FilterCriteriaModel.fromJson(x)),
);

String filterCriteriaModelListToJson(List<FilterCriteriaModel> data) =>
    json.encode(List<Map<String, dynamic>>.from(data.map((e) => e.toJson())));

/// 过滤参数配置
/// 当 从网络中请求[netApi] 和 直接指定的列表[filterCriteriaParamsList] 同时存在时优先使用netApi
class FilterCriteriaModel {
  /// 英文名称
  final String enName;

  /// 中文名称
  final String name;

  /// 请求的key
  final String requestKey;

  /// 用于将请求参数转换为需要的数据结构
  /// 因flutter不支持动态，因此 使用js函数
  final String? requestValueConvertJsFn;

  /// 是否可以多选
  final bool? multiples;

  /// 从网络中请求
  final NetApiModel? netApi;

  /// 直接指定的列表
  List<FilterCriteriaParamsModel>? filterCriteriaParamsList;

  FilterCriteriaModel({
    required this.enName,
    required this.name,
    required this.requestKey,
    this.requestValueConvertJsFn,
    this.multiples,
    this.netApi,
    this.filterCriteriaParamsList,
  });
  factory FilterCriteriaModel.fromJson(Map<String, dynamic> map) {
    ValidateResultModel validateResult = FilterCriteriaModel.validateField(map);
    if (validateResult.msgMap.isNotEmpty) {
      throw Exception(validateResult.msgMap);
    }
    List<String> errorList = [];
    var multiples = map["multiples"];
    var netApiVar = map["netApi"];
    Map<String, dynamic>? netApiMap;
    if (netApiVar != null) {
      try {
        netApiMap = DataTypeConvertUtils.toMapStrDyMap(netApiVar);
      } catch (e) {
        errorList.add("读取配置netApi转换类型时报错：$e");
      }
    }

    var filterCriteriaParamsListVar = map["filterCriteriaParamsList"];
    List<Map<String, dynamic>>? filterCriteriaParamsList;
    if (filterCriteriaParamsListVar != null) {
      try {
        filterCriteriaParamsList = DataTypeConvertUtils.toListMapStrDyMap(
          filterCriteriaParamsListVar,
        );
      } catch (e) {
        errorList.add("读取配置filterCriteriaParamsList转换类型时报错：$e");
      }
    }
    if (errorList.isNotEmpty) {
      throw Exception(errorList.join("\n"));
    }
    return FilterCriteriaModel(
      enName: map["enName"],
      name: map["name"],
      requestKey: map["requestKey"],
      requestValueConvertJsFn: (map["requestValueConvertJsFn"] ?? "")
          .toString(),
      multiples: multiples == null ? false : bool.tryParse(multiples) ?? false,
      netApi: netApiMap == null ? null : NetApiModel.fromJson(netApiMap),
      filterCriteriaParamsList: filterCriteriaParamsList == null
          ? null
          : filterCriteriaParamsModelListFromListJson(filterCriteriaParamsList),
    );
  }

  Map<String, dynamic> toJson() => {
    "enName": enName,
    "name": name,
    "requestKey": requestKey,
    "requestValueConvertJsFn": requestValueConvertJsFn,
    "multiples": multiples,
    "netApi": netApi?.toJson(),
    "filterCriteriaParamsList": filterCriteriaParamsList == null
        ? null
        : filterCriteriaParamsModelListToJson(filterCriteriaParamsList!),
  };

  // 验证方法
  static ValidateResultModel validateField(Map<String, dynamic> map) {
    ValidateResultModel validateResult =
        JsonToModelUtils.baseValidate<FilterCriteriaModel>(
          map,
          key: "filterCriteria",
          fromJson: FilterCriteriaModel.fromJson,
          validateFieldFn: FilterCriteriaModel.validateField,
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
            key: "enName",
            desc: "英文名称",
            isRequired: true,
          ),
          fieldType: "string",
        ),
        ValidateFieldModel<String>(
          fieldDesc: ApiKeyDescModel(
            key: "name",
            desc: "中文名称",
            isRequired: true,
          ),
          fieldType: "string",
        ),
        ValidateFieldModel<String>(
          fieldDesc: ApiKeyDescModel(
            key: "requestKey",
            desc: "请求的key",
            isRequired: true,
          ),
          fieldType: "string",
        ),
        ValidateFieldModel<String?>(
          fieldDesc: ApiKeyDescModel(
            key: "requestValueConvertJsFn",
            desc: "用于将请求参数转换为需要的数据结构的js方法",
            isRequired: false,
          ),
          fieldType: "string",
        ),
        ValidateFieldModel<bool?>(
          fieldDesc: ApiKeyDescModel(
            key: "multiples",
            desc: "是否可以多选",
            isRequired: false,
          ),
          fieldType: "bool",
        ),

        ValidateFieldModel<NetApiModel>(
          fieldDesc: ApiKeyDescModel(
            key: "netApi",
            desc: "从网络中请求",
            isRequired: false,
          ),
          fieldType: "class",
          fromJson: NetApiModel.fromJson,
          validateField: NetApiModel.validateField,
        ),

        ValidateFieldModel<FilterCriteriaParamsModel>(
          fieldDesc: ApiKeyDescModel(
            key: "filterCriteriaParamsList",
            desc: "直接指定的列表",
            isRequired: false,
          ),
          fieldType: "classList",
          fromJson: FilterCriteriaParamsModel.fromJson,
          validateField: FilterCriteriaParamsModel.validateField,
        ),
      ],
    );

    return validateResult;
  }
}
