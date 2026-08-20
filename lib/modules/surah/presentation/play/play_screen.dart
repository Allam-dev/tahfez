import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tahfez/app/localization/locale_keys.g.dart';
import 'package:tahfez/app/style/colors/app_colors.dart';
import 'package:tahfez/app/widgets/app_drawer.dart';
import 'package:tahfez/core/di/main_di.dart';
import 'package:tahfez/core/extensions/context/showing.dart';
import 'package:tahfez/modules/reader/presentation/widgets/readers_dropdown.dart';
import 'package:tahfez/modules/surah/domain/models/surah_model.dart';
import 'package:tahfez/modules/surah/presentation/play/cubit/play_screen_cubit.dart';

part 'widgets/play_pause_button.dart';
part 'widgets/surah_dropdown.dart';
part 'widgets/surah_repeat_counter_widget.dart';

class PlayScreen extends StatelessWidget {
  const PlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PlayScreenCubit(getIt()),
      child: BlocListener<PlayScreenCubit, PlayScreenState>(
        listener: (context, state) {
          if (state is PlayScreenFailureState) {
            context.showErrorSnakeBar(state.failure);
          }
        },
        child: Builder(
          builder: (context) {
            final playScreenBloc = context.read<PlayScreenCubit>();
            return Scaffold(
              appBar: AppBar(),
              drawer: const AppDrawer(),
              body: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 30.h,
                  children: [
                    // readers dropdown
                    ReadersDropdown(
                      onChanged: (value) =>
                          playScreenBloc.playParams.reader = value,
                    ),
                    //  surah dropdown
                    SurahDropdown(),
                    // aya repeat count and section repeat count
                    SurahRepeatCounterWidget(),
                    // play button
                    PlayPauseButton(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
