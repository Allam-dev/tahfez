part of '../play_settings_screen.dart';

class _RepeatCountersWidget extends StatefulWidget {
  const _RepeatCountersWidget();

  @override
  State<_RepeatCountersWidget> createState() => _RepeatCountersWidgetState();
}

class _RepeatCountersWidgetState extends State<_RepeatCountersWidget> {
  @override
  Widget build(BuildContext context) {
    final playSettingsScreenCubit = context.read<PlaySettingsScreenCubit>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TitleText(number: 3, text: context.tr(LocaleKeys.repeatSettings)),

        8.verticalSpace,
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: context.theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: context.theme.colorScheme.outline,
              width: 1.w,
            ),
          ),
          child: Column(
            children: [
              // Row 1: Repeat Ayah
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCounterBtn(
                    icon: Icons.remove,
                    onTap: playSettingsScreenCubit.decrementAyaRepetition,
                  ),
                  BlocSelector<
                    PlaySettingsScreenCubit,
                    PlaySettingsScreenState,
                    int
                  >(
                    selector: (state) => state.playParams.ayaRepeatCount,
                    builder: (context, value) {
                      return _counterText(count: value);
                    },
                  ),
                  _buildCounterBtn(
                    icon: Icons.add,
                    onTap: playSettingsScreenCubit.incrementAyaRepetition,
                  ),
                  Expanded(
                    child: Text(
                      context.tr(LocaleKeys.repeatEachAyah),
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: context.theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              Divider(color: context.theme.colorScheme.outline, height: 24.h),
              // Row 2: Repeat Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCounterBtn(
                    icon: Icons.remove,
                    onTap: playSettingsScreenCubit.decrementSectionRepetition,
                  ),
                  BlocSelector<
                    PlaySettingsScreenCubit,
                    PlaySettingsScreenState,
                    int
                  >(
                    selector: (state) => state.playParams.sectionRepeatCount,
                    builder: (context, value) {
                      return _counterText(count: value);
                    },
                  ),
                  _buildCounterBtn(
                    icon: Icons.add,
                    onTap: playSettingsScreenCubit.incrementSectionRepetition,
                  ),
                  Expanded(
                    child: Text(
                      context.tr(LocaleKeys.repeatWholeSection),
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: context.theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _counterText({required int count}) {
    return SizedBox(
      width: 36.w,
      child: Text(
        count.toString(),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
          color: context.theme.colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildCounterBtn({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          width: 32.w,
          height: 32.h,
          decoration: BoxDecoration(
            color: context.theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: context.theme.colorScheme.outline,
              width: 1.w,
            ),
          ),
          child: Icon(
            icon,
            size: 18.sp,
            color: context.theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
