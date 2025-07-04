import '../utils/data_type_convert_utils.dart';
import '../utils/json_to_model_utils.dart';
import 'api_key_desc_model.dart';
import 'dynamic_function_model.dart';
import 'filter_criteria_model.dart';
import 'validate_field_model.dart';
import 'validate_result_model.dart';

enum DynamicParamsDataSourceEnum {
  // 动态设置（后续赋值）
  dynamic,
  // 从过滤列表中获取
  filterCriteria,
}

class DynamicParamsModel {
  static Map<String, DynamicParamsDataSourceEnum> dataSourceEnumMap =
      DynamicParamsDataSourceEnum.values.asMap().map(
        (key, value) => MapEntry(value.name, value),
      );
  // 请求时使用的key
  final String requestKey;
  // 空值也要传入
  final bool emptyNeedSend;
  // 从哪里取数
  final DynamicParamsDataSourceEnum dataSource;
  // 过滤列表
  FilterCriteriaModel? filterCriteria;

  // 处理传入值的动态方法
  final DynamicFunctionModel? handleSendValueFn;

  DynamicParamsModel({
    required this.requestKey,
    required this.emptyNeedSend,
    this.dataSource = DynamicParamsDataSourceEnum.dynamic,
    this.filterCriteria,
    this.handleSendValueFn,
  });

  factory DynamicParamsModel.fromJson(Map<String, dynamic> map) {
    ValidateResultModel validateResult = DynamicParamsModel.validateField(map);
    if (validateResult.msgMap.isNotEmpty) {
      throw Exception(validateResult.msgMap);
    }
    var emptyNeedSend = map["emptyNeedSend"];
    List<String> errorList = [];
    var filterCriteriaVar = map["filterCriteria"];
    Map<String, dynamic>? filterCriteriaMap;
    if (filterCriteriaVar != null) {
      try {
        filterCriteriaMap = DataTypeConvertUtils.toMapStrDyMap(
          filterCriteriaVar,
        );
      } catch (e) {
        errorList.add("读取配置filterCriteria转换类型时报错：$e");
      }
    }
    if (errorList.isNotEmpty) {
      throw Exception(errorList.join("\n"));
    }
    return DynamicParamsModel(
      requestKey: map["requestKey"],
      emptyNeedSend: emptyNeedSend == null
          ? true
          : bool.tryParse(emptyNeedSend) ?? true,
      dataSource:
          dataSourceEnumMap[map["dataSource"]] ??
          DynamicParamsDataSourceEnum.dynamic,
      filterCriteria: filterCriteriaMap == null
          ? null
          : FilterCriteriaModel.fromJson(filterCriteriaMap),
      handleSendValueFn: map["handleSendValueFn"] == null
          ? null
          : DynamicFunctionModel.fromJson(map["handleSendValueFn"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "requestKey": requestKey,
    "emptyNeedSend": emptyNeedSend,
    "dataSource": dataSource.name,
    "filterCriteria": filterCriteria?.toJson(),
    "handleSendValueFn": handleSendValueFn?.toJson(),
  };

  // 验证方法
  static ValidateResultModel validateField(Map<String, dynamic> map) {
    ValidateResultModel validateResult =
        JsonToModelUtils.baseValidate<DynamicParamsModel>(
          map,
          key: "dynamicParams",
          fromJson: DynamicParamsModel.fromJson,
          validateFieldFn: DynamicParamsModel.validateField,
        );
    if (!validateResult.flag) {
      return validateResult;
    }
    DynamicParamsDataSourceEnum dataSourceEnum =
        dataSourceEnumMap[map["dataSource"]] ??
        DynamicParamsDataSourceEnum.dynamic;

    JsonToModelUtils.validateModelJson(
      map,
      validateResult: validateResult,
      validateFieldList: [
        ValidateFieldModel<String>(
          fieldDesc: ApiKeyDescModel(
            key: "requestKey",
            desc: "请求时使用的key",
            isRequired: true,
          ),
          fieldType: "string",
        ),
        ValidateFieldModel<bool>(
          fieldDesc: ApiKeyDescModel(
            key: "emptyNeedSend",
            desc: "空值也要传入",
            isRequired: false,
          ),
          fieldType: "bool",
        ),

        ValidateFieldModel<String>(
          fieldDesc: ApiKeyDescModel(
            key: "dataSource",
            desc: "从哪里取数",
            isRequired: false,
          ),
          fieldType: "string",
        ),
        ValidateFieldModel<FilterCriteriaModel?>(
          fieldDesc: ApiKeyDescModel(
            key: "filterCriteria",
            desc: "过滤列表",
            isRequired:
                dataSourceEnum == DynamicParamsDataSourceEnum.filterCriteria,
          ),
          fieldType: "class",
          fromJson: FilterCriteriaModel.fromJson,
          validateField: FilterCriteriaModel.validateField,
        ),

        ValidateFieldModel<DynamicFunctionModel?>(
          fieldDesc: ApiKeyDescModel(
            key: "handleSendValueFn",
            desc: "处理传入值的动态方法",
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
