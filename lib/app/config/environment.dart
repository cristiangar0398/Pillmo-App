import 'app_constants.dart';

abstract final class Environment {
  static const apiBaseUrl = AppConstants.apiBaseUrl;
  static const isProduction = bool.fromEnvironment('dart.vm.product');
}
