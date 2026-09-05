part of '../play_settings_screen.dart';

class _StartButton extends StatelessWidget {
  const _StartButton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlaySettingsScreenCubit, PlaySettingsScreenState>(
      builder: (context, state) {
        return ElevatedButton(
          onPressed: () {},
          child: Text(context.tr(LocaleKeys.start)),
        );
      },
    );
  }
}
