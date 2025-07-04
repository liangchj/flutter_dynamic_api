import 'dart:convert';
import 'package:dart_eval/dart_eval.dart';
import 'package:dart_eval/stdlib/core.dart';
import 'package:flutter_dynamic_api/models/dynamic_function_model.dart';
import 'package:flutter_dynamic_api/utils/data_type_convert_utils.dart';
import 'package:flutter_js/js_eval_result.dart';
import '../enums/response_parse_status_code_common.dart';
import '../models/default_response_model.dart';
import '../models/net_api_model.dart';
import '../models/page_model.dart';
import '../models/response_params_model.dart';
import '../utils/js_execute_utils.dart';
import 'response_parser.dart';

class DefaultResponseParser<T> implements ResponseParser<T> {
  final T Function(Map<String, dynamic>) fromJson;

  DefaultResponseParser(this.fromJson);

  // 解析列表数据
  @override
  PageModel<T> listDataParse(dynamic data, NetApiModel netApi) {
    if (data == null) {
      return PageModel<T>(
        page: 0,
        pageSize: 0,
        totalPage: 0,
        totalCount: 0,
        isEnd: true,
        modelList: null,
        statusCode: ResponseParseStatusCodeEnum.dataNull.code,
        msg: ResponseParseStatusCodeEnum.dataNull.name,
      );
    }
    // 如果有定义动态方法就使用动态方法
    if (netApi.responseParams.resultConvertDyFn != null) {
      return listEvaluateDynamicFunction(data, netApi);
    }
    Map<String, dynamic> dataMap = {};
    try {
      dataMap = DataTypeConvertUtils.toMapStrDyMap(data);
    } catch (e) {
      return PageModel<T>(
        page: 0,
        pageSize: 0,
        totalPage: 0,
        totalCount: 0,
        isEnd: true,
        statusCode: ResponseParseStatusCodeEnum.parseFail.code,
        msg:
            "${ResponseParseStatusCodeEnum.parseFail.name}，返回的数据不是有效的Map<dynamic, dynamic>或Map<String, dynamic>格式，请自定义js方法转换",
      );
    }
    Map<String, dynamic> handleDataMap = convertTargetJsonMultiple(
      dataMap,
      netApi.responseParams,
    );
    return parseResponseToPageModel(handleDataMap, netApi.responseParams);
  }

  // 列表执行动态方法
  PageModel<T> listEvaluateDynamicFunction(dynamic data, NetApiModel netApi) {
    if (netApi.responseParams.resultConvertDyFn == null) {
      return PageModel<T>(
        page: 0,
        pageSize: 0,
        totalPage: 0,
        totalCount: 0,
        isEnd: true,
        statusCode: ResponseParseStatusCodeEnum.dynamicFnNull.code,
        msg: ResponseParseStatusCodeEnum.dynamicFnNull.name,
      );
    }
    if (netApi.responseParams.resultConvertDyFn!.dynamicFunctionEnum ==
        DynamicFunctionEnum.js) {
      // 动态方法时js脚本
      return listEvaluateJsFunction(data, netApi);
    }

    return listEvaluateEvalFunction(data, netApi);
  }

  /// 列表执行eval方法
  PageModel<T> listEvaluateEvalFunction(dynamic data, NetApiModel netApi) {
    Map<String, dynamic> dataMap = {};
    try {
      dataMap = DataTypeConvertUtils.toMapStrDyMap(data);
    } catch (e) {
      return PageModel<T>(
        page: 0,
        pageSize: 0,
        totalPage: 0,
        totalCount: 0,
        isEnd: true,
        statusCode: ResponseParseStatusCodeEnum.evalNotAllowDataType.code,
        msg:
            "${ResponseParseStatusCodeEnum.evalNotAllowDataType.name}，当前数据类型转换失败：$e",
      );
    }
    try {
      Map<String, dynamic> result = eval(
        netApi.responseParams.resultConvertDyFn!.fn,
        function: netApi.responseParams.resultConvertDyFn!.fnName ?? "main",
        args: [$Object(dataMap)],
      );
      return parseResponseToPageModel(result, netApi.responseParams);
    } catch (e) {
      return PageModel<T>(
        page: 0,
        pageSize: 0,
        totalPage: 0,
        totalCount: 0,
        isEnd: true,
        statusCode: ResponseParseStatusCodeEnum.dynamicFnExecuteFail.code,
        msg:
            "${ResponseParseStatusCodeEnum.dynamicFnExecuteFail.name}，请修改自定义的方法：$e",
      );
    }
  }

  /// 列表执行js方法
  PageModel<T> listEvaluateJsFunction(dynamic data, NetApiModel netApi) {
    if (JsExecuteUtils.flutterJs == null) {
      JsExecuteUtils.applyGetFlutterJavascriptRuntime();
    }
    if (JsExecuteUtils.flutterJs == null) {
      return PageModel<T>(
        page: 0,
        pageSize: 0,
        totalPage: 0,
        totalCount: 0,
        isEnd: true,
        statusCode:
            ResponseParseStatusCodeEnum.dynamicRuntimeEnvironmentApplyFail.code,
        msg:
            ResponseParseStatusCodeEnum.dynamicRuntimeEnvironmentApplyFail.name,
      );
    }

    /// 编译js方法
    try {
      JsExecuteUtils.flutterJs!.evaluate(
        netApi.responseParams.resultConvertDyFn!.fn,
      );
    } catch (e) {
      return PageModel<T>(
        page: 0,
        pageSize: 0,
        totalPage: 0,
        totalCount: 0,
        isEnd: true,
        statusCode: ResponseParseStatusCodeEnum.dynamicFnEvaluateFail.code,
        msg: "${ResponseParseStatusCodeEnum.dynamicFnEvaluateFail.name}，$e",
      );
    }

    // 将Map转换为JSON字符串
    String jsonString = json.encode(data);

    /// 拼接js执行方法
    String jsFnStr = 'convertJson(JSON.parse(\'$jsonString\'))';
    JsEvalResult? complexResult;
    try {
      /// 执行js方法
      complexResult = JsExecuteUtils.flutterJs!.evaluate(jsFnStr);
    } catch (e) {
      return PageModel<T>(
        page: 0,
        pageSize: 0,
        totalPage: 0,
        totalCount: 0,
        isEnd: true,
        statusCode: ResponseParseStatusCodeEnum.dynamicFnExecuteFail.code,
        msg: "${ResponseParseStatusCodeEnum.dynamicFnExecuteFail.name}原因，$e",
      );
    }

    Map<String, dynamic>? result;
    dynamic rawResult;
    try {
      rawResult = complexResult.rawResult;
      if (rawResult != null) {
        result = {};
        if (rawResult is Map<String, dynamic>) {
          result = rawResult;
        } else if (rawResult is Map<dynamic, dynamic>) {
          for (var entry in rawResult.entries) {
            result[entry.key.toString()] = entry.value;
          }
        }
      }
    } catch (e) {
      return PageModel<T>(
        page: 0,
        pageSize: 0,
        totalPage: 0,
        totalCount: 0,
        isEnd: true,
        statusCode: ResponseParseStatusCodeEnum.dynamicFnResultIsWrong.code,
        msg:
            "${ResponseParseStatusCodeEnum.dynamicFnResultIsWrong.name}，需要返回的是Map<String, dynamic>，实际返回${rawResult?.runtimeType}，请修改自定义的js方法",
      );
    }

    return parseResponseToPageModel(result ?? {}, netApi.responseParams);
  }

  /// 解析单个内容
  @override
  DefaultResponseModel<T> detailParse(dynamic data, NetApiModel netApi) {
    if (data == null) {
      DefaultResponseModel<T>(
        statusCode: ResponseParseStatusCodeEnum.dataNull.code,
        msg: ResponseParseStatusCodeEnum.dataNull.name,
      );
    }
    // 如果有定义动态方法就需要先执行动态方法
    if (netApi.responseParams.resultConvertDyFn != null) {
      return detailEvaluateDynamicFunction(data, netApi);
    }
    Map<String, dynamic> dataMap = {};
    try {
      dataMap = DataTypeConvertUtils.toMapStrDyMap(data);
    } catch (e) {
      return DefaultResponseModel<T>(
        statusCode: ResponseParseStatusCodeEnum.parseFail.code,
        msg:
            "${ResponseParseStatusCodeEnum.parseFail.name}，返回的数据不是有效的Map<dynamic, dynamic>或Map<String, dynamic>格式，请自定义js方法转换",
      );
    }

    Map<String, dynamic> handleDataMap = convertTargetJsonSingle(
      dataMap,
      netApi.responseParams,
    );
    return parseResponseToResponseModel(handleDataMap, netApi.responseParams);
  }

  /// 执行动态方法
  DefaultResponseModel<T> detailEvaluateDynamicFunction(
    Map<String, dynamic> data,
    NetApiModel netApi,
  ) {
    if (netApi.responseParams.resultConvertDyFn == null) {
      return DefaultResponseModel<T>(
        statusCode: ResponseParseStatusCodeEnum.dynamicFnNull.code,
        msg: ResponseParseStatusCodeEnum.dynamicFnNull.name,
      );
    }
    if (netApi.responseParams.resultConvertDyFn!.dynamicFunctionEnum ==
        DynamicFunctionEnum.js) {
      // 动态方法时js脚本
      return detailEvaluateJsFunction(data, netApi);
    }

    return DefaultResponseModel<T>(
      statusCode: ResponseParseStatusCodeEnum.dynamicFnNull.code,
      msg: ResponseParseStatusCodeEnum.dynamicFnNull.name,
    );
  }

  /// 执行Eval方法
  DefaultResponseModel<T> detailEvaluateEvalFunction(
    Map<String, dynamic> data,
    NetApiModel netApi,
  ) {
    Map<String, dynamic> dataMap = {};
    try {
      dataMap = DataTypeConvertUtils.toMapStrDyMap(data);
    } catch (e) {
      return DefaultResponseModel<T>(
        statusCode: ResponseParseStatusCodeEnum.evalNotAllowDataType.code,
        msg:
            "${ResponseParseStatusCodeEnum.evalNotAllowDataType.name}，当前数据类型转换失败：$e",
      );
    }

    try {
      Map<String, dynamic> result = eval(
        netApi.responseParams.resultConvertDyFn!.fn,
        function: netApi.responseParams.resultConvertDyFn!.fnName ?? "main",
        args: [$Object(dataMap)],
      );
      return parseResponseToResponseModel(result, netApi.responseParams);
    } catch (e) {
      return DefaultResponseModel<T>(
        statusCode: ResponseParseStatusCodeEnum.dynamicFnExecuteFail.code,
        msg:
            "${ResponseParseStatusCodeEnum.dynamicFnExecuteFail.name}，请修改自定义的方法：$e",
      );
    }
  }

  /// 执行js方法
  DefaultResponseModel<T> detailEvaluateJsFunction(
    Map<String, dynamic> data,
    NetApiModel netApi,
  ) {
    if (JsExecuteUtils.flutterJs == null) {
      JsExecuteUtils.applyGetFlutterJavascriptRuntime();
    }
    if (JsExecuteUtils.flutterJs == null) {
      return DefaultResponseModel<T>(
        statusCode:
            ResponseParseStatusCodeEnum.dynamicRuntimeEnvironmentApplyFail.code,
        msg:
            ResponseParseStatusCodeEnum.dynamicRuntimeEnvironmentApplyFail.name,
      );
    }

    /// 编译js方法
    try {
      JsExecuteUtils.flutterJs!.evaluate(
        netApi.responseParams.resultConvertDyFn!.fn,
      );
    } catch (e) {
      return DefaultResponseModel<T>(
        statusCode: ResponseParseStatusCodeEnum.dynamicFnEvaluateFail.code,
        msg: "${ResponseParseStatusCodeEnum.dynamicFnEvaluateFail.name}，$e",
      );
    }

    // 将Map转换为JSON字符串
    String jsonString = json.encode(data);

    /// 拼接js执行方法
    String jsFnStr = 'convertJson(JSON.parse(\'$jsonString\'))';
    JsEvalResult? complexResult;
    try {
      /// 执行js方法
      complexResult = JsExecuteUtils.flutterJs!.evaluate(jsFnStr);
    } catch (e) {
      return DefaultResponseModel<T>(
        statusCode: ResponseParseStatusCodeEnum.dynamicFnExecuteFail.code,
        msg: "${ResponseParseStatusCodeEnum.dynamicFnExecuteFail.name}原因，$e",
      );
    }

    Map<String, dynamic>? result;
    dynamic rawResult;
    try {
      rawResult = complexResult.rawResult;
      if (rawResult != null) {
        result = {};
        if (rawResult is Map<String, dynamic>) {
          result = rawResult;
        } else if (rawResult is Map<dynamic, dynamic>) {
          for (var entry in rawResult.entries) {
            result[entry.key.toString()] = entry.value;
          }
        }
      }
    } catch (e) {
      return DefaultResponseModel<T>(
        statusCode: ResponseParseStatusCodeEnum.dynamicFnResultIsWrong.code,
        msg:
            "${ResponseParseStatusCodeEnum.dynamicFnResultIsWrong.name}，需要返回的是Map<String, dynamic>，实际返回${rawResult?.runtimeType}，请修改自定义的js方法",
      );
    }
    return parseResponseToResponseModel(result ?? {}, netApi.responseParams);
  }

  /// 转换生成单个目标json
  /// 结果为单个json
  Map<String, dynamic> convertTargetJsonSingle(
    Map<String, dynamic> map,
    ResponseParamsModel responseParamsModel,
  ) {
    String statusCodeKey = responseParamsModel.statusCodeKey;
    String statusCode = (map[statusCodeKey] ?? "").toString();
    String resDataKey = responseParamsModel.resDataKey;
    String resMsg = map[responseParamsModel.resMsgKey ?? "msg"] ?? "";
    Map<String, dynamic> resultMap = {"statusCode": statusCode, "msg": resMsg};
    var data = map[resDataKey];
    if (data != null) {
      Map<String, dynamic> dataMap = {};
      if (data is List) {
        dataMap = data[0];
      } else {
        dataMap = data;
      }
      if (responseParamsModel.resultKeyMap.isNotEmpty) {
        for (var entry in responseParamsModel.resultKeyMap.entries) {
          dataMap[entry.key] = dataMap[entry.value];
        }
        resultMap["data"] = dataMap;
      }
    }
    return resultMap;
  }

  /// 转换生成多个个目标json
  /// 结果为json列表
  /// 一般用于列表
  Map<String, dynamic> convertTargetJsonMultiple(
    Map<String, dynamic> map,
    ResponseParamsModel responseParamsModel,
  ) {
    Map<String, String> keyMap = responseParamsModel.resultKeyMap;
    String statusCodeKey = responseParamsModel.statusCodeKey;
    String statusCode = (map[statusCodeKey] ?? "").toString();
    String resDataKey = responseParamsModel.resDataKey;
    String resMsg = map[responseParamsModel.resMsgKey ?? "msg"] ?? "";
    List<dynamic> data = map[resDataKey] ?? [];
    Map<String, dynamic> resultMap = {
      "statusCode": statusCode,
      "msg": resMsg,
      "data": data,
    };
    List<String> pageKeyList = ["page", "pageSize", "totalPage", "totalCount"];
    for (String key in pageKeyList) {
      if (!keyMap.containsKey(key)) {
        continue;
      }
      resultMap[key] = map[keyMap[key]] ?? 0;
    }
    if (keyMap.isNotEmpty && data.isNotEmpty) {
      for (var entry in keyMap.entries) {
        if (pageKeyList.contains(entry.key)) {
          continue;
        }
        for (var item in resultMap['data']) {
          if (item != null && item is Map) {
            item[entry.key] = item[entry.value];
          }
        }
      }
    }

    return resultMap;
  }

  /// 读取结果为单个目标对象
  /// 一般用于详情
  DefaultResponseModel<T> parseResponseToResponseModel(
    Map<String, dynamic> map,
    ResponseParamsModel responseParamsModel,
  ) {
    String successStatusCode = responseParamsModel.successStatusCode;
    String statusCode = (map["statusCode"] ?? "").toString();
    String resMsg = (map["msg"] ?? "").toString();
    if (statusCode != successStatusCode) {
      return DefaultResponseModel<T>(
        statusCode: ResponseParseStatusCodeEnum.error.code,
        msg: resMsg.isEmpty ? ResponseParseStatusCodeEnum.error.name : resMsg,
      );
    }
    dynamic data = map["data"];
    if (data != null) {
      try {
        Map<String, dynamic> dataMap = {};
        if (data is Map<String, dynamic>) {
          dataMap = data;
        } else if (data is Map<dynamic, dynamic>) {
          for (var entry in data.entries) {
            dataMap[entry.key.toString()] = entry.value;
          }
        } else {
          throw Exception(
            "具体数据不是有效的Map<dynamic, dynamic>或Map<String, dynamic>格式",
          );
        }
        return DefaultResponseModel<T>(
          model: fromJson(data),
          statusCode: ResponseParseStatusCodeEnum.success.code,
          msg: ResponseParseStatusCodeEnum.success.name,
        );
      } catch (e) {
        return DefaultResponseModel<T>(
          statusCode: ResponseParseStatusCodeEnum.parseFail.code,
          msg: "${ResponseParseStatusCodeEnum.parseFail.name}，$e",
        );
      }
    }
    return DefaultResponseModel<T>(
      statusCode: ResponseParseStatusCodeEnum.dataNull.code,
      msg: ResponseParseStatusCodeEnum.dataNull.name,
    );
  }

  /// 读取响应结果为多个目标对象（PageModel对象）
  /// 一般用于列表
  PageModel<T> parseResponseToPageModel(
    Map<String, dynamic> map,
    ResponseParamsModel responseParamsModel,
  ) {
    String successStatusCode = responseParamsModel.successStatusCode;
    String statusCode = (map["statusCode"] ?? "").toString();
    String resMsg = (map["msg"] ?? "").toString();

    if (statusCode != successStatusCode) {
      return PageModel<T>(
        page: 0,
        pageSize: 0,
        totalPage: 0,
        totalCount: 0,
        isEnd: true,
        statusCode: ResponseParseStatusCodeEnum.error.code,
        msg: resMsg.isEmpty ? ResponseParseStatusCodeEnum.error.name : resMsg,
      );
    }
    int page = int.tryParse((map["page"] ?? 0).toString()) ?? 0;
    int pageSize = int.tryParse((map["pageSize"] ?? 0).toString()) ?? 0;
    int totalPage = int.tryParse((map["totalPage"] ?? 0).toString()) ?? 0;
    int totalCount = int.tryParse((map["totalCount"] ?? 0).toString()) ?? 0;
    List<dynamic>? mapDataList = map["data"];
    List<T> resourceList = [];
    if (mapDataList != null && mapDataList.isNotEmpty) {
      try {
        for (dynamic map in mapDataList) {
          Map<String, dynamic> dataMap = {};
          try {
            dataMap = DataTypeConvertUtils.toMapStrDyMap(map);
          } catch (e1) {
            throw Exception(
              "数据不是有效的List<Map<dynamic, dynamic>>或List<Map<String, dynamic>>格式，请自定义js方法转换：$e1",
            );
          }
          resourceList.add(fromJson(dataMap));
        }
      } catch (e) {
        return PageModel<T>(
          page: page,
          pageSize: pageSize,
          totalPage: totalPage,
          totalCount: totalCount,
          isEnd: true,
          statusCode: ResponseParseStatusCodeEnum.parseFail.code,
          msg: "${ResponseParseStatusCodeEnum.parseFail.name}，$e",
        );
      }
    } else {
      return PageModel<T>(
        page: page,
        pageSize: pageSize,
        totalPage: totalPage,
        totalCount: totalCount,
        isEnd: true,
        modelList: null,
        statusCode: ResponseParseStatusCodeEnum.dataNull.code,
        msg: ResponseParseStatusCodeEnum.dataNull.name,
      );
    }
    return PageModel<T>(
      page: page,
      pageSize: pageSize,
      totalPage: totalPage,
      totalCount: totalCount,
      isEnd: page >= totalPage,
      modelList: resourceList,
      statusCode: ResponseParseStatusCodeEnum.success.code,
      msg: ResponseParseStatusCodeEnum.success.name,
    );
  }
}
