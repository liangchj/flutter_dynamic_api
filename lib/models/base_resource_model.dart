class BaseResourceModel {
  /// 资源id
  final String resourceId;

  /// 资源名称
  final String resourceName;

  /// 资源名称（英文名称或拼音）
  final String? resourceEnName;

  BaseResourceModel({
    required this.resourceId,
    required this.resourceName,
    required this.resourceEnName,
  });

  factory BaseResourceModel.fromJson(Map<String, dynamic> map) =>
      BaseResourceModel(
        resourceId: map["resourceId"] ?? "",
        resourceName: map["resourceName"] ?? "",
        resourceEnName: map["resourceEnName"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
    "resourceId": resourceId,
    "resourceName": resourceName,
    "resourceEnName": resourceEnName,
  };
}
