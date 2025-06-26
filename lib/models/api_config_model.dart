import 'package:flutter_dynamic_api/models/validate_result_model.dart';

import '../utils/data_type_convert_utils.dart';
import '../utils/json_to_model_utils.dart';
import '../utils/model_validate_factory_utils.dart';
import 'api_base_model.dart';
import 'api_key_desc_model.dart';
import 'net_api_model.dart';

/// api配置
class ApiConfigModel {
  /// 基本信息
  final ApiBaseModel apiBaseModel;

  /// 具体请求的api配置
  final Map<String, NetApiModel> netApiMap;

  ApiConfigModel({required this.apiBaseModel, required this.netApiMap});

  factory ApiConfigModel.fromJson(Map<String, dynamic> map) {
    ValidateResultModel validateResult = ApiConfigModel.validateField(map);
    if (validateResult.msgMap.isNotEmpty) {
      throw Exception(validateResult.msgMap);
    }
    List<String> errorList = [];
    var apiBaseModelVar = map["apiBaseModel"];
    Map<String, dynamic> apiBaseMap = {};
    if (apiBaseModelVar != null) {
      try {
        apiBaseMap.addAll(DataTypeConvertUtils.toMapStrDyMap(apiBaseModelVar));
      } catch (e) {
        errorList.add("读取配置apiBaseModel转换类型时报错：$e");
      }
    }

    var netApiMap = map["netApiMap"];
    Map<String, NetApiModel> netApiModelMap = {};
    if (netApiMap != null) {
      try {
        Map<String, Map<String, dynamic>> dataMap =
            DataTypeConvertUtils.toMapStrMapStrDyMap(netApiMap);
        for (var entry in dataMap.entries) {
          var netApiModel = NetApiModel.fromJson(entry.value);
          netApiModelMap[entry.key] = netApiModel;
        }
      } catch (e) {
        errorList.add("读取配置netApiMap转换类型时报错：$e");
      }
    }
    if (errorList.isNotEmpty) {
      throw Exception(errorList.join("\n"));
    }
    return ApiConfigModel(
      apiBaseModel: ApiBaseModel.fromJson(apiBaseMap),
      netApiMap: netApiModelMap,
    );
  }

  Map<String, dynamic> toJson() {
    String netApiMapToStr = "";
    for (var entry in netApiMap.entries) {
      netApiMapToStr += '"${entry.key}": ${entry.value.toJson()}';
    }
    return {"apiBaseModel": apiBaseModel.toJson(), "netApiMap": netApiMapToStr};
  }

  // 验证方法
  static ValidateResultModel validateField(Map<String, dynamic> map) {
    if (ModelValidateFactoryUtils.isRegisterFactory<ApiConfigModel>()) {
      ModelValidateFactoryUtils.register<ApiConfigModel>(
        validator: ApiConfigModel.validateField,
        factory: ApiConfigModel.fromJson,
      );
    }
    if (ModelValidateFactoryUtils.isRegisterValidator<ApiConfigModel>()) {
      ModelValidateFactoryUtils.registerValidator<ApiConfigModel>(
        ApiConfigModel.validateField,
      );
    }
    ValidateResultModel validateResult = ValidateResultModel(
      key: "apiConfig",
      msgMap: {},
      childValidateResultMap: {},
    );
    if (map.isEmpty) {
      validateResult.msgMap["json"] = "接收传入的json数据为空";
      validateResult.flag = false;
      return validateResult;
    }

    /// 验证api基本信息字段
    JsonToModelUtils.validateField<ApiBaseModel>(
      map,
      apiKeyDescModel: apiBaseModelField,
      validateResult: validateResult,
      converter: (value) =>
          apiBaseFieldTypeValidateAndConvert(value, validateResult),
    );

    /// 验证网络api字段
    JsonToModelUtils.validateField<Map<String, NetApiModel>>(
      map,
      apiKeyDescModel: netApiMapField,
      validateResult: validateResult,
      converter: (value) =>
          netApiFieldTypeValidateAndConvert(value, validateResult),
    );

    if (validateResult.flag) {
      validateResult.flag = validateResult.msgMap.isEmpty;
    }
    return validateResult;
  }

  /// 网络api字段数据类型转换验证
  static bool netApiFieldTypeValidateAndConvert(
    value,
    ValidateResultModel validateResult,
  ) {
    bool flag = true;
    Map<String, ValidateResultModel> netApiResultMap = {};
    if (value is Map<String, NetApiModel>) {
      return true;
    }
    if (value is Map<String, Map<String, dynamic>>) {
      for (var entry in value.entries) {
        var result = NetApiModel.validateField(entry.value);
        netApiResultMap[entry.key] = result;
        if (!result.flag) {
          flag = false;
        }
      }
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
            validateResult.msgMap[netApiMapField.key] =
                "${netApiMapField.desc}（${netApiMapField.key}）数据转换时报错：$e";
            return false;
          }
        }
        var result = NetApiModel.validateField(dataMap);
        netApiResultMap[entry.key] = result;
        if (!result.flag) {
          flag = false;
        }
      }
      validateResult.childValidateResultMap[netApiMapField.key] =
          netApiResultMap;
      return flag;
    }

    validateResult.msgMap[apiBaseModelField.key] =
        "${apiBaseModelField.desc}（${apiBaseModelField.key}）从json中获取到的数据不是有效的格式";
    return false;
  }

  /// api基本信息字段数据类型转换验证
  static bool apiBaseFieldTypeValidateAndConvert(
    value,
    ValidateResultModel validateResult,
  ) {
    Map<String, dynamic> dataMap = {};
    if (value is ApiBaseModel) {
      dataMap = value.toJson();
    } else if (value is Map<String, dynamic>) {
      dataMap.addAll(value);
    } else {
      try {
        dataMap.addAll(DataTypeConvertUtils.toMapStrDyMap(value));
      } catch (e) {
        validateResult.msgMap[apiBaseModelField.key] =
            "${apiBaseModelField.desc}（${apiBaseModelField.key}）转换数据时报错：$e";
        return false;
      }
    }
    if (dataMap.isEmpty) {
      validateResult.msgMap[apiBaseModelField.key] =
          "${apiBaseModelField.desc}（${apiBaseModelField.key}）从json中获取到的数据不是有效的格式";
      return false;
    }
    var result = ApiBaseModel.validateField(dataMap);
    validateResult.childValidateResultMap[apiBaseModelField.key] = {
      apiBaseModelField.key: result,
    };
    return result.flag;
  }

  static final ApiKeyDescModel apiBaseModelField = ApiKeyDescModel(
    key: "apiBaseModel",
    desc: "api基本信息",
    isRequired: true,
  );
  static final ApiKeyDescModel netApiMapField = ApiKeyDescModel(
    key: "netApiMap",
    desc: "具体请求的api配置",
    isRequired: true,
  );
}
