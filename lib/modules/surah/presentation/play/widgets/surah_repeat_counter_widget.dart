part of '../play_screen.dart';

class SurahRepeatCounterWidget extends StatefulWidget {
  const SurahRepeatCounterWidget({super.key});

  @override
  State<SurahRepeatCounterWidget> createState() =>
      _SurahRepeatCounterWidgetState();
}

class _SurahRepeatCounterWidgetState extends State<SurahRepeatCounterWidget> {
  @override
  Widget build(BuildContext context) {
    final playScreenBloc = context.read<PlayScreenCubit>();
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
                  _buildCounterControls(
                    count: playScreenBloc.playParams.ayaRepeatCount,
                    onDecrement: () {
                      if (playScreenBloc.playParams.ayaRepeatCount > 1) {
                        setState(() {
                          playScreenBloc.playParams.ayaRepeatCount--;
                        });
                      }
                    },
                    onIncrement: () {
                      setState(() {
                        playScreenBloc.playParams.ayaRepeatCount++;
                      });
                    },
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
                  _buildCounterControls(
                    count: playScreenBloc.playParams.sectionRepeatCount,
                    onDecrement: () {
                      if (playScreenBloc.playParams.sectionRepeatCount > 1) {
                        setState(() {
                          playScreenBloc.playParams.sectionRepeatCount--;
                        });
                      }
                    },
                    onIncrement: () {
                      setState(() {
                        playScreenBloc.playParams.sectionRepeatCount++;
                      });
                    },
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

  Widget _buildCounterControls({
    required int count,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildCounterBtn(icon: Icons.remove, onTap: onDecrement),
        SizedBox(
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
        ),
        _buildCounterBtn(icon: Icons.add, onTap: onIncrement),
      ],
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
