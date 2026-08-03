sealed class BluetoothException implements Exception {
  final String message;

  BluetoothException(this.message);
}

final class BluetoothPermissionException extends BluetoothException {
  BluetoothPermissionException(super.message);

  @override
  String toString() => 'BluetoothPermissionException: $message';
}

final class BluetoothDisabledException extends BluetoothException {
  BluetoothDisabledException(super.message);

  @override
  String toString() => 'BluetoothDisabledException: $message';
}
