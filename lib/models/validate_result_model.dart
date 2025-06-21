class ValidateResultModel {
  final String key;
  bool flag;
  final Map<String, String> msgMap;
  final Map<String, Map<String, ValidateResultModel>> childValidateResultMap;

  ValidateResultModel({
    required this.key,
    this.flag = true,
    required this.msgMap,
    required this.childValidateResultMap,
  });
}
