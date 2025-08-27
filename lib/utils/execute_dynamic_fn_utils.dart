import 'dart:convert';

import 'package:flutter_js/flutter_js.dart';

import '../enums/response_parse_status_code_common.dart';
import '../models/dynamic_function_model.dart';
import 'js_execute_utils.dart';

// 执行动态方法
class ExecuteDynamicFnUtils {
  // 执行 将结果写入到缓存中的动态方法
  // 使用webview时请自行实现
  static Map<String, dynamic> executeRecordCacheDyFn(
    DynamicFunctionModel dynamicFunction,
    dynamic data,
  ) {
    Map<String, dynamic> result = {};
    if (data.isEmpty) {
      return result;
    }

    if (JsExecuteUtils.flutterJs == null) {
      JsExecuteUtils.applyGetFlutterJavascriptRuntime();
    }
    if (JsExecuteUtils.flutterJs == null) {
      throw Exception(
        ResponseParseStatusCodeEnum.dynamicRuntimeEnvironmentApplyFail.name,
      );
    }

    /// 编译js方法
    try {
      JsExecuteUtils.flutterJs!.evaluate(dynamicFunction.fn);
    } catch (e) {
      throw Exception(
        "${ResponseParseStatusCodeEnum.dynamicFnEvaluateFail.name}，$e",
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
      throw Exception(
        "${ResponseParseStatusCodeEnum.dynamicFnExecuteFail.name}原因，$e",
      );
    }

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
      throw Exception(
        "${ResponseParseStatusCodeEnum.dynamicFnResultIsWrong.name}，需要返回的是Map<String, dynamic>，实际返回${rawResult?.runtimeType}，请修改自定义的js方法",
      );
    }
    return result;
  }
}
