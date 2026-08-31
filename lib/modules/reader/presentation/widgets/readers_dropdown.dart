import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tahfez/app/localization/locale_keys.g.dart';
import 'package:tahfez/app/widgets/app_dropdown_menu.dart';
import 'package:tahfez/core/di/main_di.dart';
import 'package:tahfez/modules/reader/domain/models/reader_model.dart';
import 'package:tahfez/modules/reader/presentation/widgets/cubit/readers_dropdown_cubit.dart';

class ReadersDropdown extends StatelessWidget {
  final ValueChanged<ReaderModel>? onChanged;

  const ReadersDropdown({super.key, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ReadersDropdownCubit(getIt())..getList(),
      child: Column(
        children: [
          BlocBuilder<ReadersDropdownCubit, ReadersDropdownState>(
            buildWhen: (previous, current) =>
                current is! ReadersDropdownRewayaChangedState,
            builder: (context, state) {
              if (state is ReadersDropdownLoadedState) {
                return AppDropdownMenu<String>(
                  menuHeight: 300.h,
                  expandedInsets: EdgeInsets.zero,
                  enableFilter: true,
                  requestFocusOnTap: true,
                  initialSelection: state.rewayat.first,
                  label: Text(context.tr(LocaleKeys.selectRewaya)),
                  dropdownMenuEntries: state.rewayat
                      .map((r) => DropdownMenuEntry<String>(value: r, label: r))
                      .toList(),
                  onSelected: context.read<ReadersDropdownCubit>().changeRewaya,
                );
              } else if (state is ReadersDropdownFailureState) {
                return _ErrorRetry(
                  message: context.tr(LocaleKeys.somethingWentWrong),
                  onRetry: context.read<ReadersDropdownCubit>().getList,
                );
              } else {
                return AbsorbPointer(
                  child: DropdownMenu<ReaderModel>(
                    expandedInsets: EdgeInsets.zero,

                    enabled: false,
                    hintText: context.tr(LocaleKeys.loading),
                    trailingIcon: const SizedBox(
                      width: 16,
                      height: 16,
                      child: Padding(
                        padding: EdgeInsets.all(2),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    dropdownMenuEntries: const [],
                  ),
                );
              }
            },
          ),
          30.verticalSpace,
          BlocBuilder<ReadersDropdownCubit, ReadersDropdownState>(
            buildWhen: (previous, current) =>
                current is ReadersDropdownRewayaChangedState,
            builder: (context, state) {
              if (state is! ReadersDropdownRewayaChangedState) {
                return const SizedBox.shrink();
              }
              WidgetsBinding.instance.addPostFrameCallback((_) {
                onChanged?.call(state.readers.first);
              });
              return AppDropdownMenu<ReaderModel>(
                menuHeight: 300.h,
                expandedInsets: EdgeInsets.zero,
                initialSelection: state.readers.first,
                enableFilter: true,
                requestFocusOnTap: true,
                label: Text(context.tr(LocaleKeys.selectReader)),
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
