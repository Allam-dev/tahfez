import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tahfez/core/services/logs/log.dart';
import 'package:tahfez/modules/surah/domain/enums/line_type_enum.dart';
import 'package:tahfez/modules/surah/domain/models/line_model.dart';
import 'package:tahfez/modules/surah/domain/models/word_model.dart';

class MushafDb {
  // 1. Private constructor for Singleton pattern
  MushafDb._privateConstructor();
  static final MushafDb instance = MushafDb._privateConstructor();

  // 2. Private Database fields (No public getters)
  late final Database _linesDB;
  late final Database _wordsDB;
  bool _isInitialized = false;

  // 3. Single init method to open both databases sequentially/concurrently
  Future<void> init() async {
    if (_isInitialized) return; // Prevent double initialization

    // Initialize both databases simultaneously for better startup performance
    final databases = await Future.wait([
      _copyAndOpenAssetDb("lines.db"),
      _copyAndOpenAssetDb("words.db"),
    ]);

    _linesDB = databases[0];
    _wordsDB = databases[1];

    _isInitialized = true;
  }

  // Core internal copying mechanism
  Future<Database> _copyAndOpenAssetDb(String assetName) async {
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, assetName);
    var exists = await databaseExists(path);

    if (!exists) {
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      ByteData data = await rootBundle.load(join("assets", 'db', assetName));
      List<int> bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
      await File(path).writeAsBytes(bytes, flush: true);
    }

    return await openDatabase(path);
  }

  Future<List<LineModel>> getPage(int page) async {
    try {
      final lines = (await _linesDB.query(
        'pages',
        where: 'page_number = ?',
        whereArgs: [page],
        orderBy: 'line_number',
      )).map((e) => LineModel.fromJson(e)).toList();

      final firstWordInPage = lines
          .firstWhere((e) => e.firstWord != null)
          .firstWord!;
      final lastWordInPage = lines
          .lastWhere((e) => e.lastWord != null)
          .lastWord!;

      final wordsMap = await _wordsDB.query(
        'words',
        where: 'id BETWEEN ? AND ?',
        whereArgs: [firstWordInPage, lastWordInPage],
      );

      for (final line in lines) {
        if (line.type == LineTypeEnum.aya) {
          final List<WordModel> words = [];
          for (int i = line.firstWord!; i <= line.lastWord!; i++) {
            words.add(WordModel.fromJson(wordsMap[i - firstWordInPage]));
          }
          line.words = words;
        }
      }

      return lines;
    } catch (e) {
      Log.error(e.toString());
      rethrow;
    }
  }
}
