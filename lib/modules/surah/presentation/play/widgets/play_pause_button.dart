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
          return ElevatedButton(
            onPressed: () {},
            child: const CircularProgressIndicator(color: AppColors.teal50),
          );
        } else if (state is PlayScreenPlayingState ||
            state is PlayScreenPauseState) {
          return Row(
            children: [
              Expanded(
                child: state is PlayScreenPlayingState
                    ? ElevatedButton(
                        onPressed: playScreenCubit.pause,
                        child: const Icon(Icons.pause),
                      )
                    : ElevatedButton(
                        onPressed: playScreenCubit.resume,
                        child: const Icon(Icons.play_arrow),
                      ),
              ),
              16.horizontalSpace,
              Expanded(
                child: ElevatedButton(
                  onPressed: playScreenCubit.stop,
                  child: const Icon(Icons.stop),
                ),
              ),
            ],
          );
        }
        return ElevatedButton(
          onPressed: playScreenCubit.play,
          child: const Icon(Icons.play_arrow),
        );
      },
    );
  }
}
