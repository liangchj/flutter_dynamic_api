import 'dart:convert';
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
  @override
  PageModel<T> listDataParseFromJson(
    Map<String, dynamic> map,
    NetApiModel netApiModel,
  ) {
    Map<String, dynamic> dataMap = convertTargetJsonMultiple(
      map,
      netApiModel.responseParams,
    );
    return parseResponseToPageModel(dataMap, netApiModel.responseParams);
  }

  @override
  PageModel<T> listParseFromDynamic(dynamic data, NetApiModel netApiModel) {
    Map<String, dynamic> dataMap = {};
    if (data == null) {
      return PageModel<T>(
        page: 0,
        pageSize: 0,
        totalPage: 0,
        totalCount: 0,
        modelList: null,
        statusCode: ResponseParseStatusCodeEnum.dataNull.code,
        msg: ResponseParseStatusCodeEnum.dataNull.name,
      );
    }
    if (data is Map<dynamic, dynamic>) {
      for (var entry in data.entries) {
        dataMap[entry.key.toString()] = entry.value;
      }
    } else if (data is Map<String, dynamic>) {
      dataMap.addAll(data);
    } else {
      return PageModel<T>(
        page: 0,
        pageSize: 0,
        totalPage: 0,
        totalCount: 0,
        statusCode: ResponseParseStatusCodeEnum.parseFail.code,
        msg:
            "${ResponseParseStatusCodeEnum.parseFail.name}，返回的数据不是有效的Map<dynamic, dynamic>或Map<String, dynamic>格式，请自定义js方法转换",
      );
    }
    return listDataParseFromJson(dataMap, netApiModel);
  }

  /// 解析列表内容
  /// 未设置设置了key-value读取数据，使用自定义的Js方法解析
  /// 结果是json
  @override
  PageModel<T> listDataParseFromJsonAndJsFn(
    Map<String, dynamic> map,
    NetApiModel netApiModel,
  ) {
    return listParseFromDynamicAndJsFn(map, netApiModel);
  }

  /// 解析列表
  /// 未设置设置了key-value读取数据，使用自定义的Js方法解析
  /// 结果未知
  @override
  PageModel<T> listParseFromDynamicAndJsFn(
    dynamic data,
    NetApiModel netApiModel,
  ) {
    if (data == null) {
      return PageModel<T>(
        page: 0,
        pageSize: 0,
        totalPage: 0,
        totalCount: 0,
        modelList: null,
        statusCode: ResponseParseStatusCodeEnum.dataNull.code,
        msg: ResponseParseStatusCodeEnum.dataNull.name,
      );
    }
    if (netApiModel.responseParams.resultConvertJsFn == null ||
        netApiModel.responseParams.resultConvertJsFn!.isEmpty) {
      return PageModel<T>(
        page: 0,
        pageSize: 0,
        totalPage: 0,
        totalCount: 0,
        statusCode: ResponseParseStatusCodeEnum.jsFnNull.code,
        msg: ResponseParseStatusCodeEnum.jsFnNull.name,
      );
    }
    if (JsExecuteUtils.flutterJs == null) {
      JsExecuteUtils.applyGetFlutterJavascriptRuntime();
    }
    if (JsExecuteUtils.flutterJs == null) {
      return PageModel<T>(
        page: 0,
        pageSize: 0,
        totalPage: 0,
        totalCount: 0,
        statusCode:
            ResponseParseStatusCodeEnum.jsRuntimeEnvironmentApplyFail.code,
        msg: ResponseParseStatusCodeEnum.jsRuntimeEnvironmentApplyFail.name,
      );
    }

    /// 编译js方法
    try {
      JsExecuteUtils.flutterJs!.evaluate(
        netApiModel.responseParams.resultConvertJsFn!,
      );
    } catch (e) {
      return PageModel<T>(
        page: 0,
        pageSize: 0,
        totalPage: 0,
        totalCount: 0,
        statusCode: ResponseParseStatusCodeEnum.jsFnEvaluateFail.code,
        msg: "${ResponseParseStatusCodeEnum.jsFnEvaluateFail.name}，$e",
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
        statusCode: ResponseParseStatusCodeEnum.jsFnExecuteFail.code,
        msg: "${ResponseParseStatusCodeEnum.jsFnExecuteFail.name}原因，$e",
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
        statusCode: ResponseParseStatusCodeEnum.jsFnResultIsWrong.code,
        msg:
            "${ResponseParseStatusCodeEnum.jsFnResultIsWrong.name}，需要返回的是Map<String, dynamic>，实际返回${rawResult?.runtimeType}，请修改自定义的js方法",
      );
    }

    return parseResponseToPageModel(result ?? {}, netApiModel.responseParams);
  }

  @override
  DefaultResponseModel<T> detailParseFromJson(
    Map<String, dynamic> map,
    NetApiModel netApiModel,
  ) {
    Map<String, dynamic> dataMap = convertTargetJsonSingle(
      map,
      netApiModel.responseParams,
    );
    return parseResponseToResponseModel(dataMap, netApiModel.responseParams);
  }

  @override
  DefaultResponseModel<T> detailParseFromDynamic(
    dynamic data,
    NetApiModel netApiModel,
  ) {
    Map<String, dynamic> dataMap = {};
    if (data == null) {
      return DefaultResponseModel<T>(
        statusCode: ResponseParseStatusCodeEnum.dataNull.code,
        msg: ResponseParseStatusCodeEnum.dataNull.name,
      );
    }
    if (data is Map<dynamic, dynamic>) {
      for (var entry in data.entries) {
        dataMap[entry.key.toString()] = entry.value;
      }
    } else if (data is Map<String, dynamic>) {
      dataMap.addAll(data);
    } else {
      return DefaultResponseModel<T>(
        statusCode: ResponseParseStatusCodeEnum.parseFail.code,
        msg:
            "${ResponseParseStatusCodeEnum.parseFail.name}，返回的数据不是有效的Map<dynamic, dynamic>或Map<String, dynamic>格式，请自定义js方法转换",
      );
    }

    return detailParseFromJson(dataMap, netApiModel);
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
      modelList: resourceList,
      statusCode: ResponseParseStatusCodeEnum.success.code,
      msg: ResponseParseStatusCodeEnum.success.name,
    );
  }
}
