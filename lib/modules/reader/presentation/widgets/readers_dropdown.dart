import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tahfez/app/localization/locale_keys.g.dart';
import 'package:tahfez/app/widgets/app_dropdown_menu.dart';
import 'package:tahfez/app/widgets/text/title_text.dart';
import 'package:tahfez/core/di/main_di.dart';
import 'package:tahfez/modules/reader/domain/models/reader_model.dart';
import 'package:tahfez/modules/reader/presentation/widgets/cubit/readers_dropdown_cubit.dart';

class ReadersDropdown extends StatelessWidget {
  final ValueChanged<ReaderModel>? onChanged;
    final bool enabled;

  const ReadersDropdown({super.key, this.onChanged, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ReadersDropdownCubit(getIt())..getList(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TitleText(number: 1, text: context.tr(LocaleKeys.selectSheikh)),
          8.verticalSpace,

          BlocBuilder<ReadersDropdownCubit, ReadersDropdownState>(
            buildWhen: (previous, current) =>
                current.status != ReadersDropdownStatus.readerChanged,
            builder: (context, state) {
              if (state.status == ReadersDropdownStatus.error) {
                return _ErrorRetry(
                  message: state.failure!.message,
                  onRetry: () {
                    context.read<ReadersDropdownCubit>().getList();
                  },
                );
              } else if (state.selectedReader == null) {
                return AbsorbPointer(
                  child: DropdownMenu<ReaderModel>(
                    expandedInsets: EdgeInsets.zero,
                    enabled: false,
                    hintText: context.tr(LocaleKeys.loading),
                    dropdownMenuEntries: const [],
                  ),
                );
              }
              WidgetsBinding.instance.addPostFrameCallback((_) {
                onChanged?.call(state.selectedReader!);
              });
              return AppDropdownMenu<ReaderModel>(
                menuHeight: 300.h,
                enabled: enabled,
                expandedInsets: EdgeInsets.zero,
                initialSelection: state.selectedReader,
                enableFilter: true,
                requestFocusOnTap: true,
                dropdownMenuEntries: state.readers
                    .map(
                      (r) => DropdownMenuEntry<ReaderModel>(
                        value: r,
                        label: r.name,
                      ),
                    )
                    .toList(),
                onSelected: (value) {
                  if (value != null) {
                    context.read<ReadersDropdownCubit>().changeReader(value);
                    onChanged?.call(value);
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorRetry({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red.shade200),
        borderRadius: BorderRadius.circular(8),
        color: Colors.red.shade50,
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade400, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.red.shade700, fontSize: 13),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
