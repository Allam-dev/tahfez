part of '../downloads_screen.dart';

class _DownloadedTab extends StatelessWidget {
  const _DownloadedTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DownloadsCubit, DownloadsState>(
      builder: (context, state) {
        if (state.status == DownloadsScreenStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.downloadedGroups.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.folder_off_outlined,
                  size: 64.r,
                  color: context.theme.colorScheme.onSurface.withValues(alpha: 0.3),
                ),
                16.verticalSpace,
                Text(
                  context.tr(LocaleKeys.noDownloadedFiles),
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
          itemCount: state.downloadedGroups.length,
          separatorBuilder: (_, _) => 12.verticalSpace,
          itemBuilder: (context, index) {
            final group = state.downloadedGroups[index];
            return Card(
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
                side: BorderSide(color: context.theme.colorScheme.outline),
              ),
              child: ExpansionTile(
                tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                shape: const Border(),
                collapsedShape: const Border(),
                title: Text(
                  group.reader.name,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: context.theme.colorScheme.onSurface,
                  ),
                ),
                subtitle: Text(
                  group.reader.rewaya,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: context.theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: context.theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        '${group.surahNumbers.length} ${context.tr(LocaleKeys.surahs)}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: context.theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    8.horizontalSpace,
                    IconButton(
                      icon: Icon(
                        Icons.delete_sweep_outlined,
                        color: context.theme.colorScheme.error,
                      ),
                      tooltip: context.tr(LocaleKeys.deleteAll),
                      onPressed: () => _confirmDeleteReader(context, group),
                    ),
                  ],
                ),
                children: group.surahNumbers.map((surahNum) {
                  final surahName = (surahNum > 0 && surahNum <= SUR.length)
                      ? SUR[surahNum - 1].name
                      : 'Surah #$surahNum';

                  return Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: context.theme.colorScheme.outline.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 2.h),
                      leading: Container(
                        width: 32.r,
                        height: 32.r,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: context.theme.colorScheme.surfaceContainerHigh,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$surahNum',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: context.theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      title: Text(
                        surahName,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: context.theme.colorScheme.onSurface,
                        ),
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          size: 20.r,
                          color: context.theme.colorScheme.error,
                        ),
                        onPressed: () => _confirmDeleteSurah(
                          context,
                          group.reader,
                          surahNum,
                          surahName,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDeleteReader(BuildContext context, DownloadedReaderGroup group) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(context.tr(LocaleKeys.deleteAll)),
          content: Text(context.tr(LocaleKeys.deleteReaderConfirm)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(context.tr(LocaleKeys.cancel)),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: context.theme.colorScheme.error,
              ),
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<DownloadsCubit>().deleteReaderDownloads(group.reader);
              },
              child: Text(context.tr(LocaleKeys.delete)),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteSurah(
    BuildContext context,
    ReaderModel reader,
    int surahNumber,
    String surahName,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(surahName),
          content: Text(context.tr(LocaleKeys.deleteConfirm)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(context.tr(LocaleKeys.cancel)),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: context.theme.colorScheme.error,
              ),
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<DownloadsCubit>().deleteSurah(reader, surahNumber);
              },
              child: Text(context.tr(LocaleKeys.delete)),
            ),
          ],
        );
      },
    );
  }
}
