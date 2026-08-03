enum UploadFilePurpose {
  avatar,
  productImage,
  chatAttachment,
  document,
}


extension UploadFilePurposeExtension on UploadFilePurpose {
  String get apiString {
    switch (this) {
      case UploadFilePurpose.avatar:
        return 'avatar';
      case UploadFilePurpose.productImage:
        return 'product_image';
      case UploadFilePurpose.chatAttachment:
        return 'chat_attachment';
      case UploadFilePurpose.document:
        return 'document';
    }
  }
}