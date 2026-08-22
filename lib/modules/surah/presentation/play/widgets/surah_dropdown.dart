part of '../play_screen.dart';

class SurahDropdown extends StatefulWidget {
  const SurahDropdown({super.key});

  @override
  State<SurahDropdown> createState() => _SurahDropdownState();
}

class _SurahDropdownState extends State<SurahDropdown> {
  @override
  Widget build(BuildContext context) {
    final playScreenBloc = context.read<PlayScreenCubit>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 30.h,
      children: [
        Row(
          spacing: 16.w,
          children: [
            // from surah
            Expanded(
              child: AppDropdownMenu<int>(
                menuHeight: 300.h,
                enableFilter: true,
                requestFocusOnTap: true,
                expandedInsets: EdgeInsets.zero,
                initialSelection: playScreenBloc.playParams.startSurahNumber,
                dropdownMenuEntries: SUR
                    .map(
                      (e) => DropdownMenuEntry<int>(value: e.id, label: e.name),
                    )
                    .toList(),
                onSelected: (surah) {
                  if (surah != null) {
                    setState(() {
                      playScreenBloc.playParams.startSurahNumber = surah;
                      playScreenBloc.playParams.startAya = 1;
                      playScreenBloc.playParams.endSurahNumber = surah;
                      playScreenBloc.playParams.endAya =
                          SUR[surah - 1].versesCount;
                    });
                  }
                },
              ),
            ),
            // from aya
            AppDropdownMenu<int>(
              menuHeight: 300.h,
              enableFilter: true,
              requestFocusOnTap: true,
              initialSelection: playScreenBloc.playParams.startAya,
              dropdownMenuEntries: List.generate(
                SUR[playScreenBloc.playParams.startSurahNumber - 1].versesCount,
                (index) {
                  return DropdownMenuEntry<int>(
                    value: index + 1,
                    label: (index + 1).toString(),
                  );
                },
              ),
              onSelected: (aya) {
                if (aya != null) {
                  setState(() {
                    playScreenBloc.playParams.startAya = aya;
                    if (aya >=
                        SUR[playScreenBloc.playParams.startSurahNumber - 1]
                            .versesCount) {
                      playScreenBloc.playParams.endSurahNumber =
                          playScreenBloc.playParams.startSurahNumber + 1;
                      playScreenBloc.playParams.endAya = 1;
                    } else {
                      playScreenBloc.playParams.endSurahNumber =
                          playScreenBloc.playParams.startSurahNumber;
                      playScreenBloc.playParams.endAya =
                          SUR[playScreenBloc.playParams.startSurahNumber - 1]
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
          spacing: 16.w,
          children: [
            // to surah
            Expanded(
              child: AppDropdownMenu<int>(
                menuHeight: 300.h,
                enableFilter: true,
                requestFocusOnTap: true,
                expandedInsets: EdgeInsets.zero,
                initialSelection: playScreenBloc.playParams.endSurahNumber,
                dropdownMenuEntries: SUR
                    .skip(playScreenBloc.playParams.startSurahNumber - 1)
                    .map((e) => DropdownMenuEntry<int>(value: e.id, label: e.name))
                    .toList(),
                onSelected: (surahId) {
                  if (surahId != null) {
                    setState(() {
                      playScreenBloc.playParams.endSurahNumber = surahId;
                      playScreenBloc.playParams.endAya =
                          SUR[surahId - 1].versesCount;
                    });
                  }
                },
              ),
            ),
            // to aya
            AppDropdownMenu<int>(
              menuHeight: 300.h,
              enableFilter: true,
              requestFocusOnTap: true,
              initialSelection: playScreenBloc.playParams.endAya,
              dropdownMenuEntries: playScreenBloc.playParams.sameSurah
                  ? List.generate(
                      SUR[playScreenBloc.playParams.endSurahNumber - 1]
                              .versesCount -
                          playScreenBloc.playParams.startAya,
                      (index) {
                        return DropdownMenuEntry<int>(
                          value: index + playScreenBloc.playParams.startAya + 1,
                          label:
                              (index + playScreenBloc.playParams.startAya + 1)
                                  .toString(),
                        );
                      },
                    )
                  : List.generate(
                      SUR[playScreenBloc.playParams.endSurahNumber - 1]
                          .versesCount,
                      (index) {
                        return DropdownMenuEntry<int>(
                          value: index + 1,
                          label: (index + 1).toString(),
                        );
                      },
                    ),
              onSelected: (aya) {
                if (aya != null) {
                  setState(() {
                    playScreenBloc.playParams.endAya = aya;
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
