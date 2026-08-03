import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tahfez/core/services/logs/log.dart';
import 'package:tahfez/core/services/download_manager/download_manager.dart';

class DownloadManagerDioImp implements DownloadManager {
  @override
  Future<String?> downloadFile(String url, String fileName) async {
    try {
      final dio = Dio();
      final response = await dio.get(
        url,
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.statusCode == 200) {
        Directory? saveDir;

        if (defaultTargetPlatform == TargetPlatform.android) {
          saveDir = Directory('/storage/emulated/0/Download');
        } else if (defaultTargetPlatform == TargetPlatform.iOS) {
          saveDir = await getApplicationDocumentsDirectory();
        }

        if (saveDir != null) {
          if (!saveDir.existsSync()) {
            saveDir.createSync(recursive: true);
          }

          final filePath = '${saveDir.path}/$fileName';
          final file = File(filePath);
          await file.writeAsBytes(response.data);

          Log.info('File saved successfully: $filePath');
          return filePath;
        } else {
          Log.error('Failed to determine save directory.');
        }
      } else {
        Log.error(
          'Failed to download file. HTTP status: ${response.statusCode}',
        );
      }
      return null;
    } catch (e) {
      Log.error('Error downloading file: $e');
      rethrow;
    }
  }
}
