import 'package:dio/dio.dart';
import 'package:tahfez/app/localization/locale_keys.g.dart';

import '../failure.dart';

abstract class DioExceptionHandler {
  static Failure handle(DioException exception) {
    switch (exception.type) {
      case DioExceptionType.connectionTimeout || DioExceptionType.sendTimeout:
        return Failure(
          type: FailureType.timeout,
          message: LocaleKeys.itTookTooLongTryAgain,
        );

      case DioExceptionType.badCertificate:
        return Failure(type: FailureType.timeout);
      case DioExceptionType.connectionError:
        return Failure(type: FailureType.network);
      case DioExceptionType.unknown:
        return Failure(
          message: exception.message ?? LocaleKeys.somethingWentWrong,
        );
      case DioExceptionType.badResponse:
        return _handleBadResponse(exception);
      default:
        return Failure();
    }
  }

  static Failure _handleBadResponse(DioException exception) {
    try {
      return Failure(
        type: _statusCodeToFailureType(exception.response?.statusCode ?? 0),
        message:
            exception.response?.data['error']?['message'] ??
            exception.response?.data['message'] ??
            LocaleKeys.somethingWentWrong,
      );
    } catch (e) {
      return Failure(
        type: FailureType.unknown,
        message: LocaleKeys.somethingWentWrong,
      );
    }
  }

  static FailureType _statusCodeToFailureType(int statusCode) {
    switch (statusCode) {
      case 404:
        return FailureType.notFound;
      case 401:
        return FailureType.authentication;
      case 400:
        return FailureType.badRequest;
      default:
        return FailureType.unknown;
    }
  }
}
