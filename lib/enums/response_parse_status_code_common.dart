enum ResponseParseStatusCodeEnum {
  error("error", "请求失败！"),
  noData("noData", "返回数据错误！"),
  parseFail("parseFail", "解析失败"),

  jsRuntimeEnvironmentApplyFail("jsRuntimeEnvironmentApplyFail", "js运行环境获取失败！"),
  jsNull("jsNull", "js插件获取失败！"),
  jsFnNull("jsFnNull", "js方法为空"),
  jsFnEvaluateFail("jsFnEvaluateFail", "js方法解析失败"),
  jsFnExecuteFail("jsFnExecuteFail", "js方法执行失败！"),
  jsFnResultIsWrong("jsFnResultIsWrong", "js方法执行结果错误！"),
  dataNull("dataNull", "结果为空"),
  success("success", "成功");

  final String code;
  final String name;

  const ResponseParseStatusCodeEnum(this.code, this.name);
}
