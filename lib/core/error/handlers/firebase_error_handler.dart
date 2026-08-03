// import 'package:firebase_core/firebase_core.dart';

// import '../failure.dart';

// Failure handleFirebaseException(FirebaseException e) {
//   switch (e.code) {
//     case 'network-request-failed':
//       return Failure(
//         message: 'Network error. Please check your internet connection.',
//         type: FailureType.network,
//       );
//     case 'invalid-credential':
//       return Failure(
//         message: 'Invalid login credentials. Please try again.',
//         type: FailureType.authentication,
//       );

//     case 'user-not-found':
//       return Failure(
//         message: 'No user found with this email.',
//         type: FailureType.authentication,
//       );
//     case 'wrong-password':
//       return Failure(
//         message: 'Incorrect password.',
//         type: FailureType.authentication,
//       );
//     case 'invalid-email':
//       return Failure(
//         message: 'The email address format is invalid.',
//         type: FailureType.authentication,
//       );
//     case 'email-already-in-use':
//       return Failure(
//         message: 'This email is already associated with an account.',
//         type: FailureType.authentication,
//       );
//     case 'permission-denied':
//       return Failure(
//         message: 'You do not have permission to perform this action.',
//         type: FailureType.permissionDenied,
//       );
//     case 'document-not-found':
//       return Failure(
//         message: 'Requested resource was not found.',
//         type: FailureType.notFound,
//       );
//     case 'internal-error':
//     case 'unavailable':
//       return Failure(
//         message: 'Server error. Please try again later.',
//         type: FailureType.server,
//       );
//     default:
//       return Failure();
//   }
// }
