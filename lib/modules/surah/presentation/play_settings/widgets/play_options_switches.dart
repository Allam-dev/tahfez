part of '../play_settings_screen.dart';

class _PlayOptionsSwitch extends StatelessWidget {
  const _PlayOptionsSwitch();

  @override
  Widget build(BuildContext context) {
    final playSettingsScreenCubit = context.read<PlaySettingsScreenCubit>();
    return Column(
      children: [
        Text(
          '5. ${context.tr(LocaleKeys.options)}',
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
          child: BlocBuilder<PlaySettingsScreenCubit, PlaySettingsScreenState>(
            buildWhen: (previous, current) =>
                current.status == PlaySettingsScreenStatus.switchChanged,
            builder: (context, state) {
              return Column(
                spacing: 12.h,
                children: [
                  _SwitchRow(
                    label: context.tr(LocaleKeys.playAudio),
                    value: state.playAudio,
                    onChanged: playSettingsScreenCubit.playAudio,
                  ),
                  _SwitchRow(
                    label: context.tr(LocaleKeys.downloadWhilePlaying),
                    value: state.downloadWhilePlaying,
                    onChanged: playSettingsScreenCubit.downloadWhilePlaying,
                  ),
                  _SwitchRow(
                    label: context.tr(LocaleKeys.downloadOnly),
                    value: state.downloadingOnly,
                    onChanged: playSettingsScreenCubit.downloadOnly,
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeTrackColor: AppColors.green500,
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: AppColors.sand200,
        ),
        Expanded(
          child: Text(
            label,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.inkLight,
            ),
          ),
        ),
      ],
    );
  }
}
