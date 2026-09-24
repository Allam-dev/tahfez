import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tahfez/app/style/colors/aya_highlight_colors.dart';
import 'package:tahfez/core/di/main_di.dart';
import 'package:tahfez/core/extensions/context/moshaf_page.dart';
import 'package:tahfez/core/extensions/context/theme.dart';
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
      child: BlocBuilder<MoshafScreenCubit, SurahPlaybackInfo>(
        builder: (context, state) {
          if (state.ayaMetaData == null) {
            return const SizedBox.shrink();
          }
          return LayoutBuilder(
            builder: (context, constraints) {
              // 1. Calculate how your SVG fits inside the available device screen boundaries.
              // We simulate a BoxFit.contain scaling logic manually.
              double scaleX = constraints.maxWidth / svgDesignSize.width;
              double scaleY = constraints.maxHeight / svgDesignSize.height;

              // Because BoxFit.contain uses the smaller scale factor to keep aspect ratio:
              double activeScale = scaleX < scaleY ? scaleX : scaleY;

              // Calculate the actual size the SVG will occupy on screen
              double renderedWidth = svgDesignSize.width * activeScale;
              double renderedHeight = svgDesignSize.height * activeScale;

              // 2. Scale your coordinates using the calculated active scale factor
              final scaledPoints =
                  AyaCoordinateParser.parseString(
                    state.ayaMetaData?.polygon ?? '',
                  ).map((point) {
                    return Offset(
                      point.dx * activeScale,
                      point.dy * activeScale,
                    );
                  }).toList();

              // 3. Center the layout stack exactly like BoxFit.contain aligns graphics
              return Center(
                child: SizedBox(
                  width: renderedWidth,
                  height: renderedHeight,
                  child: Stack(
                    children: [
                      // The main static background SVG text page
                      Positioned.fill(
                        child: SvgPicture.asset(
                          context.getThemedMoshafPage(
                            state.ayaMetaData?.pageFileName ?? '',
                          ),
                          fit: BoxFit.contain,
                        ),
                      ),

                      // The scaled active highlight box
                      Positioned.fill(
                        child: _AnimatedAyaHighlight(
                          targetPoints: scaledPoints,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
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
