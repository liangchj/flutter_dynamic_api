import 'package:flutter_js/flutter_js.dart';

class JsExecuteUtils {
  static JavascriptRuntime? flutterJs;

  static applyGetFlutterJavascriptRuntime() {
    flutterJs = getJavascriptRuntime();
  }

  static disposeFlutterJavascriptRuntime() {
    flutterJs?.dispose();
  }
}
