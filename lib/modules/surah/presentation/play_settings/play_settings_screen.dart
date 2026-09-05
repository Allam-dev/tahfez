import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tahfez/app/localization/locale_keys.g.dart';
import 'package:tahfez/app/style/colors/app_colors.dart';
import 'package:tahfez/app/widgets/app_dropdown_menu.dart';
import 'package:tahfez/app/widgets/drawer/app_drawer.dart';
import 'package:tahfez/core/extensions/context/showing.dart';
import 'package:tahfez/modules/reader/presentation/widgets/readers_dropdown.dart';
import 'package:tahfez/modules/surah/domain/models/surah_model.dart';
import 'package:tahfez/modules/surah/presentation/play_settings/cubit/play_settings_screen_cubit.dart';

part 'widgets/start_button.dart';
part 'widgets/range_selection_dropdowns.dart';
part 'widgets/repeat_counters_widget.dart';
part 'widgets/play_options_switches.dart';

class PlaySettingsScreen extends StatelessWidget {
  const PlaySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PlaySettingsScreenCubit(),
      child: BlocListener<PlaySettingsScreenCubit, PlaySettingsScreenState>(
        listener: (context, state) {
          if (state.status == PlaySettingsScreenStatus.error &&
              state.failure != null) {
            context.showErrorSnakeBar(state.failure!);
          }
        },
        child: Builder(
          builder: (context) {
            final playSettingsScreenCubit = context
                .read<PlaySettingsScreenCubit>();
            return Scaffold(
              appBar: AppBar(),
              drawer: const AppDrawer(),
              body: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section 1 & 2: Readers and Qiraah Dropdowns
                    ReadersDropdown(
                      onChanged: (value) =>
                          playSettingsScreenCubit.changeReader(value),
                    ),
                    24.verticalSpace,

                    // Section 3: Ayah Range
                    const _RangeSelectionDropdowns(),
                    24.verticalSpace,

                    // Section 4: Repeat Settings
                    const _RepeatCountersWidget(),
                    24.verticalSpace,

                    // Section 5: Options (Switches)
                    const _PlayOptionsSwitch(),
                    32.verticalSpace,

                    // Bottom Action Button (Start)
                    const _StartButton(),
                    24.verticalSpace,
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
