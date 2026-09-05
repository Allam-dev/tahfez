import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tahfez/app/localization/locale_keys.g.dart';
import 'package:tahfez/app/style/colors/app_colors.dart';

/// A self-contained stateful widget that manages 3 audio playback options switches
/// and enforces internal state dependency & mutual exclusivity rules:
/// 1. [playAudio]: Toggling ON disables [downloadOnly]. Toggling OFF disables [downloadWhilePlaying].
/// 2. [downloadWhilePlaying]: Toggling ON enables [playAudio] and disables [downloadOnly].
/// 3. [downloadOnly]: Toggling ON disables both [playAudio] and [downloadWhilePlaying].
class PlayOptionsSwitch extends StatefulWidget {
  const PlayOptionsSwitch({super.key});

  @override
  State<PlayOptionsSwitch> createState() => _PlayOptionsSwitchState();
}

class _PlayOptionsSwitchState extends State<PlayOptionsSwitch> {
  late bool _playAudio;
  late bool _downloadWhilePlaying;
  late bool _downloadOnly;

  @override
  void initState() {
    super.initState();
    _playAudio = true;
    _downloadWhilePlaying = true;
    _downloadOnly = false;
  }

  void _handlePlayAudioChanged(bool value) {
    setState(() {
      _playAudio = value;
      if (value) {
        // Playing audio is mutually exclusive with download only
        _downloadOnly = false;
      } else {
        // If audio playback is turned off, download-while-playing must also be turned off
        _downloadWhilePlaying = false;
      }
    });
  }

  void _handleDownloadWhilePlayingChanged(bool value) {
    setState(() {
      _downloadWhilePlaying = value;
      if (value) {
        // Download while playing requires audio playback to be active and download-only inactive
        _playAudio = true;
        _downloadOnly = false;
      }
    });
  }

  void _handleDownloadOnlyChanged(bool value) {
    setState(() {
      _downloadOnly = value;
      if (value) {
        // Download only is mutually exclusive with audio playback and download while playing
        _playAudio = false;
        _downloadWhilePlaying = false;
      } else if (!_playAudio) {
        // Default back to audio playing if download only is disabled
        _playAudio = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SwitchRow(
          label: context.tr(LocaleKeys.playAudio),
          value: _playAudio,
          onChanged: _handlePlayAudioChanged,
        ),
        SizedBox(height: 12.h),
        _SwitchRow(
          label: context.tr(LocaleKeys.downloadWhilePlaying),
          value: _downloadWhilePlaying,
          onChanged: _handleDownloadWhilePlayingChanged,
        ),
        SizedBox(height: 12.h),
        _SwitchRow(
          label: context.tr(LocaleKeys.downloadOnly),
          value: _downloadOnly,
          onChanged: _handleDownloadOnlyChanged,
        ),
      ],
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeTrackColor: AppColors.green500,
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: AppColors.sand200,
        ),
        Expanded(
          child: Text(
            label,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.inkLight,
            ),
          ),
        ),
      ],
    );
  }
}
