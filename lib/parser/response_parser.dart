import '../models/default_response_model.dart';
import '../models/net_api_model.dart';
import '../models/page_model.dart';

/// 响应数据解码器
abstract class ResponseParser<T> {
  // 解析列表内容
  PageModel<T> listDataParse(dynamic data, NetApiModel netApi);

  /// 解析单个内容
  DefaultResponseModel<T> detailParse(dynamic data, NetApiModel netApi);
}
