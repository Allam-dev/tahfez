part of '../play_settings_screen.dart';

class _StartButton extends StatelessWidget {
  const _StartButton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlaySettingsScreenCubit, PlaySettingsScreenState>(
      buildWhen: (previous, current) =>
          current.playbackInfo.playerState != previous.playbackInfo.playerState,
      builder: (context, state) {
        if (state.playbackInfo.playerState == SurahPlayerState.play) {
          return Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () =>
                      context.read<PlaySettingsScreenCubit>().pause(),
                  child: Icon(Icons.pause),
                ),
              ),
              20.horizontalSpace,
              Expanded(
                child: ElevatedButton(
                  onPressed: () =>
                      context.read<PlaySettingsScreenCubit>().stop(),
                  child: Icon(Icons.stop),
                ),
              ),
            ],
          );
        } else if (state.playbackInfo.playerState == SurahPlayerState.pause) {
          return Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () =>
                      context.read<PlaySettingsScreenCubit>().resume(),
                  child: Icon(Icons.play_arrow),
                ),
              ),
              20.horizontalSpace,

              Expanded(
                child: ElevatedButton(
                  onPressed: () =>
                      context.read<PlaySettingsScreenCubit>().stop(),
                  child: Icon(Icons.stop),
                ),
              ),
            ],
          );
        } else if (state.playbackInfo.playerState == SurahPlayerState.loading) {
          return ElevatedButton(
            onPressed: null,
            child: CircularProgressIndicator.adaptive(),
          );
        }
        return ElevatedButton(
          onPressed: () => context.read<PlaySettingsScreenCubit>().start(),
          child: Text(context.tr(LocaleKeys.start)),
        );
      },
    );
  }
}
