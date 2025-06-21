import '../models/base_resource_model.dart';
import '../models/default_response_model.dart';
import '../models/net_api_model.dart';
import '../models/page_model.dart';

/// 响应数据解码器
abstract class ResponseParser {
  /// 解析列表内容
  /// 设置了key-value读取数据
  /// 结果是json
  PageModel<BaseResourceModel> listDataParseFromJson(
    Map<String, dynamic> map,
    NetApiModel netApiModel,
  );

  /// 解析列表
  /// 设置了key-value读取数据
  /// 结果未知
  PageModel<BaseResourceModel> listParseFromDynamic(
    dynamic data,
    NetApiModel netApiModel,
  );

  /// 解析列表内容
  /// 未设置设置了key-value读取数据，使用自定义的Js方法解析
  /// 结果是json
  PageModel<BaseResourceModel> listDataParseFromJsonAndJsFn(
    Map<String, dynamic> map,
    NetApiModel netApiModel,
  );

  /// 解析列表
  /// 未设置设置了key-value读取数据，使用自定义的Js方法解析
  /// 结果未知
  PageModel<BaseResourceModel> listParseFromDynamicAndJsFn(
    dynamic data,
    NetApiModel netApiModel,
  );

  /// 解析单个内容
  /// 设置了key-value读取数据
  /// 结果是json
  DefaultResponseModel<BaseResourceModel> detailParseFromJson(
    Map<String, dynamic> map,
    NetApiModel netApiModel,
  );

  /// 解析单个内容
  /// 设置了key-value读取数据
  /// 结果是json
  DefaultResponseModel<BaseResourceModel> detailParseFromDynamic(
    dynamic data,
    NetApiModel netApiModel,
  );
}
