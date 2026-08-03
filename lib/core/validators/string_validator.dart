import 'package:easy_localization/easy_localization.dart';
import 'package:tahfez/core/extensions/string/validations.dart';
import 'package:tahfez/app/localization/locale_keys.g.dart';

abstract class StringValidator {
  static String? isEmail(String? email) {
    if (!email.hasValue) {
      return LocaleKeys.thisFieldIsRequired.tr();
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email!)) {
      return LocaleKeys.pleaseEnterAValidEmail.tr();
    }
    return null;
  }

  static String? hasValue(String? name) {
    if (!name.hasValue) {
      return LocaleKeys.thisFieldIsRequired.tr();
    }
    return null;
  }

  static String? isEquals({
    String? parent,
    String? child,
    String parentFiledName = '',
  }) {
    if (parent != child) {
      return "${LocaleKeys.doesntMatch.tr()} $parentFiledName";
    }
    return null;
  }

  static String? isPassword(String? password) {
    if (!password.hasValue) {
      return LocaleKeys.thisFieldIsRequired.tr();
    }
    if (!RegExp(r'[A-Z]').hasMatch(password!)) {
      return LocaleKeys.mustContainAtLeastOneUpperCaseLetter.tr();
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return LocaleKeys.mustContainAtLeastOneLowerCaseLetter.tr();
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return LocaleKeys.mustContainAtLeastOneNumber.tr();
    }
    if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password)) {
      return LocaleKeys.mustContainAtLeastOneSpecialCharacter.tr();
    }
    if (password.length < 8) {
      return LocaleKeys.mustBeAtLeast8CharactersLong.tr();
    }
    return null;
  }
}
