extension Validations on String? {
  bool get hasValue => this != null && this!.isNotEmpty;
}
