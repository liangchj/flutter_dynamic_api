/// 分页
class PageModel<T> {
  /// 当前页
  int page;

  /// 页码大小
  int pageSize;

  /// 总页数
  int totalPage;

  /// 总记录数
  int totalCount;

  /// 是否到结尾（是否最后一页）
  bool isEnd;

  /// 内容列表
  List<T>? modelList;

  /// 状态码
  String statusCode;

  /// 说明信息
  String? msg;
  PageModel({
    required this.page,
    required this.pageSize,
    required this.totalPage,
    required this.totalCount,
    this.isEnd = false,
    this.modelList,
    required this.statusCode,
    this.msg,
  });

  Map<String, dynamic> toJson() => {
    "page": page,
    "pageSize": pageSize,
    "totalPage": totalPage,
    "totalCount": totalCount,
    "isEnd": isEnd,
    "modelList": modelList,
    "statusCode": statusCode,
    "msg": msg,
  };
}
