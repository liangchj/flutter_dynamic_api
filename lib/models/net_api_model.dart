import 'dart:convert';

import '../utils/data_type_convert_utils.dart';
import '../utils/json_to_model_utils.dart';
import 'api_key_desc_model.dart';
import 'dynamic_function_model.dart';
import 'request_params_model.dart';
import 'response_params_model.dart';
import 'validate_field_model.dart';
import 'validate_result_model.dart';

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

  /// 扩展信息
  final Map<String, dynamic>? extendMap;

  // 使用webView需要执行的js方法
  final String? webViewJsFn;

  // 将结果写入到缓存中的动态方法
  // 如果是读取html中的数据请使用js
  final DynamicFunctionModel? recordCacheDyFn;

  NetApiModel({
    required this.path,
    this.useBaseUrl = true,
    this.useWebView = false,
    this.usePost = false,
    this.userAgent,
    required this.requestParams,
    required this.responseParams,
    this.extendMap,
    this.webViewJsFn,
    this.recordCacheDyFn,
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
      extendMap: JsonToModelUtils.getMapStrToTFromJson<dynamic>(
        map,
        "extendMap",
      ),
      recordCacheDyFn: map["recordCacheDyFn"] == null
          ? null
          : DynamicFunctionModel.fromJson(map["recordCacheDyFn"]),
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
    "extendMap": extendMap,
    "recordCacheDyFn": recordCacheDyFn?.toJson(),
  };

  // 验证方法
  static ValidateResultModel validateField(Map<String, dynamic> map) {
    ValidateResultModel validateResult =
        JsonToModelUtils.baseValidate<NetApiModel>(
          map,
          key: "netApi",
          fromJson: NetApiModel.fromJson,
          validateFieldFn: NetApiModel.validateField,
        );
    if (!validateResult.flag) {
      return validateResult;
    }
    var useWebViewVar = map["useWebView"];
    bool useWebView = useWebViewVar == null
        ? false
        : bool.tryParse(useWebViewVar) ?? false;

    JsonToModelUtils.validateModelJson(
      map,
      validateResult: validateResult,
      validateFieldList: [
        ValidateFieldModel<String>(
          fieldDesc: ApiKeyDescModel(
            key: "path",
            desc: "请求路径",
            isRequired: true,
          ),
          fieldType: "string",
        ),
        ValidateFieldModel<bool>(
          fieldDesc: ApiKeyDescModel(
            key: "useBaseUrl",
            desc: "是否使用基本的链接",
            isRequired: false,
          ),
          fieldType: "bool",
        ),
        ValidateFieldModel<bool>(
          fieldDesc: ApiKeyDescModel(
            key: "useWebView",
            desc: "是否使用webView",
            isRequired: false,
          ),
          fieldType: "bool",
        ),
        ValidateFieldModel<bool>(
          fieldDesc: ApiKeyDescModel(
            key: "usePost",
            desc: "是否使用post请求",
            isRequired: false,
          ),
          fieldType: "bool",
        ),
        ValidateFieldModel<String>(
          fieldDesc: ApiKeyDescModel(
            key: "userAgent",
            desc: "指定代理",
            isRequired: false,
          ),
          fieldType: "string",
        ),
        ValidateFieldModel<RequestParamsModel>(
          fieldDesc: ApiKeyDescModel(
            key: "requestParams",
            desc: "请求信息",
            isRequired: true,
          ),
          fieldType: "class",
          fromJson: RequestParamsModel.fromJson,
          validateField: RequestParamsModel.validateField,
        ),
        ValidateFieldModel<ResponseParamsModel>(
          fieldDesc: ApiKeyDescModel(
            key: "responseParams",
            desc: "响应信息",
            isRequired: true,
          ),
          fieldType: "class",
          fromJson: ResponseParamsModel.fromJson,
          validateField: ResponseParamsModel.validateField,
        ),

        ValidateFieldModel<Map<String, dynamic>?>(
          fieldDesc: ApiKeyDescModel(
            key: "extendMap",
            desc: "扩展信息",
            isRequired: false,
          ),
          fieldType: "mapStrTody",
        ),

        ValidateFieldModel<String>(
          fieldDesc: ApiKeyDescModel(
            key: "webViewJsFn",
            desc: "使用webView需要执行的js方法",
            isRequired: useWebView,
          ),
          fieldType: "string",
        ),

        ValidateFieldModel<DynamicFunctionModel>(
          fieldDesc: ApiKeyDescModel(
            key: "recordCacheDyFn",
            desc: "将结果写入到缓存中的动态方法，如果是读取html中的数据请使用js",
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
