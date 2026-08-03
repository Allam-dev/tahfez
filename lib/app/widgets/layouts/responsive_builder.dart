import 'package:flutter/material.dart';
import 'package:tahfez/core/services/logs/log.dart';

class ResponsiveBuilder extends StatelessWidget {
  final WidgetBuilder mobile;
  final WidgetBuilder? landscapeMobile;
  final WidgetBuilder? portraitTablet;
  final WidgetBuilder? landscapeTablet;
  final WidgetBuilder? desktop;
  final WidgetBuilder? tv;
  final BreakPoints breakPoints;

  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.landscapeMobile,
    this.portraitTablet,
    this.landscapeTablet,
    this.desktop,
    this.tv,
    this.breakPoints = const BreakPoints(),
  });

  @override
  Widget build(BuildContext context) {
    Log.debug(
      'Screen width: ${context.screenWidth}, orientation: ${context.orientation}',
    );
    return Builder(
      builder: (context) {
        switch (_deviceType(context)) {
          case DeviceType.mobile:
            switch (context.orientation) {
              case _DeviceOrientation.portrait:
                return mobile(context);
              case _DeviceOrientation.landscape:
                final builder = landscapeMobile ?? landscapeTablet ?? mobile;
                return builder(context);
            }
          case DeviceType.tablet:
            switch (context.orientation) {
              case _DeviceOrientation.portrait:
                final builder = portraitTablet ?? mobile;
                return builder(context);
              case _DeviceOrientation.landscape:
                final builder = landscapeTablet ?? portraitTablet ?? mobile;
                return builder(context);
            }
          case DeviceType.desktop:
            final builder =
                desktop ?? landscapeTablet ?? portraitTablet ?? mobile;
            return builder(context);
          case DeviceType.tv:
            final builder =
                tv ?? landscapeTablet ?? portraitTablet ?? desktop ?? mobile;
            return builder(context);
        }
      },
    );
  }

  DeviceType _deviceType(BuildContext context) {
    if (context.screenWidth > breakPoints.tv) {
      return DeviceType.tv;
    } else if (context.screenWidth > breakPoints.desktop) {
      return DeviceType.desktop;
    } else if (context.screenWidth > breakPoints.tablet) {
      return DeviceType.tablet;
    } else {
      return DeviceType.mobile;
    }
  }
}

extension _MediaQueryExtension on BuildContext {
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  double get screenWidth => mediaQuery.size.width;
  double get screenHeight => mediaQuery.size.height;
  _DeviceOrientation get orientation {
    if (screenWidth > screenHeight) {
      return _DeviceOrientation.landscape;
    } else {
      return _DeviceOrientation.portrait;
    }
  }
}

enum _DeviceOrientation { portrait, landscape }

enum DeviceType { mobile, tablet, desktop, tv }

class BreakPoints {
  final double tablet;
  final double desktop;
  final double tv;

  const BreakPoints({this.tablet = 500, this.desktop = 1100, this.tv = 1920});
}
