import '../models/validate_result_model.dart';
// 定义验证回调签名
typedef ModelValidator<T> =
    ValidateResultModel Function(Map<String, dynamic> json);
typedef ModelFactory<T> = T Function(Map<String, dynamic> json);

class JsonToModelFn<T> {
  final T? model;
  final String? msg;

  JsonToModelFn({this.model, this.msg});
}

class ModelValidateFactoryUtils {
  static final _validators = <Type, ModelValidator>{};
  static final _factories = <Type, ModelFactory>{};

  // 注册模型和方法
  static void register<T>({
    required ModelValidator<T> validator,
    required ModelFactory<T> factory,
  }) {
    _validators[T] = validator;
    _factories[T] = factory as ModelFactory;
  }

  // 注册模型
  static void registerFactory<T>(ModelFactory<T> factory) {
    _factories[T] = factory as ModelFactory;
  }

  // 注册模型方法
  static void registerValidator<T>(ModelValidator<T> validator) {
    _validators[T] = validator;
  }

  // 取消注册模型处理逻辑
  static void unregisterFactory<T>() {
    if (_validators.containsKey(T)) {
      _validators.remove(T);
    }
    if (_factories.containsKey(T)) {
      _factories.remove(T);
    }
  }

  // 取消注册某个方法
  static void unregisterFn<T>() {
    if (_validators.containsKey(T)) {
      _validators.remove(T);
    }
  }

  // 判断是否已经注册了模型
  static bool isRegisterFactory<T>() {
    return _factories.containsKey(T) && _factories[T] != null;
  }

  // 判断是否已经注册了方法
  static bool isRegisterValidator<T>() {
    return _validators.containsKey(T) && _validators[T] != null;
  }

  static ValidateResultModel validateField<T>(
    Map<String, dynamic> json, {
    Map<String, String>? extend,
  }) {
    ModelFactory<T>? factory = _factories[T] as ModelFactory<T>?;
    if (factory == null) {
      throw Exception("$T未注册");
    }
    final validator = _validators[T];
    if (validator == null) {
      throw Exception("$T中的方法$validator未注册");
    }
    return validator(json);
  }

  static JsonToModelFn<T> toModel<T>(Map<String, dynamic> json) {
    ModelFactory<T>? factory = _factories[T] as ModelFactory<T>?;
    if (factory == null) {
      return JsonToModelFn<T>(msg: "$T未注册");
    }
    final validator = _validators[T];
    if (validator != null) {
      var validateResultModel = validator(json);
      if (!validateResultModel.flag) {
        return JsonToModelFn<T>(msg: "$T验证失败");
      }
    }
    return JsonToModelFn<T>(model: factory(json));
  }
}
