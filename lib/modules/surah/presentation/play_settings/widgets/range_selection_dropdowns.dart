part of '../play_settings_screen.dart';

class _RangeSelectionDropdowns extends StatelessWidget {
  const _RangeSelectionDropdowns();

  @override
  Widget build(BuildContext context) {
    final playSettingsScreenCubit = context.read<PlaySettingsScreenCubit>();
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
            // Row 1: Start Surah & Start Aya
            Row(
              children: [
                // Start Aya
                SizedBox(
                  width: 100.w,
                  child:
                      BlocBuilder<
                        PlaySettingsScreenCubit,
                        PlaySettingsScreenState
                      >(
                        buildWhen: (previous, current) =>
                            current.status ==
                            PlaySettingsScreenStatus.startSurahChanged,
                        builder: (context, state) {
                          return AppDropdownMenu<int>(
                            menuHeight: 300.h,
                            enableFilter: true,
                            requestFocusOnTap: true,
                            initialSelection: state.playParams.startAya,
                            label: Text(context.tr(LocaleKeys.ayah)),
                            dropdownMenuEntries: List.generate(
                              SUR[state.playParams.startSurahNumber - 1]
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
                      BlocBuilder<
                        PlaySettingsScreenCubit,
                        PlaySettingsScreenState
                      >(
                        buildWhen: (previous, current) =>
                            current.status == PlaySettingsScreenStatus.inital,
                        builder: (context, state) {
                          return AppDropdownMenu<int>(
                            menuHeight: 300.h,
                            enableFilter: true,
                            requestFocusOnTap: true,
                            expandedInsets: EdgeInsets.zero,
                            initialSelection: state.playParams.startSurahNumber,
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
                  width: 100.w,
                  child:
                      BlocBuilder<
                        PlaySettingsScreenCubit,
                        PlaySettingsScreenState
                      >(
                        buildWhen: (previous, current) =>
                            current.status ==
                                PlaySettingsScreenStatus.startSurahChanged ||
                            current.status ==
                                PlaySettingsScreenStatus.endSurahChanged ||
                            current.status ==
                                PlaySettingsScreenStatus.startAyaChanged,
                        builder: (context, state) {
                          return AppDropdownMenu<int>(
                            menuHeight: 300.h,
                            enableFilter: true,
                            requestFocusOnTap: true,
                            initialSelection: state.playParams.endAya,
                            label: Text(context.tr(LocaleKeys.ayah)),
                            dropdownMenuEntries: state.playParams.sameSurah
                                ? List.generate(
                                    SUR[state.playParams.endSurahNumber - 1]
                                            .versesCount -
                                        state.playParams.startAya +
                                        1,
                                    (index) {
                                      return DropdownMenuEntry<int>(
                                        value:
                                            index + state.playParams.startAya,
                                        label:
                                            (index + state.playParams.startAya)
                                                .toString(),
                                      );
                                    },
                                  )
                                : List.generate(
                                    SUR[state.playParams.endSurahNumber - 1]
                                        .versesCount,
                                    (index) {
                                      return DropdownMenuEntry<int>(
                                        value: index + 1,
                                        label: (index + 1).toString(),
                                      );
                                    },
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
                      BlocBuilder<
                        PlaySettingsScreenCubit,
                        PlaySettingsScreenState
                      >(
                        buildWhen: (previous, current) =>
                            current.status ==
                                PlaySettingsScreenStatus.startSurahChanged ||
                            current.status ==
                                PlaySettingsScreenStatus.startAyaChanged,
                        builder: (context, state) {
                          return AppDropdownMenu<int>(
                            menuHeight: 300.h,
                            enableFilter: true,
                            requestFocusOnTap: true,
                            expandedInsets: EdgeInsets.zero,
                            initialSelection: state.playParams.endSurahNumber,
                            label: Text(context.tr(LocaleKeys.toSurah)),
                            dropdownMenuEntries: SUR
                                .skip(state.playParams.startSurahNumber - 1)
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
}
