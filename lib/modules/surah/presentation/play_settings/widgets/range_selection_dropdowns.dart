part of '../play_settings_screen.dart';

class _RangeSelectionDropdowns extends StatelessWidget {
  const _RangeSelectionDropdowns();

  @override
  Widget build(BuildContext context) {
    final playSettingsScreenCubit = context.read<PlaySettingsScreenCubit>();
    final enabled = context.select<PlaySettingsScreenCubit, bool>(
      (cubit) => cubit.state.playbackInfo.playerState.isIdel,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TitleText(text: context.tr(LocaleKeys.ayahRange), number: 2),
        8.verticalSpace,

        Column(
          children: [
            // Row 1: Start Surah & Start Aya
            Row(
              children: [
                // Start Aya
                SizedBox(
                  width: 110.w,
                  child:
                      BlocSelector<
                        PlaySettingsScreenCubit,
                        PlaySettingsScreenState,
                        int
                      >(
                        selector: (state) => state.playParams.startAya,
                        builder: (context, value) {
                          return AppDropdownMenu<int>(
                            enabled: enabled,
                            menuHeight: 300.h,
                            enableFilter: true,
                            keyboardType: TextInputType.number,
                            requestFocusOnTap: true,
                            initialSelection: value,
                            label: Text(context.tr(LocaleKeys.ayah)),
                            dropdownMenuEntries: List.generate(
                              SUR[playSettingsScreenCubit
                                          .state
                                          .playParams
                                          .startSurahNumber -
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
                              playSettingsScreenCubit.changeStartAya(aya);
                            },
                          );
                        },
                      ),
                ),
                8.horizontalSpace,
                // Start Surah
                Expanded(
                  child:
                      BlocSelector<
                        PlaySettingsScreenCubit,
                        PlaySettingsScreenState,
                        int
                      >(
                        selector: (state) => state.playParams.startSurahNumber,
                        builder: (context, value) {
                          return AppDropdownMenu<int>(
                            enabled: enabled,
                            menuHeight: 300.h,
                            enableFilter: true,
                            requestFocusOnTap: true,
                            expandedInsets: EdgeInsets.zero,
                            initialSelection: value,
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
                              playSettingsScreenCubit.changeStartSurah(surah);
                            },
                          );
                        },
                      ),
                ),
              ],
            ),
            16.verticalSpace,

            // Row 2: End Surah & End Aya
            Row(
              children: [
                // End Aya
                SizedBox(
                  width: 110.w,
                  child:
                      BlocSelector<
                        PlaySettingsScreenCubit,
                        PlaySettingsScreenState,
                        int
                      >(
                        selector: (state) => state.playParams.endAya,
                        builder: (context, value) {
                          return AppDropdownMenu<int>(
                            enabled: enabled,

                            menuHeight: 300.h,
                            enableFilter: true,
                            keyboardType: TextInputType.number,
                            requestFocusOnTap: true,
                            initialSelection: value,
                            label: Text(context.tr(LocaleKeys.ayah)),
                            dropdownMenuEntries: _getEndAyaOptions(
                              playSettingsScreenCubit.state,
                            ),
                            onSelected: (aya) {
                              playSettingsScreenCubit.changeEndAya(aya);
                            },
                          );
                        },
                      ),
                ),
                8.horizontalSpace,
                // End Surah
                Expanded(
                  child:
                      BlocSelector<
                        PlaySettingsScreenCubit,
                        PlaySettingsScreenState,
                        int
                      >(
                        selector: (state) => state.playParams.endSurahNumber,
                        builder: (context, value) {
                          return AppDropdownMenu<int>(
                            enabled: enabled,

                            menuHeight: 300.h,
                            enableFilter: true,
                            requestFocusOnTap: true,
                            expandedInsets: EdgeInsets.zero,
                            initialSelection: value,
                            label: Text(context.tr(LocaleKeys.toSurah)),
                            dropdownMenuEntries: SUR
                                .skip(
                                  playSettingsScreenCubit
                                          .state
                                          .playParams
                                          .startSurahNumber -
                                      1,
                                )
                                .map(
                                  (e) => DropdownMenuEntry<int>(
                                    value: e.id,
                                    label: e.name,
                                  ),
                                )
                                .toList(),
                            onSelected: (surah) {
                              playSettingsScreenCubit.changeEndSurah(surah);
                            },
                          );
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
  }

  List<DropdownMenuEntry<int>> _getEndAyaOptions(
    PlaySettingsScreenState state,
  ) {
    if (state.playParams.sameSurah) {
      return List.generate(
        SUR[state.playParams.endSurahNumber - 1].versesCount -
            state.playParams.startAya +
            1,
        (index) {
          return DropdownMenuEntry<int>(
            value: index + state.playParams.startAya,
            label: (index + state.playParams.startAya).toString(),
          );
        },
      );
    } else {
      return List.generate(
        SUR[state.playParams.endSurahNumber - 1].versesCount,
        (index) {
          return DropdownMenuEntry<int>(
            value: index + 1,
            label: (index + 1).toString(),
          );
        },
      );
    }
  }
}
