import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tahfez/modules/surah/presentation/play/cubit/play_screen_cubit.dart';

class PlayPauseButton extends StatelessWidget {
  const PlayPauseButton({super.key});

  @override
  Widget build(BuildContext context) {
    final PlayScreenCubit playScreenCubit = context.read<PlayScreenCubit>();
    return BlocBuilder<PlayScreenCubit, PlayScreenState>(
      builder: (context, state) {
        if (state is PlayScreenPlayingState) {
          return Row(
            children: [
              ElevatedButton(
                onPressed: playScreenCubit.pause,
                child: const Icon(Icons.pause),
              ),
              ElevatedButton(
                onPressed: playScreenCubit.stop,
                child: const Icon(Icons.stop),
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
