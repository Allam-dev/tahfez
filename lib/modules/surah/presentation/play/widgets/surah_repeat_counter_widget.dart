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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          children: [
            Text(context.tr(LocaleKeys.repeatAyaTimes)),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      playScreenBloc.playParams.ayaRepeatCount--;
                    });
                  },
                  icon: const Icon(Icons.remove),
                ),
                Text(playScreenBloc.playParams.ayaRepeatCount.toString()),
                IconButton(
                  onPressed: () {
                    setState(() {
                      playScreenBloc.playParams.ayaRepeatCount++;
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
                      playScreenBloc.playParams.sectionRepeatCount--;
                    });
                  },
                  icon: const Icon(Icons.remove),
                ),
                Text(playScreenBloc.playParams.sectionRepeatCount.toString()),
                IconButton(
                  onPressed: () {
                    setState(() {
                      playScreenBloc.playParams.sectionRepeatCount++;
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
