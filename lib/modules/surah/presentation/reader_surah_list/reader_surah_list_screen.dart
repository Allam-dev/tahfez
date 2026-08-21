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
            if (state is ReaderSurahListLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final loaded = state as ReaderSurahListLoaded;

            return ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              itemCount: SUR.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
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

class _SurahTile extends StatelessWidget {
  final SurahModel surah;
  final bool isDownloaded;
  final bool isDownloading;
  final double progress;

  /// True when a full-Quran download is running — blocks individual downloads.
  final bool isLocked;

  const _SurahTile({
    required this.surah,
    required this.isDownloaded,
    required this.isDownloading,
    required this.progress,
    required this.isLocked,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      leading: Container(
        width: 40.w,
        height: 40.w,
        decoration: BoxDecoration(
          color: isDownloaded
              ? theme.colorScheme.primary.withValues(alpha: 0.12)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDownloaded
                ? theme.colorScheme.primary.withValues(alpha: 0.3)
                : theme.colorScheme.outline,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          surah.id.toString(),
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: isDownloaded
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface,
          ),
        ),
      ),
      title: Text(
        surah.name,
        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
      ),
      subtitle: isDownloading
          ? Padding(
              padding: EdgeInsets.only(top: 6.h),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: progress > 0 ? progress : null,
                  minHeight: 3.h,
                ),
              ),
            )
          : null,
      trailing: _buildTrailing(context, theme, progress),
    );
  }

  Widget _buildTrailing(
    BuildContext context,
    ThemeData theme,
    double progress,
  ) {
    if (isDownloading) {
      /// return SizedBox(
      ///   width: 24.sp,
      ///   height: 24.sp,
      ///   child: const CircularProgressIndicator(strokeWidth: 2),
      /// );
      return Text(
        "${(progress * 100).round()}%",
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.primary,
        ),
      );
    }

    if (isDownloaded) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_rounded,
            color: theme.colorScheme.primary,
            size: 22.sp,
          ),
          SizedBox(width: 4.w),
          IconButton(
            onPressed: () =>
                context.read<ReaderSurahListCubit>().deleteSurah(surah.id),
            icon: Icon(
              Icons.delete_outline_rounded,
              color: theme.colorScheme.error,
              size: 20.sp,
            ),
            tooltip: context.tr(LocaleKeys.delete),
            visualDensity: VisualDensity.compact,
          ),
        ],
      );
    }

    // Not downloaded — show download button (disabled if full Quran is running)
    return IconButton(
      onPressed: isLocked
          ? null
          : () => context.read<ReaderSurahListCubit>().downloadSurah(surah.id),
      icon: Icon(
        Icons.download_rounded,
        size: 22.sp,
        color: isLocked
            ? theme.colorScheme.onSurface.withValues(alpha: 0.3)
            : theme.colorScheme.primary,
      ),
      tooltip: isLocked
          ? context.tr(LocaleKeys.fullQuranDownloading)
          : context.tr(LocaleKeys.downloadSurah),
    );
  }
}
