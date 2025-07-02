import '../models/api_key_desc_model.dart';
import '../models/validate_field_model.dart';
import '../models/validate_result_model.dart';
import 'data_type_convert_utils.dart';
import 'model_validate_factory_utils.dart';

class ModelValidateFieldResult<T> {
  final T? model;
  final List<String>? errorList;

  ModelValidateFieldResult({this.model, this.errorList});
}

class JsonToModelUtils {
  static ValidateResultModel baseValidate<T>(
    Map<String, dynamic> map, {
    required String key,
    required T Function(Map<String, dynamic>) fromJson,
    required ValidateResultModel Function(Map<String, dynamic>) validateFieldFn,
  }) {
    if (ModelValidateFactoryUtils.isRegisterFactory<T>()) {
      ModelValidateFactoryUtils.register<T>(
        validator: validateFieldFn,
        factory: fromJson,
      );
    }
    if (ModelValidateFactoryUtils.isRegisterValidator<T>()) {
      ModelValidateFactoryUtils.registerValidator<T>(validateFieldFn);
    }
    ValidateResultModel validateResult = ValidateResultModel(
      key: key,
      msgMap: {},
      childValidateResultMap: {},
    );
    if (map.isEmpty) {
      validateResult.msgMap["json"] = "接收传入的json数据为空";
      validateResult.flag = false;
      return validateResult;
    }
    return validateResult;
  }

  static void validateModelJson<T>(
    Map<String, dynamic> map, {
    required ValidateResultModel validateResult,
    required List<ValidateFieldModel> validateFieldList,
  }) {
    for (var validateFieldItem in validateFieldList) {
      switch (validateFieldItem.fieldType) {
        case "class":
          validateFieldClass(
            map,
            apiKeyDescModel: validateFieldItem.fieldDesc,
            validateResult: validateResult,
            fromJson: validateFieldItem.fromJson!,
            validateFieldFn: validateFieldItem.validateField!,
          );
          break;
        case "classList":
          validateFieldClassList(
            map,
            apiKeyDescModel: validateFieldItem.fieldDesc,
            validateResult: validateResult,
            fromJson: validateFieldItem.fromJson!,
            validateFieldFn: validateFieldItem.validateField!,
          );
          break;
        case "mapStrToClass":
          validateFieldMapStrToClass(
            map,
            apiKeyDescModel: validateFieldItem.fieldDesc,
            validateResult: validateResult,
            fromJson: validateFieldItem.fromJson!,
            validateFieldFn: validateFieldItem.validateField!,
          );
          break;
        case "mapStrToDy":
          validateFieldMapStrToDy(
            map,
            apiKeyDescModel: validateFieldItem.fieldDesc,
            validateResult: validateResult,
          );
          break;
        case "string":
          validateFieldStr(
            map,
            apiKeyDescModel: validateFieldItem.fieldDesc,
            validateResult: validateResult,
          );
          break;
        default:
          break;
      }
    }
    if (validateResult.flag) {
      validateResult.flag = validateResult.msgMap.isEmpty;
    }
  }

  /// 验证model的字段（字符串类型的字段）
  static void validateFieldStr(
    Map<String, dynamic> map, {
    required ApiKeyDescModel apiKeyDescModel,
    required ValidateResultModel validateResult,
  }) {
    JsonToModelUtils.validateField(
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
    JsonToModelUtils.validateField(
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

  // 验证对象
  static void validateFieldClass(
    Map<String, dynamic> map, {
    required ApiKeyDescModel apiKeyDescModel,
    required ValidateResultModel validateResult,
    required Function(Map<String, dynamic>) fromJson,
    required ValidateResultModel Function(Map<String, dynamic>) validateFieldFn,
  }) {
    return validateField(
      map,
      apiKeyDescModel: apiKeyDescModel,
      validateResult: validateResult,
      converter: (value) {
        Map<String, dynamic> dataMap = {};
        if (value is Map<String, dynamic>) {
          dataMap.addAll(value);
        } else {
          try {
            dataMap.addAll(DataTypeConvertUtils.toMapStrDyMap(value));
          } catch (e) {
            validateResult.msgMap[apiKeyDescModel.key] =
                "${apiKeyDescModel.desc}（${apiKeyDescModel.key}）转换数据时报错：$e";
            return false;
          }
        }
        if (dataMap.isEmpty) {
          validateResult.msgMap[apiKeyDescModel.key] =
              "${apiKeyDescModel.desc}（${apiKeyDescModel.key}）从json中获取到的数据不是有效的格式";
          return false;
        }
        var result = validateFieldFn(dataMap);
        validateResult.childValidateResultMap[apiKeyDescModel.key] = {
          apiKeyDescModel.key: result,
        };
        return result.flag;
      },
    );
  }

  // 验证对象
  static void validateFieldClassList(
    Map<String, dynamic> map, {
    required ApiKeyDescModel apiKeyDescModel,
    required ValidateResultModel validateResult,
    required Function(Map<String, dynamic>) fromJson,
    required ValidateResultModel Function(Map<String, dynamic>) validateFieldFn,
  }) {
    return validateField(
      map,
      apiKeyDescModel: apiKeyDescModel,
      validateResult: validateResult,
      converter: (value) {
        Map<String, ValidateResultModel> resultMap = {};
        bool flag = true;
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
            validateResult.msgMap[apiKeyDescModel.key] =
                "${apiKeyDescModel.desc}（${apiKeyDescModel.key}）数据转换时报错：$e";
            return false;
          }
        }

        for (int i = 0; i < list.length; i++) {
          var item = list[i];
          ValidateResultModel result = validateFieldFn(item);
          resultMap[i.toString()] = result;
          if (!result.flag) {
            flag = false;
          }
        }
        validateResult.childValidateResultMap[apiKeyDescModel.key] = resultMap;
        return flag;
      },
    );
  }

  // 验证Map对象
  static void validateFieldMapStrToClass(
    Map<String, dynamic> map, {
    required ApiKeyDescModel apiKeyDescModel,
    required ValidateResultModel validateResult,
    required Function(Map<String, dynamic>) fromJson,
    required ValidateResultModel Function(Map<String, dynamic>) validateFieldFn,
  }) {
    return validateField(
      map,
      apiKeyDescModel: apiKeyDescModel,
      validateResult: validateResult,
      converter: (value) {
        bool flag = true;
        Map<String, ValidateResultModel> resultMap = {};
        if (value is Map<String, Map<String, dynamic>>) {
          for (var entry in value.entries) {
            ValidateResultModel result = validateFieldFn(entry.value);
            resultMap[entry.key] = result;
            if (!result.flag) {
              flag = false;
            }
          }
          validateResult.childValidateResultMap[apiKeyDescModel.key] =
              resultMap;
          return flag;
        } else if (value is Map<dynamic, dynamic> ||
            value is Map<String, dynamic>) {
          for (var entry in value.entries) {
            Map<String, dynamic> dataMap = {};
            if (entry.value is Map<String, dynamic>) {
              dataMap.addAll(entry.value);
            } else {
              // 尝试转换类型
              try {
                dataMap.addAll(DataTypeConvertUtils.toMapStrDyMap(entry.value));
              } catch (e) {
                flag = false;
                validateResult.msgMap[apiKeyDescModel.key] =
                    "${apiKeyDescModel.desc}（${apiKeyDescModel.key}）数据转换时报错：$e";
                return false;
              }
            }
            ValidateResultModel result = validateFieldFn(dataMap);
            resultMap[entry.key] = result;
            if (!result.flag) {
              flag = false;
            }
          }
          validateResult.childValidateResultMap[apiKeyDescModel.key] =
              resultMap;
          return flag;
        }

        validateResult.msgMap[apiKeyDescModel.key] =
            "${apiKeyDescModel.desc}（${apiKeyDescModel.key}）从json中获取到的数据不是有效的格式";
        return false;
      },
    );
  }

  // 验证Map对象
  static void validateFieldMapStrToDy(
    Map<String, dynamic> map, {
    required ApiKeyDescModel apiKeyDescModel,
    required ValidateResultModel validateResult,
  }) {
    return validateField(
      map,
      apiKeyDescModel: apiKeyDescModel,
      validateResult: validateResult,
      converter: (value) {
        if (value is Map<String, dynamic>) {
          return true;
        }
        // 尝试转换类型
        try {
          DataTypeConvertUtils.toMapStrDyMap(value);
        } catch (e) {
          validateResult.msgMap[apiKeyDescModel.key] =
              "${apiKeyDescModel.desc}（${apiKeyDescModel.key}）数据转换时报错：$e";
          return false;
        }
        return true;
      },
    );
  }

  /// 验证model的字段
  static void validateField(
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
    // if (apiKeyDescModel.isRequired &&
    //     (value == null || value.toString().isEmpty)) {
    if (apiKeyDescModel.isRequired && value == null) {
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
