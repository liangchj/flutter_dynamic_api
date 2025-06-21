import '../models/api_key_desc_model.dart';
import '../models/validate_result_model.dart';

class ModelValidateFieldResult<T> {
  final T? model;
  final List<String>? errorList;

  ModelValidateFieldResult({this.model, this.errorList});
}

class JsonToModelUtils {
  /// 验证model的字段（字符串类型的字段）
  static void validateFieldStr(
    Map<String, dynamic> map, {
    required ApiKeyDescModel apiKeyDescModel,
    required ValidateResultModel validateResult,
  }) {
    JsonToModelUtils.validateField<String?>(
      map,
      apiKeyDescModel: apiKeyDescModel,
      validateResult: validateResult,
      converter: (value) {
        if (value is String) {
          return true;
        }
        if (value != null) {
          try {
            value.toString();
            return true;
          } catch (e) {
            return false;
          }
        }
        validateResult.msgMap[apiKeyDescModel.key] =
            "${apiKeyDescModel.desc}（${apiKeyDescModel.key}）从json中获取到的数据不是有效的格式";
        return false;
      },
    );
  }

  /// 验证model的字段（bool类型的字段）
  static void validateFieldBool(
    Map<String, dynamic> map, {
    required ApiKeyDescModel apiKeyDescModel,
    required ValidateResultModel validateResult,
  }) {
    JsonToModelUtils.validateField<bool?>(
      map,
      apiKeyDescModel: apiKeyDescModel,
      validateResult: validateResult,
      converter: (value) {
        if (value is bool) return true;
        if (value != null) {
          bool? flag = bool.tryParse(value);
          if (flag != null) {
            return true;
          }
        }
        validateResult.msgMap[apiKeyDescModel.key] =
            "${apiKeyDescModel.desc}（${apiKeyDescModel.key}）从json中获取到的数据不是有效的格式";
        return false;
      },
    );
  }

  /// 验证model的字段
  static void validateField<T>(
    Map<String, dynamic> map, {
    required ApiKeyDescModel apiKeyDescModel,
    bool Function(dynamic)? converter,
    required ValidateResultModel validateResult,
  }) {
    // 检查字段是否存在
    if (!map.containsKey(apiKeyDescModel.key)) {
      if (apiKeyDescModel.isRequired) {
        validateResult.msgMap[apiKeyDescModel.key] =
            "${apiKeyDescModel.desc}（${apiKeyDescModel.key}）缺失";
      }
      return;
    }
    final value = map[apiKeyDescModel.key];
    // 验证必填
    if (apiKeyDescModel.isRequired &&
        (value == null || value.toString().isEmpty)) {
      validateResult.msgMap[apiKeyDescModel.key] =
          "${apiKeyDescModel.desc}（${apiKeyDescModel.key}）为必填项，json中获取到为空";
      return;
    }
    if (converter == null) {
      return;
    }
    // 尝试类型转换
    try {
      var flag = converter(value);
      if (!flag) {
        validateResult.flag = false;
      }
      // 其他业务验证（可选）
    } catch (e) {
      validateResult.msgMap[apiKeyDescModel.key] =
          "${apiKeyDescModel.desc}（${apiKeyDescModel.key}）类型转换报错：$e";
      return;
    }
  }

  static Map<String, T>? getMapStrToTFromJson<T>(
    Map<String, dynamic> map,
    String key,
  ) {
    Map<String, T>? data;
    var value = map[key];
    if (value != null) {
      if (value is Map<String, T>) {
        data = value;
      } else if (value is Map) {
        data = {};
        for (var entry in value.entries) {
          data[entry.key.toString()] = entry.value;
        }
      }
    }
    return data;
  }

  static String getValidateResultMsg(ValidateResultModel validateResult) {
    List<String> errorList = [];
    for (var entry in validateResult.msgMap.entries) {
      errorList.add("[${entry.key}]：${entry.value}");
    }
    if (validateResult.childValidateResultMap.isNotEmpty) {
      for (var entry in validateResult.childValidateResultMap.entries) {
        List<String> list = [];
        for (var item in entry.value.entries) {
          var msg = getValidateResultMsg(item.value);
          if (msg.isNotEmpty) {
            list.add("里面具体项[${item.key}]：$msg");
          }
        }
        if (list.isNotEmpty) {
          errorList.add("具体内容[${entry.key}]，${list.join("\n")}");
        }
      }
    }
    return errorList.join("\n");
  }
}
