import 'dart:convert';

import 'package:flutter_dynamic_api/models/validate_result_model.dart';

import '../utils/data_type_convert_utils.dart';
import '../utils/json_to_model_utils.dart';
import '../utils/model_validate_factory_utils.dart';
import 'api_key_desc_model.dart';
import 'net_api_model.dart';
import 'filter_criteria_params_model.dart';

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

  /// 是否可以传入多个
  final bool? multiples;

  /// 从网络中请求
  final NetApiModel? netApi;

  /// 直接指定的列表
  final List<FilterCriteriaParamsModel>? filterCriteriaParamsList;

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
    if (ModelValidateFactoryUtils.isRegisterFactory<FilterCriteriaModel>()) {
      ModelValidateFactoryUtils.register<FilterCriteriaModel>(
        validator: FilterCriteriaModel.validateField,
        factory: FilterCriteriaModel.fromJson,
      );
    }
    if (ModelValidateFactoryUtils.isRegisterValidator<FilterCriteriaModel>()) {
      ModelValidateFactoryUtils.registerValidator<FilterCriteriaModel>(
        FilterCriteriaModel.validateField,
      );
    }
    ValidateResultModel validateResult = ValidateResultModel(
      key: "filterCriteria",
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
      apiKeyDescModel: enNameKey,
      validateResult: validateResult,
    );

    JsonToModelUtils.validateFieldStr(
      map,
      apiKeyDescModel: nameKey,
      validateResult: validateResult,
    );

    JsonToModelUtils.validateFieldStr(
      map,
      apiKeyDescModel: requestKeyKey,
      validateResult: validateResult,
    );

    JsonToModelUtils.validateFieldStr(
      map,
      apiKeyDescModel: requestValueConvertJsFnKey,
      validateResult: validateResult,
    );

    JsonToModelUtils.validateFieldBool(
      map,
      apiKeyDescModel: multiplesKey,
      validateResult: validateResult,
    );

    JsonToModelUtils.validateField<NetApiModel>(
      map,
      apiKeyDescModel: netApiKey,
      validateResult: validateResult,
      converter: (value) =>
          netApiFieldTypeValidateAndConvert(value, validateResult),
    );

    JsonToModelUtils.validateField<List<FilterCriteriaParamsModel>?>(
      map,
      apiKeyDescModel: filterCriteriaParamsListKey,
      validateResult: validateResult,
      converter: (value) => filterCriteriaParamsListFieldTypeValidateAndConvert(
        value,
        validateResult,
      ),
    );

    if (validateResult.flag) {
      validateResult.flag = validateResult.msgMap.isEmpty;
    }
    return validateResult;
  }

  /// 从网络中请求字段数据类型转换验证
  static bool netApiFieldTypeValidateAndConvert(
    value,
    ValidateResultModel validateResult,
  ) {
    if (value is NetApiModel) {
      return true;
    }
    Map<String, dynamic> dataMap = {};
    if (value is Map<String, dynamic>) {
      dataMap.addAll(value);
    } else {
      // 尝试转换类型
      try {
        dataMap.addAll(DataTypeConvertUtils.toMapStrDyMap(value));
      } catch (e) {
        validateResult.msgMap[netApiKey.key] =
            "${netApiKey.desc}（${netApiKey.key}）数据转换时报错：$e";
        return false;
      }
    }
    var result = NetApiModel.validateField(dataMap);
    validateResult.childValidateResultMap[netApiKey.key] = {
      netApiKey.key: result,
    };
    return result.flag;
  }

  /// 直接指定的列表字段数据类型转换验证
  static bool filterCriteriaParamsListFieldTypeValidateAndConvert(
    value,
    ValidateResultModel validateResult,
  ) {
    if (value is List<FilterCriteriaParamsModel> ||
        value is List<FilterCriteriaParamsModel>?) {
      return true;
    }
    bool flag = true;
    Map<String, ValidateResultModel> filterCriteriaParamsResultMap = {};
    List<Map<String, dynamic>> list = [];
    if (value is List<Map<String, dynamic>>) {
      list.addAll(value);
    } else if (value is Map<String, dynamic>) {
      list.add(value);
    } else {
      // 尝试转换类型
      try {
        list.addAll(DataTypeConvertUtils.toListMapStrDyMap(value));
      } catch (e) {
        flag = false;
        validateResult.msgMap[filterCriteriaParamsListKey.key] =
            "${filterCriteriaParamsListKey.desc}（${filterCriteriaParamsListKey.key}）数据转换时报错：$e";
        return false;
      }
    }

    for (int i = 0; i < list.length; i++) {
      Map<String, dynamic> item = list[i];
      ValidateResultModel result = FilterCriteriaParamsModel.validateField(
        item,
      );
      filterCriteriaParamsResultMap[i.toString()] = result;
      if (!result.flag) {
        flag = false;
      }
    }
    validateResult.childValidateResultMap[filterCriteriaParamsListKey.key] =
        filterCriteriaParamsResultMap;
    return flag;
  }

  static final ApiKeyDescModel enNameKey = ApiKeyDescModel(
    key: "enName",
    desc: "英文名称",
    isRequired: true,
  );
  static final ApiKeyDescModel nameKey = ApiKeyDescModel(
    key: "name",
    desc: "中文名称",
    isRequired: true,
  );
  static final ApiKeyDescModel requestKeyKey = ApiKeyDescModel(
    key: "requestKey",
    desc: "请求的key",
    isRequired: true,
  );
  static final ApiKeyDescModel requestValueConvertJsFnKey = ApiKeyDescModel(
    key: "requestValueConvertJsFn",
    desc: "用于将请求参数转换为需要的数据结构的js方法",
    isRequired: false,
  );
  static final ApiKeyDescModel multiplesKey = ApiKeyDescModel(
    key: "multiples",
    desc: "是否可以传入多个",
    isRequired: false,
  );
  static final ApiKeyDescModel netApiKey = ApiKeyDescModel(
    key: "netApi",
    desc: "从网络中请求",
    isRequired: false,
  );
  static final ApiKeyDescModel filterCriteriaParamsListKey = ApiKeyDescModel(
    key: "filterCriteriaParamsList",
    desc: "直接指定的列表",
    isRequired: false,
  );
}
