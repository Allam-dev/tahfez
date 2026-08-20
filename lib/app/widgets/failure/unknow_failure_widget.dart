part of 'failure_widget.dart';

class _UnknowFailureWidget extends StatelessWidget {
  const _UnknowFailureWidget({
    required this.failure,
    this.onRetry,
    this.retryText,
  });

  final Failure failure;
  final VoidCallback? onRetry;
  final String? retryText;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          _failureIcon(failure.type),
          20.verticalSpace,
          Text(context.tr(failure.message)),
          if (onRetry != null) ...[
            12.verticalSpace,
            TextButton(
              onPressed: onRetry,
              child: Text(retryText ?? context.tr(LocaleKeys.retry)),
            ),
          ],
        ],
      ),
    );
  }
}
