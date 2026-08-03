import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tahfez/app/localization/locale_keys.g.dart';
import 'package:tahfez/core/di/main_di.dart';
import 'package:tahfez/modules/reader/presentation/widgets/readers_dropdown.dart';
import 'package:tahfez/modules/surah/presentation/play/cubit/play_screen_cubit.dart';
import 'package:tahfez/modules/surah/presentation/play/widgets/surah_dropdown.dart';

import 'widgets/surah_repeat_counter_widget.dart';

class PlayScreen extends StatelessWidget {
  const PlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PlayScreenCubit(getIt()),
      child: Builder(
        builder: (context) {
          final playScreenCubit = context.read<PlayScreenCubit>();
          return Scaffold(
            appBar: AppBar(),
            body: Column(
              spacing: 30.h,
              children: [
                // readers dropdown
                ReadersDropdown(
                  onChanged: (value) =>
                      playScreenCubit.playParams.reader = value,
                ),
                //  surah dropdown
                SurahDropdown(),

                // aya repeat count and section repeat count
                SurahRepeatCounterWidget(),
                // play button
                ElevatedButton(
                  onPressed: playScreenCubit.play,
                  child: Text(LocaleKeys.play),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
