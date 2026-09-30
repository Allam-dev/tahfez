import 'package:flutter/material.dart';
import 'package:tahfez/modules/surah/data/data_sources/db/mushaf_db.dart';
import 'package:tahfez/modules/surah/domain/enums/line_type_enum.dart';
import 'package:tahfez/modules/surah/domain/models/surah_model.dart';

class TestTextScreen extends StatelessWidget {
  TestTextScreen({super.key});

  final int p = 586;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F5),
      body: SafeArea(
        child: FutureBuilder(
          future: MushafDb.instance.getPage(p),
          builder: (context, snapshot) {
            final list = snapshot.data ?? [];
            if (list.isEmpty) return const SizedBox.shrink();

            return Directionality(
              textDirection: TextDirection.rtl,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: list.map<Widget>((line) {
                    final words = line.words;
                    if (line.type == LineTypeEnum.basmallah) {
                      return Text(
                        'بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ',
                        style: TextStyle(fontFamily: 'hafs'),
                      );
                    } else if (line.type == LineTypeEnum.surahName) {
                      return Text(
                        SUR.first.name,
                        style: TextStyle(fontFamily: 'hafs'),
                      );
                    }
                    return Expanded(
                      child: FittedBox(
                        fit: BoxFit.fitWidth, // scale line to full width
                        child: Text.rich(
                          TextSpan(
                            children: [
                              for (int i = 0; i < words!.length; i++)
                                TextSpan(
                                  text: words[i].text,
                                  style: TextStyle(
                                    backgroundColor: words[i].aya == 13
                                        ? Colors.red
                                        : null,
                                  ),
                                ),
                            ],
                            style: TextStyle(
                              fontFamily: 'p$p',
                              fontSize: 100, // base size, FittedBox rescales
                              color: Colors.black,
                            ),
                          ),
                          textDirection: TextDirection.rtl,
                          softWrap: false,
                          maxLines: 1,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
