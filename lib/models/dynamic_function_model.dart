// 动态方法
import '../utils/json_to_model_utils.dart';
import 'api_key_desc_model.dart';
import 'validate_field_model.dart';
import 'validate_result_model.dart';

enum DynamicFunctionEnum { dartEval, js }

class DynamicFunctionModel {
  static Map<String, DynamicFunctionEnum> dataSourceEnumMap =
      DynamicFunctionEnum.values.asMap().map(
        (key, value) => MapEntry(value.name, value),
      );
  final DynamicFunctionEnum dynamicFunctionEnum;
  final String fn;
  // dart_eval需要，不传默认为main
  final String? fnName;
  // js函数执行数据需要webview
  final bool jsWebView;

  DynamicFunctionModel({
    required this.dynamicFunctionEnum,
    required this.fn,
    this.fnName,
    this.jsWebView = false,
  });

  factory DynamicFunctionModel.fromJson(Map<String, dynamic> map) {
    ValidateResultModel validateResult = DynamicFunctionModel.validateField(
      map,
    );
    if (validateResult.msgMap.isNotEmpty) {
      throw Exception(validateResult.msgMap);
    }
    var jsWebView = map["jsWebView"];
    return DynamicFunctionModel(
      dynamicFunctionEnum: dataSourceEnumMap[map["dynamicFunctionEnum"]]!,
      fn: map["fn"],
      fnName: map["fnName"],
      jsWebView: jsWebView == null ? false : bool.tryParse(jsWebView) ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    "dynamicFunctionEnum": dynamicFunctionEnum,
    "fn": fn,
    "fnName": fnName,
    "jsWebView": jsWebView,
  };

  // 验证方法
  static ValidateResultModel validateField(Map<String, dynamic> map) {
    ValidateResultModel validateResult =
        JsonToModelUtils.baseValidate<DynamicFunctionModel>(
          map,
          key: "dynamicFunction",
          fromJson: DynamicFunctionModel.fromJson,
          validateFieldFn: DynamicFunctionModel.validateField,
        );
    if (!validateResult.flag) {
      return validateResult;
    }

    JsonToModelUtils.validateModelJson(
      map,
      validateResult: validateResult,
      validateFieldList: [
        ValidateFieldModel<String>(
          fieldDesc: ApiKeyDescModel(
            key: "dynamicFunctionEnum",
            desc: "动态方法类型",
            isRequired: true,
          ),
          fieldType: "string",
        ),
        ValidateFieldModel<String>(
          fieldDesc: ApiKeyDescModel(
            key: "fn",
            desc: "动态方法字符串",
            isRequired: true,
          ),
          fieldType: "string",
        ),
        ValidateFieldModel<String>(
          fieldDesc: ApiKeyDescModel(
            key: "fnName",
            desc: "动态方法名称",
            isRequired: false,
          ),
          fieldType: "string",
        ),

        ValidateFieldModel<bool>(
          fieldDesc: ApiKeyDescModel(
            key: "jsWebView",
            desc: "js函数执行数据需要webview",
            isRequired: false,
          ),
          fieldType: "bool",
        ),
      ],
    );

    var dynamicFunctionEnum = map["dynamicFunctionEnum"];
    if (dynamicFunctionEnum != null &&
        dynamicFunctionEnum.toString().isNotEmpty) {
      if (!dataSourceEnumMap.containsKey(dynamicFunctionEnum.toString())) {
        String msg = validateResult.msgMap["dynamicFunctionEnum"] ?? "";
        msg +=
            "动态方法类型（dynamicFunctionEnum）只允许填写[${dataSourceEnumMap.keys.join('、')}]";
        validateResult.msgMap["dynamicFunctionEnum"] = msg;
      }
    }

    return validateResult;
  }
}
