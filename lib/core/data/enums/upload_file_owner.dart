enum UploadFileOwner {
  user,
  product,
  message,
}


extension UploadFileOwnerExtension on UploadFileOwner {
  String get apiString {
    switch (this) {
      case UploadFileOwner.user:
        return 'user';
      case UploadFileOwner.product:
        return 'product';
      case UploadFileOwner.message:
        return 'message';
    }
  }
}