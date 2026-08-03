import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:tahfez/app/localization/locale_keys.g.dart';
import 'package:tahfez/core/validators/string_validator.dart';

class PasswordTextFormField extends StatefulWidget {
  const PasswordTextFormField({
    super.key,
    this.controller,
    this.textInputAction,
    this.validator,
  });

  final TextEditingController? controller;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;

  @override
  State<PasswordTextFormField> createState() => _PasswordTextFormFieldState();
}

class _PasswordTextFormFieldState extends State<PasswordTextFormField> {
  bool obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: obscure,
      validator: widget.validator ?? StringValidator.isPassword,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: widget.textInputAction,
      decoration: InputDecoration(
        hintText: context.tr(LocaleKeys.password),
        prefixIcon: Icon(Icons.lock_rounded),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility : Icons.visibility_off),
          onPressed: () {
            setState(() {
              obscure = !obscure;
            });
          },
        ),
      ),
    );
  }
}
