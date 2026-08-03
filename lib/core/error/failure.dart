import 'package:dio/dio.dart';
import 'package:tahfez/app/localization/locale_keys.g.dart';
import 'exceptions/bluetooth_exception.dart';
import 'exceptions/no_internet_exception.dart';
import 'handlers/dio_exception_handler.dart';

enum FailureType {
  unknown,
  timeout,
  forbidden,
  notFound,
  badRequest,
  invalidInput,
  authentication,
  permissionDenied,
  network,
  serv,
  noInternet,
}

class Failure {
  FailureType type;
  String message;

  Failure({
    this.type = FailureType.unknown,
    this.message = LocaleKeys.somethingWentWrong,
  });

  factory Failure.fromException(dynamic e) {
    switch (e) {
      case NoInternetConnectionException _:
        return Failure(
          message: LocaleKeys.noInternetConnection,
          type: FailureType.network,
        );
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
