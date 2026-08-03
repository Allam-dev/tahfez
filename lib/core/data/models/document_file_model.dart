enum DocumentFileType {
  image,
  video,
  pdf,
  word,
  powerpoint,
  excel,
  other;

  static DocumentFileType fromString(String type) {
    switch (type.toLowerCase()) {
      case 'image':
        return DocumentFileType.image;
      case 'video':
        return DocumentFileType.video;
      case 'pdf':
        return DocumentFileType.pdf;
      case 'word':
        return DocumentFileType.word;
      case 'powerpoint':
        return DocumentFileType.powerpoint;
      default:
        return DocumentFileType.other;
    }
  }
}

class DocumentFile {
  final String id;
  final String name;
  final String endpoint;
  late DocumentFileType type;

  DocumentFile({
    required this.id,
    required this.name,
    required this.endpoint,
    DocumentFileType? type,
  }) {
    this.type = type ?? _determineFileTypeFromName(name);

    if (this.type == DocumentFileType.other) {
      this.type = _determineFileTypeFromName(endpoint);
    }
  }

  factory DocumentFile.fromJsonImageType(Map json) {
    return DocumentFile(
      id: json['id'] as String,
      name: '',
      type: DocumentFileType.image,
      endpoint:
          (json['image_url'] ?? json['publicUrl'] ?? json['image']) as String,
    );
  }

  factory DocumentFile.fromimageId(String id) {
    return DocumentFile(
      id: id,
      name: '',
      type: DocumentFileType.image,
      endpoint: id,
    );
  }

  factory DocumentFile.fakeFromUrl(String url) {
    return DocumentFile(
      id: 'fake-id',
      name: url.split('/').last,
      endpoint: url,
    );
  }

  factory DocumentFile.fromJson(Map json) {
    return DocumentFile(
      id: json['id'] as String,
      name: json['fileName'] ?? json['name'] ?? json['object_key'] ?? 'unknown',
      endpoint: json['publicUrl'] ?? json['endpoint'] ?? json['url'] as String,
    );
  }

  DocumentFileType _determineFileTypeFromName(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.endsWith('.jpg') ||
        lowerName.endsWith('.jpeg') ||
        lowerName.endsWith('.png')) {
      return DocumentFileType.image;
    } else if (lowerName.endsWith('.mp4') || lowerName.endsWith('.mov')) {
      return DocumentFileType.video;
    } else if (lowerName.endsWith('.pdf')) {
      return DocumentFileType.pdf;
    } else if (lowerName.endsWith('.doc') || lowerName.endsWith('.docx')) {
      return DocumentFileType.word;
    } else if (lowerName.endsWith('.ppt') || lowerName.endsWith('.pptx')) {
      return DocumentFileType.powerpoint;
    } else {
      return DocumentFileType.other;
    }
  }

  Map toJson() {
    return {'id': id, 'fileName': name, 'publicUrl': endpoint};
  }

  String get url => endpoint;
}
