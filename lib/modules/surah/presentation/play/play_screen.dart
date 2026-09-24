import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tahfez/app/widgets/drawer/app_drawer.dart';
import 'package:tahfez/core/di/main_di.dart';
import 'package:tahfez/modules/surah/presentation/moshaf/moshaf_screen.dart';
import 'package:tahfez/modules/surah/presentation/play/cubit/play_screen_cubit.dart';
import 'package:tahfez/modules/surah/presentation/play_settings/play_settings_screen.dart';

class PlayScreen extends StatelessWidget {
  const PlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PlayScreenCubit(getIt()),
      child: Scaffold(
        appBar: AppBar(),
        drawer: const AppDrawer(),
        body: BlocBuilder<PlayScreenCubit, PlayScreenState>(
          builder: (context, state) {
            if (state is PlayScreenSettingsState) {
              return const PlaySettingsScreen();
            }
            return  MoshafScreen();
          },
        ),
      ),
    );
  }
}
