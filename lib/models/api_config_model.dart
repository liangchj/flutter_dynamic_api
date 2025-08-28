import '../utils/data_type_convert_utils.dart';
import '../utils/json_to_model_utils.dart';
import 'api_base_model.dart';
import 'api_key_desc_model.dart';
import 'net_api_model.dart';
import 'validate_field_model.dart';
import 'validate_result_model.dart';

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
    Map<String, Map<String, dynamic>> netApiMapToJson = {};
    for (var entry in netApiMap.entries) {
      netApiMapToJson[entry.key] = entry.value.toJson();
    }
    return {
      "apiBaseModel": apiBaseModel.toJson(),
      "netApiMap": netApiMapToJson,
    };
  }

  // 验证方法
  static ValidateResultModel validateField(Map<String, dynamic> map) {
    ValidateResultModel validateResult =
        JsonToModelUtils.baseValidate<ApiConfigModel>(
          map,
          key: "apiConfig",
          fromJson: ApiConfigModel.fromJson,
          validateFieldFn: ApiConfigModel.validateField,
        );
    if (!validateResult.flag) {
      return validateResult;
    }

    JsonToModelUtils.validateModelJson(
      map,
      validateResult: validateResult,
      validateFieldList: [
        ValidateFieldModel<ApiBaseModel>(
          fieldDesc: ApiKeyDescModel(
            key: "apiBaseModel",
            desc: "api基本信息",
            isRequired: true,
          ),
          fieldType: "class",
          fromJson: ApiBaseModel.fromJson,
          validateField: ApiBaseModel.validateField,
        ),
        ValidateFieldModel<NetApiModel>(
          fieldDesc: ApiKeyDescModel(
            key: "netApiMap",
            desc: "具体请求的api配置",
            isRequired: true,
          ),
          fieldType: "mapStrToClass",
          fromJson: NetApiModel.fromJson,
          validateField: NetApiModel.validateField,
        ),
      ],
    );

    return validateResult;
  }
}
