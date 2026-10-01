import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tahfez/app/localization/locale_keys.g.dart';
import 'package:tahfez/core/di/main_di.dart';
import 'package:tahfez/core/extensions/context/showing.dart';
import 'package:tahfez/core/extensions/context/theme.dart';
import 'package:tahfez/core/extensions/string/validations.dart';
import 'package:tahfez/modules/reader/domain/models/reader_model.dart';
import 'package:tahfez/modules/surah/domain/enums/surah_download_status.dart';
import 'package:tahfez/modules/surah/domain/models/surah_model.dart';
import 'package:tahfez/modules/surah/presentation/downloads/cubit/downloads_cubit.dart';

part 'widgets/downloaded_tab.dart';
part 'widgets/downloading_tab.dart';

class DownloadsScreen extends StatelessWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DownloadsCubit(getIt(), getIt()),
      child: BlocListener<DownloadsCubit, DownloadsState>(
        listener: (context, state) {
          if (state.failure != null) {
            context.showErrorSnakeBar(state.failure!);
          } else if (state.message.hasValue) {
            context.showSuccessSnackBar(context.tr(state.message!));
          }
        },
        child: DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                context.tr(LocaleKeys.downloads),
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              bottom: TabBar(
                indicatorColor: context.theme.colorScheme.primary,
                labelColor: context.theme.colorScheme.primary,
                unselectedLabelColor:
                    context.theme.colorScheme.onSurface.withValues(alpha: 0.6),
                labelStyle: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelStyle: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.normal,
                ),
                tabs: [
                  Tab(text: context.tr(LocaleKeys.currentlyDownloading)),
                  Tab(text: context.tr(LocaleKeys.downloadedFiles)),
                ],
              ),
            ),
            body: const TabBarView(
              children: [
                _DownloadingTab(),
                _DownloadedTab(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
