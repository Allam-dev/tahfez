import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tahfez/modules/surah/domain/models/surah_model.dart';
import 'package:tahfez/modules/surah/presentation/play/cubit/play_screen_cubit.dart';

class SurahDropdown extends StatefulWidget {
  const SurahDropdown({super.key});

  @override
  State<SurahDropdown> createState() => _SurahDropdownState();
}

class _SurahDropdownState extends State<SurahDropdown> {
  @override
  Widget build(BuildContext context) {
    final playScreenCubit = context.read<PlayScreenCubit>();
    return Column(
      children: [
        Row(
          children: [
            // from
            DropdownMenu<int>(
              initialSelection: playScreenCubit.playParams.startSurahNumber,
              dropdownMenuEntries: SUR
                  .map(
                    (e) => DropdownMenuEntry<int>(value: e.id, label: e.name),
                  )
                  .toList(),
              onSelected: (surah) {
                if (surah != null) {
                  setState(() {
                    playScreenCubit.playParams.startSurahNumber = surah;
                    playScreenCubit.playParams.startAya = 1;
                    playScreenCubit.playParams.endSurahNumber = surah;
                    playScreenCubit.playParams.endAya =
                        SUR[surah - 1].versesCount;
                  });
                }
              },
            ),
            DropdownMenu(
              initialSelection: playScreenCubit.playParams.startAya,
              dropdownMenuEntries: List.generate(
                SUR[playScreenCubit.playParams.startSurahNumber - 1]
                    .versesCount,
                (index) {
                  return DropdownMenuEntry(
                    value: index + 1,
                    label: (index + 1).toString(),
                  );
                },
              ),
              onSelected: (aya) {
                if (aya != null) {
                  setState(() {
                    playScreenCubit.playParams.startAya = aya;
                    if (aya >=
                        SUR[playScreenCubit.playParams.startSurahNumber - 1]
                            .versesCount) {
                      playScreenCubit.playParams.endSurahNumber =
                          playScreenCubit.playParams.startSurahNumber + 1;
                      playScreenCubit.playParams.endAya = 1;
                    } else {
                      playScreenCubit.playParams.endSurahNumber =
                          playScreenCubit.playParams.startSurahNumber;
                      playScreenCubit.playParams.endAya =
                          SUR[playScreenCubit.playParams.startSurahNumber - 1]
                              .versesCount;
                    }
                  });
                }
              },
            ),
          ],
        ),
        // to
        Row(
          children: [
            DropdownMenu(
              initialSelection: playScreenCubit.playParams.endSurahNumber,
              dropdownMenuEntries: SUR
                  .skip(playScreenCubit.playParams.startSurahNumber - 1)
                  .map((e) => DropdownMenuEntry(value: e.id, label: e.name))
                  .toList(),
              onSelected: (surahId) {
                if (surahId != null) {
                  setState(() {
                    playScreenCubit.playParams.endSurahNumber = surahId;
                    playScreenCubit.playParams.endAya =
                        SUR[surahId - 1].versesCount;
                  });
                }
              },
            ),
            DropdownMenu(
              initialSelection: playScreenCubit.playParams.endAya,
              dropdownMenuEntries: playScreenCubit.playParams.sameSurah
                  ? List.generate(
                      SUR[playScreenCubit.playParams.endSurahNumber - 1]
                              .versesCount -
                          playScreenCubit.playParams.startAya,
                      (index) {
                        return DropdownMenuEntry(
                          value:
                              index + playScreenCubit.playParams.startAya + 1,
                          label:
                              (index + playScreenCubit.playParams.startAya + 1)
                                  .toString(),
                        );
                      },
                    )
                  : List.generate(
                      SUR[playScreenCubit.playParams.endSurahNumber - 1]
                          .versesCount,
                      (index) {
                        return DropdownMenuEntry(
                          value: index + 1,
                          label: (index + 1).toString(),
                        );
                      },
                    ),
              onSelected: (aya) {
                if (aya != null) {
                  setState(() {
                    playScreenCubit.playParams.endAya = aya;
                  });
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}
