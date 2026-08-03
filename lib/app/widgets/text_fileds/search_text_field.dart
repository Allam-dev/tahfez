import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:tahfez/app/localization/locale_keys.g.dart';

class SearchTextField extends StatefulWidget {
  final String? hintText;
  final void Function() onSearch;
  final VoidCallback? onCancel;
  final Duration debounceDuration;
  final TextEditingController controller;
  final bool autoSearch;

  const SearchTextField({
    super.key,
    required this.onSearch,
    this.onCancel,
    this.hintText,
    this.debounceDuration = const Duration(milliseconds: 500),
    required this.controller,
    this.autoSearch = true,
  });

  @override
  State<SearchTextField> createState() => _SearchTextFieldState();
}

class _SearchTextFieldState extends State<SearchTextField> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
      textInputAction: TextInputAction.search,
      onChanged: (_) {
        if (widget.autoSearch) {
          if (_debounce?.isActive ?? false) _debounce?.cancel();
          _debounce = Timer(widget.debounceDuration, () {
            if (widget.controller.text.trim().isNotEmpty) {
              widget.onSearch();
            }
          });
        }
      },
      onSubmitted: (_) {
        if (widget.controller.text.trim().isNotEmpty) {
          widget.onSearch();
        }
      },
      decoration: InputDecoration(
        hintText: widget.hintText ?? context.tr(LocaleKeys.search),
        prefixIcon: IconButton(
          onPressed: () {
            if (widget.controller.text.trim().isNotEmpty) {
              FocusManager.instance.primaryFocus?.unfocus();
              widget.onSearch();
            }
          },
          icon: const Icon(Icons.search),
        ),
        suffixIcon: IconButton(
          onPressed: () {
            FocusManager.instance.primaryFocus?.unfocus();
            widget.controller.clear();
            widget.onCancel?.call();
          },
          icon: const Icon(Icons.close),
        ),
      ),
    );
  }
}
