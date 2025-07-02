class ApiKeyDescModel {
  final String key;
  final String desc;
  bool isRequired;

  ApiKeyDescModel({
    required this.key,
    required this.desc,
    this.isRequired = false,
  });

  factory ApiKeyDescModel.fromJson(Map<String, dynamic> map) {
    var isRequiredVar = map["isRequired"];
    bool? isRequired;
    if (isRequiredVar != null) {
      isRequired = bool.tryParse(isRequiredVar);
    }
    return ApiKeyDescModel(
      key: map["key"],
      desc: map["desc"],
      isRequired: isRequired ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    "key": key,
    "desc": desc,
    "isRequired": isRequired,
  };
}
