import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tahfez/app/localization/locale_keys.g.dart';
import 'package:tahfez/core/di/main_di.dart';
import 'package:tahfez/modules/reader/domain/models/reader_model.dart';
import 'package:tahfez/modules/reader/domain/reader_repo.dart';

class ReadersDropdown extends StatefulWidget {
  final ValueChanged<ReaderModel>? onChanged;

  const ReadersDropdown({super.key, this.onChanged});

  @override
  State<ReadersDropdown> createState() => _ReadersDropdownState();
}

class _ReadersDropdownState extends State<ReadersDropdown> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getIt<ReaderRepo>().getList(),
      builder: (context, snapshot) {
        // Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return AbsorbPointer(
            child: DropdownMenu<ReaderModel>(
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

        // Error (either connectionState error, or Left(Failure))
        if (snapshot.hasError) {
          return _ErrorRetry(
            message: context.tr(LocaleKeys.somethingWentWrong),
            onRetry: _retry,
          );
        }

        final either = snapshot.data!;

        return either.fold(
          (failure) => _ErrorRetry(
            message: context.tr(failure.message), // adapt to your Failure class
            onRetry: _retry,
          ),
          (list) {
            if (list.isEmpty) {
              return _ErrorRetry(
                message: context.tr(LocaleKeys.noReadersFound),
                onRetry: _retry,
              );
            }
            return DropdownMenu<ReaderModel>(
              menuHeight: 300.h,

              expandedInsets: EdgeInsets.zero,
              enableFilter: true,
              requestFocusOnTap: true,
              label: Text(context.tr(LocaleKeys.selectReader)),
              dropdownMenuEntries: list
                  .map(
                    (r) => DropdownMenuEntry<ReaderModel>(
                      value: r,
                      label: r.nameWithRewaya,
                    ),
                  )
                  .toList(),
              onSelected: (value) {
                if (value != null) {
                  widget.onChanged?.call(value);
                }
              },
            );
          },
        );
      },
    );
  }

  void _retry() {
    setState(() {});
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
