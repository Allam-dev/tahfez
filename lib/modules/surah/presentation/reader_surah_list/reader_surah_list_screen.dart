import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tahfez/app/localization/locale_keys.g.dart';
import 'package:tahfez/core/di/main_di.dart';
import 'package:tahfez/modules/reader/domain/models/reader_model.dart';
import 'package:tahfez/modules/surah/domain/models/surah_model.dart';
import 'package:tahfez/modules/surah/domain/repos/surah_downloader.dart';
import 'package:tahfez/modules/surah/presentation/reader_surah_list/cubit/reader_surah_list_cubit.dart';

part 'widgets/surah_tile.dart';

class ReaderSurahListScreen extends StatelessWidget {
  final ReaderModel reader;

  const ReaderSurahListScreen({super.key, required this.reader});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ReaderSurahListCubit(
        reader: reader,
        surahDownloader: getIt<SurahDownloader>(),
      ),
      child: Scaffold(
        appBar: AppBar(title: Text(reader.nameWithRewaya)),
        body: BlocBuilder<ReaderSurahListCubit, ReaderSurahListState>(
          builder: (context, state) {
            if (state is ReaderSurahListLoadingState) {
              return const Center(child: CircularProgressIndicator());
            }

            final loaded = state as ReaderSurahListLoadedState;

            return ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              itemCount: SUR.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final surah = SUR[index];
                final surahNumber = surah.id;
                final isDownloaded = loaded.isSurahDownloaded(surahNumber);
                final isDownloading = loaded.isSurahDownloading(surahNumber);
                final progress = loaded.surahProgress(surahNumber);
                final isLocked = loaded.isFullQuranDownloading;

                return _SurahTile(
                  surah: surah,
                  isDownloaded: isDownloaded,
                  isDownloading: isDownloading,
                  progress: progress,
                  isLocked: isLocked,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
