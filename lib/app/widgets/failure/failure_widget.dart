// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:tahfez/core/error/failure.dart';
// import 'package:tahfez/core/extensions/context/navigation.dart';
// import 'package:tahfez/app/localization/locale_keys.g.dart';
// import 'package:tahfez/modules/auth/presentation/screens/login/login_screen.dart';

// part 'auth_failure_widget.dart';
// part 'unknow_failure_widget.dart';

// class FailureWidget extends StatelessWidget {
//   final Failure failure;
//   final VoidCallback? onRetry;

//   const FailureWidget({super.key, required this.failure, this.onRetry});

//   @override
//   Widget build(BuildContext context) {
//     switch (failure.type) {
//       case FailureType.authentication:
//         return _AuthFailureWidget(failure: failure);
//       default:
//         return _UnknowFailureWidget(failure: failure, onRetry: onRetry);
//     }
//   }
// }

// Widget _failureIcon(FailureType failureType) {
//   switch (failureType) {
//     case FailureType.noInternet:
//       return Icon(Icons.wifi_off);
//     default:
//       return Icon(Icons.error);
//   }
// }
