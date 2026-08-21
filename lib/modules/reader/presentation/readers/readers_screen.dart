import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tahfez/app/localization/locale_keys.g.dart';
import 'package:tahfez/core/di/main_di.dart';
import 'package:tahfez/core/extensions/context/navigation.dart';
import 'package:tahfez/modules/reader/domain/models/reader_model.dart';
import 'package:tahfez/modules/reader/domain/reader_repo.dart';
import 'package:tahfez/modules/reader/presentation/readers/cubit/readers_screen_cubit.dart';
import 'package:tahfez/modules/surah/domain/repos/surah_downloader.dart';
import 'package:tahfez/modules/surah/presentation/reader_surah_list/reader_surah_list_screen.dart';

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
            if (state is ReadersScreenLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ReadersScreenError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 48.sp,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      context.tr(state.failure.message),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15.sp),
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton.icon(
                      onPressed: () =>
                          context.read<ReadersScreenCubit>().loadReaders(),
                      icon: const Icon(Icons.refresh_rounded),
                      label: Text(context.tr(LocaleKeys.retry)),
                    ),
                  ],
                ),
              );
            }

            final loaded = state as ReadersScreenLoaded;

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

class _ReaderCard extends StatelessWidget {
  final ReaderModel reader;
  final int downloadedCount;
  final bool isDownloading;
  final double overallProgress;

  const _ReaderCard({
    required this.reader,
    required this.downloadedCount,
    required this.isDownloading,
    required this.overallProgress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasDownloads = downloadedCount > 0;
    final isComplete = downloadedCount >= 114;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push(ReaderSurahListScreen(reader: reader)),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Reader name and rewaya
              Row(
                children: [
                  Icon(
                    Icons.person_rounded,
                    size: 24.sp,
                    color: theme.colorScheme.primary,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reader.name,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          reader.rewaya,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Download count badge
                  if (hasDownloads)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: isComplete
                            ? theme.colorScheme.primary.withValues(alpha: 0.15)
                            : theme.colorScheme.secondary.withValues(
                                alpha: 0.15,
                              ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$downloadedCount/114',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: isComplete
                              ? theme.colorScheme.primary
                              : theme.colorScheme.secondary,
                        ),
                      ),
                    ),
                  SizedBox(width: 4.w),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ],
              ),

              // Download progress bar (shown when downloading)
              if (isDownloading) ...[
                SizedBox(height: 12.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: overallProgress > 0 ? overallProgress : null,
                    minHeight: 4.h,
                  ),
                ),
              ],

              SizedBox(height: 12.h),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Delete button (shown when there are downloads)
                  if (hasDownloads && !isDownloading)
                    TextButton.icon(
                      onPressed: () => _showDeleteDialog(context),
                      icon: Icon(
                        Icons.delete_outline_rounded,
                        size: 18.sp,
                        color: theme.colorScheme.error,
                      ),
                      label: Text(
                        context.tr(LocaleKeys.delete),
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ),
                  const Spacer(),
                  // Download All button
                  if (!isComplete && !isDownloading)
                    FilledButton.icon(
                      onPressed: () => context
                          .read<ReadersScreenCubit>()
                          .downloadFullQuran(reader),
                      icon: Icon(Icons.download_rounded, size: 18.sp),
                      label: Text(context.tr(LocaleKeys.downloadAll)),
                    ),
                  if (isDownloading)
                    Chip(
                      avatar: SizedBox(
                        width: 16.sp,
                        height: 16.sp,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      ),
                      label: Text(
                        context.tr(LocaleKeys.downloading),
                        style: TextStyle(fontSize: 12.sp),
                      ),
                    ),
                  if (isComplete && !isDownloading)
                    Chip(
                      avatar: Icon(
                        Icons.check_circle_rounded,
                        size: 18.sp,
                        color: theme.colorScheme.primary,
                      ),
                      label: Text(
                        context.tr(LocaleKeys.completed),
                        style: TextStyle(fontSize: 12.sp),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.tr(LocaleKeys.delete)),
        content: Text(context.tr(LocaleKeys.deleteReaderConfirm)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(context.tr(LocaleKeys.cancel)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<ReadersScreenCubit>().deleteFullQuran(reader);
            },
            child: Text(
              context.tr(LocaleKeys.delete),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}
