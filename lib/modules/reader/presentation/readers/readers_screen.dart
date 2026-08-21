import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tahfez/app/localization/locale_keys.g.dart';
import 'package:tahfez/app/widgets/failure/failure_widget.dart';
import 'package:tahfez/core/di/main_di.dart';
import 'package:tahfez/core/extensions/context/navigation.dart';
import 'package:tahfez/modules/reader/domain/models/reader_model.dart';
import 'package:tahfez/modules/reader/domain/reader_repo.dart';
import 'package:tahfez/modules/reader/presentation/readers/cubit/readers_screen_cubit.dart';
import 'package:tahfez/modules/surah/domain/repos/surah_downloader.dart';
import 'package:tahfez/modules/surah/presentation/reader_surah_list/reader_surah_list_screen.dart';

part 'widgets/reader_card.dart';

class ReadersScreen extends StatelessWidget {
  const ReadersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ReadersScreenCubit(
        readerRepo: getIt<ReaderRepo>(),
        surahDownloader: getIt<SurahDownloader>(),
      ),
      child: Scaffold(
        appBar: AppBar(title: Text(context.tr(LocaleKeys.downloads))),
        body: BlocBuilder<ReadersScreenCubit, ReadersScreenState>(
          builder: (context, state) {
            if (state is ReadersScreenLoadingState) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ReadersScreenFailureState) {
              return FailureWidget(failure: state.failure);
            }

            final loaded = state as ReadersScreenLoadedState;

            if (loaded.readers.isEmpty) {
              return Center(
                child: Text(
                  context.tr(LocaleKeys.noReadersFound),
                  style: TextStyle(fontSize: 15.sp),
                ),
              );
            }

            return ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              itemCount: loaded.readers.length,
              separatorBuilder: (_, _) => SizedBox(height: 10.h),
              itemBuilder: (context, index) {
                final reader = loaded.readers[index];
                return _ReaderCard(
                  reader: reader,
                  downloadedCount: loaded.downloadedCounts[reader.id] ?? 0,
                  isDownloading: loaded.isReaderDownloading(reader.id),
                  overallProgress: loaded.readerOverallProgress(reader.id),
                );
              },
            );
          },
        ),
      ),
    );
  }
}


