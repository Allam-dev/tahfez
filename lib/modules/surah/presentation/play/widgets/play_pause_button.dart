part of '../play_screen.dart';

class PlayPauseButton extends StatelessWidget {
  const PlayPauseButton({super.key});

  @override
  Widget build(BuildContext context) {
    final PlayScreenCubit playScreenCubit = context.read<PlayScreenCubit>();
    return BlocBuilder<PlayScreenCubit, PlayScreenState>(
      buildWhen: (previous, current) => current != previous,
      builder: (context, state) {
        if (state is PlayScreenLoadingState) {
          return SizedBox(
            width: double.infinity,
            height: 52.h,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green600,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
              child: const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              ),
            ),
          );
        } else if (state is PlayScreenPlayingState ||
            state is PlayScreenPauseState) {
          return Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 52.h,
                  child: state is PlayScreenPlayingState
                      ? ElevatedButton.icon(
                          onPressed: playScreenCubit.pause,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.green600,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                          ),
                          icon: const Icon(Icons.pause, color: Colors.white),
                          label: Text(
                            'إيقاف مؤقت',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : ElevatedButton.icon(
                          onPressed: playScreenCubit.resume,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.green600,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                          ),
                          icon: const Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                          ),
                          label: Text(
                            'استئناف',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                ),
              ),
              12.horizontalSpace,
              SizedBox(
                height: 52.h,
                child: ElevatedButton(
                  onPressed: playScreenCubit.stop,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                  child: const Icon(Icons.stop, color: Colors.white),
                ),
              ),
            ],
          );
        }

        return SizedBox(
          width: double.infinity,
          height: 52.h,
          child: ElevatedButton(
            onPressed: playScreenCubit.play,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.green600,

              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
            child: Text(
              context.tr(LocaleKeys.start),
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}
