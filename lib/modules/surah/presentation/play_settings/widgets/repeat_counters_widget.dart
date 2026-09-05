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
        Text(
          '4. ${context.tr(LocaleKeys.repeatSettings)}',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.green600,
          ),
        ),
        8.verticalSpace,
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: AppColors.sand50,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.sand200, width: 1.w),
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
                  BlocBuilder<PlaySettingsScreenCubit, PlaySettingsScreenState>(
                    buildWhen: (previous, current) =>
                        current.status == PlaySettingsScreenStatus.ayaRepetitionChanged,
                    builder: (context, state) {
                      return _counterText(
                        count: state.playParams.ayaRepeatCount,
                      );
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
                        color: AppColors.inkLight,
                      ),
                    ),
                  ),
                ],
              ),
              Divider(color: AppColors.sand200, height: 24.h),
              // Row 2: Repeat Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCounterBtn(
                    icon: Icons.remove,
                    onTap: playSettingsScreenCubit.decrementSectionRepetition,
                  ),
                  BlocBuilder<PlaySettingsScreenCubit, PlaySettingsScreenState>(
                    buildWhen: (previous, current) =>
                        current.status ==
                        PlaySettingsScreenStatus.sectionRepetitionChanged,
                    builder: (context, state) {
                      return _counterText(
                        count: state.playParams.sectionRepeatCount,
                      );
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
                        color: AppColors.inkLight,
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
          color: AppColors.inkLight,
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
            color: AppColors.sand100,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: AppColors.sand200, width: 1.w),
          ),
          child: Icon(icon, size: 18.sp, color: AppColors.green600),
        ),
      ),
    );
  }
}
