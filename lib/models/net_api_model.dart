import 'dart:convert';

import 'package:flutter_dynamic_api/models/validate_result_model.dart';

import '../utils/data_type_convert_utils.dart';
import '../utils/json_to_model_utils.dart';
import '../utils/model_validate_factory_utils.dart';
import 'api_key_desc_model.dart';
import 'filter_criteria_model.dart';
import 'request_params_model.dart';
import 'response_params_model.dart';

List<NetApiModel> netApiModelListFromJsonStr(String str) =>
    List<NetApiModel>.from(
      json.decode(str).map((x) => NetApiModel.fromJson(x)),
    );

List<NetApiModel> netApiModelListFromListJson(
  List<Map<String, dynamic>> list,
) => List<NetApiModel>.from(list.map((x) => NetApiModel.fromJson(x)));

String netApiModelListToJson(List<NetApiModel> data) =>
    json.encode(List<Map<String, dynamic>>.from(data.map((e) => e.toJson())));

/// 网络的api
class NetApiModel {
  /// 路径，完整路径：baseUrl + path
  final String path;

  /// 是否使用基本的链接
  final bool useBaseUrl;

  /// 使用webView
  final bool useWebView;

  /// 使用post请求
  final bool usePost;

  /// 指定代理
  final String? userAgent;

  /// 请求信息
  final RequestParamsModel requestParams;

  /// 响应信息
  final ResponseParamsModel responseParams;

  /// 过滤请求
  final List<FilterCriteriaModel>? filterCriteriaList;

  /// 扩展信息
  final Map<String, dynamic>? extendMap;

  NetApiModel({
    required this.path,
    this.useBaseUrl = true,
    this.useWebView = false,
    this.usePost = false,
    this.userAgent,
    required this.requestParams,
    required this.responseParams,
    this.filterCriteriaList,
    this.extendMap,
  });

  factory NetApiModel.fromJson(Map<String, dynamic> map) {
    ValidateResultModel validateResult = NetApiModel.validateField(map);
    if (validateResult.msgMap.isNotEmpty) {
      throw Exception(validateResult.msgMap);
    }
    List<String> errorList = [];
    var useBaseUrl = map["useBaseUrl"];
    var useWebView = map["useWebView"];
    var usePost = map["usePost"];
    var userAgent = map["userAgent"];

    var requestParamsVar = map["requestParams"];
    Map<String, dynamic> requestParamsMap = {};
    if (requestParamsVar != null) {
      try {
        requestParamsMap.addAll(
          DataTypeConvertUtils.toMapStrDyMap(requestParamsVar),
        );
      } catch (e) {
        errorList.add("读取配置requestParams转换类型时报错：$e");
      }
    }

    var responseParamsVar = map["responseParams"];
    Map<String, dynamic> responseParamsMap = {};
    if (responseParamsVar != null) {
      try {
        responseParamsMap.addAll(
          DataTypeConvertUtils.toMapStrDyMap(responseParamsVar),
        );
      } catch (e) {
        errorList.add("读取配置responseParams转换类型时报错：$e");
      }
    }
    var filterCriteriaListVar = map["filterCriteriaList"];
    List<Map<String, dynamic>>? filterCriteriaList;
    if (filterCriteriaListVar != null) {
      try {
        filterCriteriaList = DataTypeConvertUtils.toListMapStrDyMap(
          filterCriteriaListVar,
        );
      } catch (e) {
        errorList.add("读取配置filterCriteriaList转换类型时报错：$e");
      }
    }
    if (errorList.isNotEmpty) {
      throw Exception(errorList.join("\n"));
    }
    return NetApiModel(
      path: map["path"],
      useBaseUrl: useBaseUrl == null ? true : bool.tryParse(useBaseUrl) ?? true,
      useWebView: useWebView == null
          ? false
          : bool.tryParse(useWebView) ?? false,
      usePost: usePost == null ? false : bool.tryParse(usePost) ?? false,
      userAgent: userAgent,
      requestParams: RequestParamsModel.fromJson(requestParamsMap),
      responseParams: ResponseParamsModel.fromJson(responseParamsMap),
      filterCriteriaList: filterCriteriaList == null
          ? null
          : filterCriteriaModelListFromListJson(filterCriteriaList),
      extendMap: JsonToModelUtils.getMapStrToTFromJson<dynamic>(
        map,
        "extendMap",
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    "path": path,
    "useBaseUrl": useBaseUrl,
    "useWebView": useWebView,
    "usePost": usePost,
    "userAgent": userAgent,
    "requestParams": requestParams.toJson(),
    "responseParams": responseParams.toJson(),
    "filterCriteriaList": filterCriteriaList == null
        ? null
        : filterCriteriaModelListToJson(filterCriteriaList!),
    "extendMap": extendMap,
  };

  // 验证方法
  static ValidateResultModel validateField(Map<String, dynamic> map) {
    if (ModelValidateFactoryUtils.isRegisterFactory<NetApiModel>()) {
      ModelValidateFactoryUtils.register<NetApiModel>(
        validator: NetApiModel.validateField,
        factory: NetApiModel.fromJson,
      );
    }
    if (ModelValidateFactoryUtils.isRegisterValidator<NetApiModel>()) {
      ModelValidateFactoryUtils.registerValidator<NetApiModel>(
        NetApiModel.validateField,
      );
    }
    ValidateResultModel validateResult = ValidateResultModel(
      key: "netApi",
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
      apiKeyDescModel: pathField,
      validateResult: validateResult,
    );
    JsonToModelUtils.validateFieldBool(
      map,
      apiKeyDescModel: useBaseUrlField,
      validateResult: validateResult,
    );

    JsonToModelUtils.validateFieldBool(
      map,
      apiKeyDescModel: useWebViewField,
      validateResult: validateResult,
    );

    JsonToModelUtils.validateFieldBool(
      map,
      apiKeyDescModel: usePostField,
      validateResult: validateResult,
    );

    JsonToModelUtils.validateFieldBool(
      map,
      apiKeyDescModel: userAgentField,
      validateResult: validateResult,
    );

    JsonToModelUtils.validateField<RequestParamsModel>(
      map,
      apiKeyDescModel: requestParamsField,
      validateResult: validateResult,
      converter: (value) =>
          requestParamsFieldTypeValidateAndConvert(value, validateResult),
    );

    JsonToModelUtils.validateField<ResponseParamsModel>(
      map,
      apiKeyDescModel: responseParamsField,
      validateResult: validateResult,
      converter: (value) =>
          responseParamsFieldTypeValidateAndConvert(value, validateResult),
    );

    JsonToModelUtils.validateField<List<FilterCriteriaModel>?>(
      map,
      apiKeyDescModel: filterCriteriaListField,
      validateResult: validateResult,
      converter: (value) =>
          filterCriteriaFieldTypeValidateAndConvert(value, validateResult),
    );

    JsonToModelUtils.validateField<Map<String, dynamic>?>(
      map,
      apiKeyDescModel: extendMapField,
      validateResult: validateResult,
      converter: (value) {
        if (value is Map<String, dynamic>? || value is Map<String, dynamic>) {
          return true;
        }
        // 尝试转换类型
        try {
          DataTypeConvertUtils.toMapStrDyMap(value);
        } catch (e) {
          validateResult.msgMap[extendMapField.key] =
              "${extendMapField.desc}（${extendMapField.key}）数据转换时报错：$e";
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

  /// 请求信息字段数据类型转换验证
  static bool requestParamsFieldTypeValidateAndConvert(
    value,
    ValidateResultModel validateResult,
  ) {
    Map<String, dynamic> dataMap = {};
    if (value is RequestParamsModel) {
      dataMap = value.toJson();
    } else if (value is Map<String, dynamic>) {
      dataMap.addAll(value);
    }
    try {
      dataMap.addAll(DataTypeConvertUtils.toMapStrDyMap(value));
    } catch (e) {
      validateResult.msgMap[requestParamsField.key] =
          "${requestParamsField.desc}（${requestParamsField.key}）转换数据时报错：$e";
      return false;
    }
    var result = RequestParamsModel.validateField(dataMap);
    validateResult.childValidateResultMap[requestParamsField.key] = {
      requestParamsField.key: result,
    };
    return result.flag;
  }

  /// 响应信息字段数据类型转换验证
  static bool responseParamsFieldTypeValidateAndConvert(
    value,
    ValidateResultModel validateResult,
  ) {
    Map<String, dynamic> dataMap = {};
    if (value is ResponseParamsModel) {
      dataMap = value.toJson();
    } else if (value is Map<String, dynamic>) {
      dataMap.addAll(value);
    }
    try {
      dataMap.addAll(DataTypeConvertUtils.toMapStrDyMap(value));
    } catch (e) {
      validateResult.msgMap[responseParamsField.key] =
          "${responseParamsField.desc}（${responseParamsField.key}）转换数据时报错：$e";
      return false;
    }
    var result = ResponseParamsModel.validateField(dataMap);
    validateResult.childValidateResultMap[responseParamsField.key] = {
      responseParamsField.key: result,
    };
    return result.flag;
  }

  /// 过滤请求列表信息字段数据类型转换验证
  static bool filterCriteriaFieldTypeValidateAndConvert(
    value,
    ValidateResultModel validateResult,
  ) {
    Map<String, ValidateResultModel> filterCriteriaResultMap = {};
    if (value is List<FilterCriteriaModel> ||
        value is List<FilterCriteriaModel>?) {
      return true;
    }
    bool flag = true;
    List<Map<String, dynamic>> list = [];
    if (value is List<FilterCriteriaModel>?) {
      return true;
    }
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
        validateResult.msgMap[filterCriteriaListField.key] =
            "${filterCriteriaListField.desc}（${filterCriteriaListField.key}）数据转换时报错：$e";
        return false;
      }
    }
    for (var item in list) {
      String key = item["enName"] ?? item["name"] ?? "";
      ValidateResultModel result = FilterCriteriaModel.validateField(item);
      filterCriteriaResultMap[key] = result;
      if (!result.flag) {
        flag = false;
      }
    }
    validateResult.childValidateResultMap[filterCriteriaListField.key] =
        filterCriteriaResultMap;
    return flag;
  }

  static final ApiKeyDescModel pathField = ApiKeyDescModel(
    key: "path",
    desc: "请求路径",
    isRequired: true,
  );
  static final ApiKeyDescModel useBaseUrlField = ApiKeyDescModel(
    key: "useBaseUrl",
    desc: "是否使用基本的链接",
    isRequired: false,
  );
  static final ApiKeyDescModel useWebViewField = ApiKeyDescModel(
    key: "useWebView",
    desc: "是否使用webView",
    isRequired: false,
  );
  static final ApiKeyDescModel usePostField = ApiKeyDescModel(
    key: "usePost",
    desc: "是否使用post请求",
    isRequired: false,
  );
  static final ApiKeyDescModel userAgentField = ApiKeyDescModel(
    key: "userAgent",
    desc: "指定代理",
    isRequired: false,
  );
  static final ApiKeyDescModel requestParamsField = ApiKeyDescModel(
    key: "requestParams",
    desc: "请求信息",
    isRequired: true,
  );
  static final ApiKeyDescModel responseParamsField = ApiKeyDescModel(
    key: "responseParams",
    desc: "响应信息",
    isRequired: true,
  );
  static final ApiKeyDescModel filterCriteriaListField = ApiKeyDescModel(
    key: "filterCriteriaList",
    desc: "过滤请求列表",
    isRequired: false,
  );

  static final ApiKeyDescModel extendMapField = ApiKeyDescModel(
    key: "extendMap",
    desc: "扩展信息",
    isRequired: false,
  );
}
