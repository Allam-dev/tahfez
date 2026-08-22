import 'package:flutter/material.dart';

/// A reusable, selection-enforced [DropdownMenu] wrapper.
///
/// Features:
/// - Typing in the text field is used ONLY for filtering/searching the popup list.
/// - Typing does NOT mutate the selected value directly.
/// - Selecting text on focus allows quick typing without appending to the existing label.
/// - If search produces no results or user unfocuses without selecting an item,
///   the text field automatically restores the selected value label before search.
/// - Supports Arabic character normalization during search filtering.
class AppDropdownMenu<T> extends StatefulWidget {
  final T? initialSelection;
  final List<DropdownMenuEntry<T>> dropdownMenuEntries;
  final ValueChanged<T?>? onSelected;
  final double? menuHeight;
  final EdgeInsets? expandedInsets;
  final bool enableFilter;
  final bool requestFocusOnTap;
  final Widget? label;
  final String? hintText;
  final bool enabled;
  final Widget? trailingIcon;
  final Widget? leadingIcon;
  final TextStyle? textStyle;

  const AppDropdownMenu({
    super.key,
    this.initialSelection,
    required this.dropdownMenuEntries,
    this.onSelected,
    this.menuHeight,
    this.expandedInsets,
    this.enableFilter = true,
    this.requestFocusOnTap = true,
    this.label,
    this.hintText,
    this.enabled = true,
    this.trailingIcon,
    this.leadingIcon,
    this.textStyle,
  });

  @override
  State<AppDropdownMenu<T>> createState() => _AppDropdownMenuState<T>();
}

class _AppDropdownMenuState<T> extends State<AppDropdownMenu<T>> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  T? _selectedVal;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    _selectedVal = widget.initialSelection;
    _updateControllerText();

    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(covariant AppDropdownMenu<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialSelection != oldWidget.initialSelection ||
        widget.dropdownMenuEntries != oldWidget.dropdownMenuEntries) {
      _selectedVal = widget.initialSelection;
      _updateControllerText();
    }
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      // Auto-highlight existing text so typing immediately replaces it for searching
      if (_controller.text.isNotEmpty) {
        _controller.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _controller.text.length,
        );
      }
    } else {
      // Focus lost / dismissed: restore to the selected value before search
      _updateControllerText();
    }
  }

  void _updateControllerText() {
    final selectedEntry = _findEntry(_selectedVal);
    final expectedText = selectedEntry?.label ?? '';
    if (_controller.text != expectedText) {
      _controller.text = expectedText;
    }
  }

  DropdownMenuEntry<T>? _findEntry(T? value) {
    if (value == null) return null;
    for (final entry in widget.dropdownMenuEntries) {
      if (entry.value == value) return entry;
    }
    return null;
  }

  static String _normalizeArabic(String text) {
    return text
        .replaceAll(RegExp(r'[أإآا]'), 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ئ', 'ي')
        .replaceAll('ؤ', 'و')
        .toLowerCase();
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<T>(
      key: ValueKey('${_selectedVal}_${widget.initialSelection}_${widget.dropdownMenuEntries.length}'),
      controller: _controller,
      focusNode: _focusNode,
      initialSelection: _selectedVal,
      dropdownMenuEntries: widget.dropdownMenuEntries,
      menuHeight: widget.menuHeight,
      expandedInsets: widget.expandedInsets,
      enableFilter: widget.enableFilter,
      requestFocusOnTap: widget.requestFocusOnTap,
      label: widget.label,
      hintText: widget.hintText,
      enabled: widget.enabled,
      trailingIcon: widget.trailingIcon,
      leadingIcon: widget.leadingIcon,
      textStyle: widget.textStyle,
      filterCallback: (entries, filter) {
        if (filter.trim().isEmpty) return entries;
        final normalizedFilter = _normalizeArabic(filter.trim());
        return entries.where((entry) {
          final normalizedLabel = _normalizeArabic(entry.label);
          return normalizedLabel.contains(normalizedFilter);
        }).toList();
      },
      onSelected: (value) {
        if (value != null) {
          setState(() {
            _selectedVal = value;
            _updateControllerText();
          });
          widget.onSelected?.call(value);
        } else {
          // If null or invalid, revert back to the pre-search value
          _updateControllerText();
        }
      },
    );
  }
}
