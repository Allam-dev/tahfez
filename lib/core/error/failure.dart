import 'package:dio/dio.dart';
import 'package:tahfez/app/localization/locale_keys.g.dart';
import 'exceptions/bluetooth_exception.dart';
import 'exceptions/no_internet_exception.dart';
import 'handlers/dio_exception_handler.dart';

enum FailureType {
  unknown(LocaleKeys.noInternetConnection),
  timeout(LocaleKeys.itTookTooLongTryAgain),
  forbidden(LocaleKeys.forbidden),
  notFound(LocaleKeys.notFound),
  badRequest(LocaleKeys.badRequest),
  invalidInput(LocaleKeys.invalidInput),
  authentication(LocaleKeys.authentication),
  permissionDenied(LocaleKeys.permissionDenied),
  network(LocaleKeys.networkError),
  server(LocaleKeys.serverError),
  noInternet(LocaleKeys.noInternetConnection);

  final String message;
  const FailureType(this.message);
}

class Failure {
  FailureType type;
  String message;

  Failure({this.type = FailureType.unknown, String? message})
    : message = message ?? type.message;

  @override
  String toString() {
    return 'FailureType: $type, Message: $message';
  }

  factory Failure.fromException(dynamic e) {
    switch (e) {
      case NoInternetConnectionException _:
        return Failure(type: FailureType.noInternet);
      case BluetoothException _:
        return Failure(message: e.message);
      case Failure _:
        return e;
      case DioException _:
        return DioExceptionHandler.handle(e);

      default:
        return Failure();
    }
  }
}
