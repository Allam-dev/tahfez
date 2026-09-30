import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tahfez/app/style/colors/aya_highlight_colors.dart';
import 'package:tahfez/core/di/main_di.dart';
import 'package:tahfez/core/extensions/context/moshaf_page.dart';
import 'package:tahfez/core/extensions/context/theme.dart';
import 'package:tahfez/core/services/logs/log.dart';
import 'package:tahfez/modules/surah/domain/models/surah_playback_info.dart';
import 'package:tahfez/modules/surah/presentation/moshaf/cubit/moshaf_screen_cubit.dart';

part 'widgets/aya_highlighter.dart';

class MoshafScreen extends StatelessWidget {
  MoshafScreen({super.key});
  final Size svgDesignSize = Size(345, 550);
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MoshafScreenCubit(getIt()),
      child: BlocBuilder<MoshafScreenCubit, MoshafScreenState>(
        builder: (context, state) {
          if (state.playbackInfo.ayaMetaData == null) {
            return const SizedBox.shrink();
          }
          return Directionality(
            textDirection: TextDirection.rtl,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: state.lines.map<Widget>((line) {
                  final words = line.words;
                  if (words == null || words.isEmpty) {
                    return const Expanded(child: SizedBox.shrink());
                  }
                  return Expanded(
                    child: FittedBox(
                      fit: BoxFit.fitWidth, // scale line to full width
                      child: Text.rich(
                        TextSpan(
                          children: [
                            for (int i = 0; i < words.length; i++)
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
                            fontFamily: 'p${state.playbackInfo.ayaMetaData!.pageNumber}',
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
    );
  }
}

/// =========================================================================
/// 5. SVG STRING PARSER REUSABLE UTILITY
/// =========================================================================
class AyaCoordinateParser {
  AyaCoordinateParser._();

  /// Converts an SVG polygon data string into a structural Flutter [List<Offset>]
  static List<Offset> parseString(String polygonString) {
    if (polygonString.trim().isEmpty) return [];
    try {
      return polygonString.trim().split(' ').map((pair) {
        final coordinates = pair.split(',');
        return Offset(
          double.parse(coordinates[0]),
          double.parse(coordinates[1]),
        );
      }).toList();
    } catch (e) {
      debugPrint("Error parsing ayah coordinate structure: $e");
      return [];
    }
  }
}
