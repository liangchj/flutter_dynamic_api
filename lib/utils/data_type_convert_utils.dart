class DataTypeConvertUtils {
  static Map<String, dynamic> toMapStrDyMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      Map<String, dynamic> map = {};
      for (var entry in data.entries) {
        map[(entry.key ?? '').toString()] = entry.value;
      }
      return map;
    }
    return data as Map<String, dynamic>;
  }

  static List<Map<String, dynamic>> toListMapStrDyMap(dynamic data) {
    if (data is List<Map<String, dynamic>>) {
      return data;
    }
    if (data is List) {
      List<Map<String, dynamic>> list = [];
      for (var item in data) {
        list.add(toMapStrDyMap(item));
      }
      return list;
    }
    return data as List<Map<String, dynamic>>;
  }
}
