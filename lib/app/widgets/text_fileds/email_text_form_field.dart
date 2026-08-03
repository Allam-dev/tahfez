import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:tahfez/app/localization/locale_keys.g.dart';
import 'package:tahfez/core/validators/string_validator.dart';

class EmailTextFormField extends StatelessWidget {
  const EmailTextFormField({super.key, this.controller, this.textInputAction});

  final TextEditingController? controller;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textInputAction: textInputAction,
      keyboardType: TextInputType.emailAddress,
      validator: StringValidator.isEmail,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.email),
        labelText: context.tr(LocaleKeys.email),
      ),
    );
  }
}
