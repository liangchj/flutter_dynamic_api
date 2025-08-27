// 动态方法
import '../utils/json_to_model_utils.dart';
import 'api_key_desc_model.dart';
import 'validate_field_model.dart';
import 'validate_result_model.dart';

class DynamicFunctionModel {
  final String fn;
  // js函数执行数据需要webview
  final bool jsWebView;

  DynamicFunctionModel({required this.fn, this.jsWebView = false});

  factory DynamicFunctionModel.fromJson(Map<String, dynamic> map) {
    ValidateResultModel validateResult = DynamicFunctionModel.validateField(
      map,
    );
    if (validateResult.msgMap.isNotEmpty) {
      throw Exception(validateResult.msgMap);
    }
    var jsWebView = map["jsWebView"];
    return DynamicFunctionModel(
      fn: map["fn"],
      jsWebView: jsWebView == null ? false : bool.tryParse(jsWebView) ?? false,
    );
  }

  Map<String, dynamic> toJson() => {"fn": fn, "jsWebView": jsWebView};

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

    return validateResult;
  }
}
