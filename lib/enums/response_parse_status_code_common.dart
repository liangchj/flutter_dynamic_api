enum ResponseParseStatusCodeEnum {
  error("error", "请求失败！"),
  noData("noData", "返回数据错误！"),
  parseFail("parseFail", "解析失败"),

  dynamicRuntimeEnvironmentApplyFail(
    "dynamicRuntimeEnvironmentApplyFail",
    "动态脚本运行环境获取失败！",
  ),
  dynamicNull("dynamicNull", "动态脚本插件获取失败！"),
  dynamicFnNull("dynamicFnNull", "动态脚本方法为空"),
  dynamicFnEvaluateFail("dynamicFnEvaluateFail", "动态脚本方法解析失败"),
  dynamicFnExecuteFail("dynamicFnExecuteFail", "动态脚本方法执行失败！"),
  dynamicFnResultIsWrong("dynamicFnResultIsWrong", "动态脚本方法执行结果错误！"),
  evalNotAllowDataType("evalNotAllowDataType", "eval方法目前仅支持参数类型为Map"),
  dataNull("dataNull", "结果为空"),
  success("success", "成功");

  final String code;
  final String name;

  const ResponseParseStatusCodeEnum(this.code, this.name);
}
