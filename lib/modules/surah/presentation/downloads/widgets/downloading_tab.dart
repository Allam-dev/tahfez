part of '../downloads_screen.dart';

class _DownloadingTab extends StatelessWidget {
  const _DownloadingTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DownloadsCubit, DownloadsState>(
      builder: (context, state) {
        if (state.downloadingItems.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cloud_download_outlined,
                  size: 64.r,
                  color: context.theme.colorScheme.onSurface.withValues(alpha: 0.3),
                ),
                16.verticalSpace,
                Text(
                  context.tr(LocaleKeys.noActiveDownloads),
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: context.theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          itemCount: state.downloadingItems.length,
          separatorBuilder: (_, _) => 12.verticalSpace,
          itemBuilder: (context, index) {
            final item = state.downloadingItems[index];
            final isFailed = item.status == SurahDownloadStatus.failed;
            final percentage = (item.progress * 100).toInt();

            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
                side: BorderSide(
                  color: isFailed
                      ? context.theme.colorScheme.error.withValues(alpha: 0.5)
                      : context.theme.colorScheme.outline,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.surahName,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: context.theme.colorScheme.onSurface,
                                ),
                              ),
                              4.verticalSpace,
                              Text(
                                item.readerName,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: context.theme.colorScheme.onSurface
                                      .withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isFailed)
                          TextButton.icon(
                            style: TextButton.styleFrom(
                              foregroundColor: context.theme.colorScheme.error,
                            ),
                            onPressed: () {
                              context.read<DownloadsCubit>().retryDownload(item);
                            },
                            icon: const Icon(Icons.refresh),
                            label: Text(context.tr(LocaleKeys.retry)),
                          )
                        else
                          Text(
                            '$percentage%',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: context.theme.colorScheme.primary,
                            ),
                          ),
                      ],
                    ),
                    12.verticalSpace,
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4.r),
                      child: LinearProgressIndicator(
                        value: isFailed ? 0.0 : item.progress,
                        minHeight: 6.h,
                        backgroundColor: context.theme.colorScheme.surfaceContainerHigh,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isFailed
                              ? context.theme.colorScheme.error
                              : context.theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
