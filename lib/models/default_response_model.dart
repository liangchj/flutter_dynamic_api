/// 默认的响应结果
class DefaultResponseModel<T> {
  /// 响应的数据
  T? model;

  /// 响应状态码
  String statusCode;

  /// 响应说明
  String? msg;

  DefaultResponseModel({this.model, required this.statusCode, this.msg});

  Map<String, dynamic> toJson() => {
    "model": model,
    "statusCode": statusCode,
    "msg": msg,
  };
}
