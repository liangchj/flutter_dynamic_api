import 'package:flutter_dynamic_api/flutter_dynamic_api.dart';

void main() {
  var apiJson = {
    "apiBaseModel": {
      "name": "mate40",
      "enName": "mate40",
      "baseUrl": "http://192.168.7.215:9999/api.php/provide/vod",
    },
    "netApiMap": {
      "listApi": {
        "apiDesc": "列表请求",
        "path": "/vod/list",
        "requestParams": {
          "headerParams": {},
          "staticParams": {"t": "vod", "ac": "list"},
          "dynamicParams": {
            "page": {"requestKey": "pg"},
            "pageSize": {"requestKey": "limit"},
            "totalPage": {"requestKey": "pagecount"},
            "totalCount": {"requestKey": "total"},
            "typeIds": {
              "requestKey": "t",
              "dataSource": "filterCriteria",
              "filterCriteria": {
                "enName": "type",
                "name": "类型",
                "filterCriteriaParamsList": [
                  {"value": "1", "label": "电影"},
                  {"value": "2", "label": "电视剧"},
                  {"value": "4", "label": "动漫"},
                ],
              },
            },
            "class": {
              "requestKey": "class",
              "dataSource": "filterCriteria",
              "filterCriteria": {
                "enName": "type1",
                "name": "类型1",
                "netApi": {
                  "path": "/vod/list",
                  "requestParams": {
                    "headerParams": {},
                    "staticParams": {"t": "0", "ac": "list"},
                    "dynamicParams": {
                      "parentTypeIds": {
                        "requestKey": "t",
                        "dataSource": "filterCriteria",
                        "filterCriteria": {
                          "enName": "type",
                          "name": "类型",
                          "filterCriteriaParamsList": [],
                        },
                      },
                    },
                  },
                  "responseParams": {
                    "statusCodeKey": "code",
                    "successStatusCode": "1",
                    "resDataKey": "class",
                    "resMsg": "请求成功",
                    "resultKeyMap": {
                      "value": "type_id",
                      "label": "type_name",
                      "parentValue": "type_id",
                    },
                  },
                },
              },
            },
            "typeJsFn": {
              "requestKey": "typeJsFn",
              "dataSource": "filterCriteria",
              "filterCriteria": {
                "enName": "typeJsFn",
                "name": "类型解析js方法",
                "netApi": {
                  "path": "/vod/list",
                  "requestParams": {
                    "headerParams": {},
                    "staticParams": {"t": "0", "ac": "list"},
                    "dynamicParams": {
                      "parentTypeIds": {
                        "requestKey": "t",
                        "dataSource": "filterCriteria",
                        "filterCriteria": {
                          "enName": "type",
                          "name": "类型",
                          "filterCriteriaParamsList": [],
                        },
                      },
                    },
                  },
                  "responseParams": {
                    "statusCodeKey": "code",
                    "successStatusCode": "1",
                    "resDataKey": "class",
                    "resMsg": "请求成功",
                    "resultConvertJsFn": """
              function convertJson(typeJson) {
                if (!typeJson) {
                    typeJson = {}
                }
                let typeList = typeJson["class"] || [];
                let newList = [];
                for (let i in typeList) {
                    let item = typeList[i];
                    newList.push({
                        "value": item["type_id"],
                        "label": item["type_name"],
                        "parentValue": item["type_pid"]
                    });
                }
                typeJson["class"] = newList;
                return typeJson;
            }
          """,
                  },
                },
              },
            },
          },
        },
        "responseParams": {
          "statusCodeKey": "code",
          "successStatusCode": "200",
          "resDataKey": "list",
          "resMsg": "请求成功",
          "resultKeyList": {"resourceId": "id"},
        },
      },
    },
  };

  var validateResult = ApiConfigModel.validateField(apiJson);
  print(validateResult);
  if (validateResult.flag) {
    try {
      ApiConfigModel? apiConfigModel = ApiConfigModel.fromJson(apiJson);
      print(apiConfigModel.toJson());
    } catch (e) {
      print("转换出错：${JsonToModelUtils.getValidateResultMsg(validateResult)}");
    }
  }
}
