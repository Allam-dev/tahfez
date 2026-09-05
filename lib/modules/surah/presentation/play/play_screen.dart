import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tahfez/app/localization/locale_keys.g.dart';
import 'package:tahfez/app/style/colors/app_colors.dart';
import 'package:tahfez/app/widgets/app_dropdown_menu.dart';
import 'package:tahfez/app/widgets/drawer/app_drawer.dart';
import 'package:tahfez/core/di/main_di.dart';
import 'package:tahfez/core/extensions/context/showing.dart';
import 'package:tahfez/modules/reader/presentation/widgets/readers_dropdown.dart';
import 'package:tahfez/modules/surah/domain/models/surah_model.dart';
import 'package:tahfez/modules/surah/presentation/play/cubit/play_screen_cubit.dart';
import 'package:tahfez/modules/surah/presentation/play/widgets/play_options_switch.dart';

part 'widgets/play_pause_button.dart';
part 'widgets/surah_dropdown.dart';
part 'widgets/surah_repeat_counter_widget.dart';

class PlayScreen extends StatelessWidget {
  const PlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PlayScreenCubit(getIt(), getIt()),
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
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section 1 & 2: Readers and Qiraah Dropdowns
                    ReadersDropdown(
                      onChanged: (value) =>
                          playScreenBloc.playParams.reader = value,
                    ),
                    24.verticalSpace,

                    // Section 3: Ayah Range
                    const SurahDropdown(),
                    24.verticalSpace,

                    // Section 4: Repeat Settings
                    const SurahRepeatCounterWidget(),
                    24.verticalSpace,

                    // Section 5: Options (Switches)
                    Text(
                      '5. ${context.tr(LocaleKeys.options)}',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.green600,
                      ),
                    ),
                    8.verticalSpace,
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 14.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.sand50,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: AppColors.sand200,
                          width: 1.w,
                        ),
                      ),
                      child: const PlayOptionsSwitch(),
                    ),
                    32.verticalSpace,

                    // Bottom Action Button (Start)
                    const PlayPauseButton(),
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
