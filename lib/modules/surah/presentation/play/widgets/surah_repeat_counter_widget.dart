import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tahfez/app/localization/locale_keys.g.dart';
import 'package:tahfez/modules/surah/presentation/play/cubit/play_screen_cubit.dart';

class SurahRepeatCounterWidget extends StatefulWidget {
  const SurahRepeatCounterWidget({super.key});

  @override
  State<SurahRepeatCounterWidget> createState() =>
      _SurahRepeatCounterWidgetState();
}

class _SurahRepeatCounterWidgetState extends State<SurahRepeatCounterWidget> {
  @override
  Widget build(BuildContext context) {
    final playScreenCubit = context.read<PlayScreenCubit>();
    return Row(
      children: [
        Column(
          children: [
            Text(context.tr(LocaleKeys.repeatAyaTimes)),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      playScreenCubit.playParams.ayaRepeatCount--;
                    });
                  },
                  icon: const Icon(Icons.remove),
                ),
                Text(playScreenCubit.playParams.ayaRepeatCount.toString()),
                IconButton(
                  onPressed: () {
                    setState(() {
                      playScreenCubit.playParams.ayaRepeatCount++;
                    });
                  },
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ],
        ),
        Column(
          children: [
            Text(context.tr(LocaleKeys.repeatSectionTimes)),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      playScreenCubit.playParams.sectionRepeatCount--;
                    });
                  },
                  icon: const Icon(Icons.remove),
                ),
                Text(playScreenCubit.playParams.sectionRepeatCount.toString()),
                IconButton(
                  onPressed: () {
                    setState(() {
                      playScreenCubit.playParams.sectionRepeatCount++;
                    });
                  },
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
