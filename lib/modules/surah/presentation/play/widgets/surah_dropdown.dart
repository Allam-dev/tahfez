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
    return BlocBuilder<PlayScreenCubit, PlayScreenState>(
      buildWhen: (previous, current) =>
          current is PlayScreenUpdatePlayingParamState,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '3. ${context.tr(LocaleKeys.ayahRange)}',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.green600,
              ),
            ),
            8.verticalSpace,

            Column(
              children: [
                // Row 1: From Surah & From Aya
                Row(
                  children: [
                    // From Aya
                    SizedBox(
                      width: 100.w,
                      child: AppDropdownMenu<int>(
                        menuHeight: 300.h,
                        enableFilter: true,
                        requestFocusOnTap: true,
                        initialSelection: playScreenBloc.playParams.startAya,
                        label: Text(context.tr(LocaleKeys.ayah)),
                        dropdownMenuEntries: List.generate(
                          SUR[playScreenBloc.playParams.startSurahNumber - 1]
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
                              playScreenBloc.playParams.startAya = aya;
                              if (aya >=
                                  SUR[playScreenBloc
                                              .playParams
                                              .startSurahNumber -
                                          1]
                                      .versesCount) {
                                playScreenBloc.playParams.endSurahNumber =
                                    playScreenBloc.playParams.startSurahNumber +
                                    1;
                                playScreenBloc.playParams.endAya = 1;
                              } else {
                                playScreenBloc.playParams.endSurahNumber =
                                    playScreenBloc.playParams.startSurahNumber;
                                playScreenBloc.playParams.endAya =
                                    SUR[playScreenBloc
                                                .playParams
                                                .startSurahNumber -
                                            1]
                                        .versesCount;
                              }
                            });
                          }
                        },
                      ),
                    ),
                    8.horizontalSpace,
                    // From Surah
                    Expanded(
                      child: AppDropdownMenu<int>(
                        menuHeight: 300.h,
                        enableFilter: true,
                        requestFocusOnTap: true,
                        expandedInsets: EdgeInsets.zero,
                        initialSelection:
                            playScreenBloc.playParams.startSurahNumber,
                        label: Text(context.tr(LocaleKeys.fromSurah)),
                        dropdownMenuEntries: SUR
                            .map(
                              (e) => DropdownMenuEntry<int>(
                                value: e.id,
                                label: e.name,
                              ),
                            )
                            .toList(),
                        onSelected: (surah) {
                          if (surah != null) {
                            setState(() {
                              playScreenBloc.playParams.startSurahNumber =
                                  surah;
                              playScreenBloc.playParams.startAya = 1;
                              playScreenBloc.playParams.endSurahNumber = surah;
                              playScreenBloc.playParams.endAya =
                                  SUR[surah - 1].versesCount;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                16.verticalSpace,

                // Row 2: To Surah & To Aya
                Row(
                  children: [
                    // To Aya
                    SizedBox(
                      width: 100.w,
                      child: AppDropdownMenu<int>(
                        menuHeight: 300.h,
                        enableFilter: true,
                        requestFocusOnTap: true,
                        initialSelection: playScreenBloc.playParams.endAya,
                        label: Text(context.tr(LocaleKeys.ayah)),
                        dropdownMenuEntries: playScreenBloc.playParams.sameSurah
                            ? List.generate(
                                SUR[playScreenBloc.playParams.endSurahNumber -
                                            1]
                                        .versesCount -
                                    playScreenBloc.playParams.startAya +
                                    1,
                                (index) {
                                  return DropdownMenuEntry<int>(
                                    value:
                                        index +
                                        playScreenBloc.playParams.startAya,
                                    label:
                                        (index +
                                                playScreenBloc
                                                    .playParams
                                                    .startAya)
                                            .toString(),
                                  );
                                },
                              )
                            : List.generate(
                                SUR[playScreenBloc.playParams.endSurahNumber -
                                        1]
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
                    ),
                    8.horizontalSpace,
                    // To Surah
                    Expanded(
                      child: AppDropdownMenu<int>(
                        menuHeight: 300.h,
                        enableFilter: true,
                        requestFocusOnTap: true,
                        expandedInsets: EdgeInsets.zero,
                        initialSelection:
                            playScreenBloc.playParams.endSurahNumber,
                        label: Text(context.tr(LocaleKeys.toSurah)),
                        dropdownMenuEntries: SUR
                            .skip(
                              playScreenBloc.playParams.startSurahNumber - 1,
                            )
                            .map(
                              (e) => DropdownMenuEntry<int>(
                                value: e.id,
                                label: e.name,
                              ),
                            )
                            .toList(),
                        onSelected: (surahId) {
                          if (surahId != null) {
                            setState(() {
                              playScreenBloc.playParams.endSurahNumber =
                                  surahId;
                              playScreenBloc.playParams.endAya =
                                  SUR[surahId - 1].versesCount;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],

              /// ),
            ),
          ],
        );
      },
    );
  }
}
