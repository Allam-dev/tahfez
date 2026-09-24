part of '../moshaf_screen.dart';

class _AnimatedAyaHighlight extends StatelessWidget {
  final List<Offset> targetPoints;
  final Duration duration;

  const _AnimatedAyaHighlight({
    required this.targetPoints,
  }) : duration = const Duration(milliseconds: 300);

  @override
  Widget build(BuildContext context) {
    if (targetPoints.isEmpty) return const SizedBox.shrink();

    // Safely pull the active colors from context via ThemeExtension
    final themeColors = context.theme.extension<AyaHighlightColors>()!;

    return TweenAnimationBuilder<List<Offset>>(
      tween: _PolygonPointsTween(end: targetPoints),
      duration: duration,
      curve: Curves.easeInOutCubic,
      builder: (context, animatedPoints, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: _SmoothAyaPainter(
            points: animatedPoints,
            fillColor: themeColors.fill,
            glowColor: themeColors.glow,
          ),
        );
      },
    );
  }
}

/// =========================================================================
/// 3. GEOMETRIC INTERPOLATION ENGINE (TWEEN)
/// =========================================================================
class _PolygonPointsTween extends Tween<List<Offset>> {
  _PolygonPointsTween({super.end});

  @override
  List<Offset> lerp(double t) {
    final start = begin ?? end ?? [];
    final finish = end ?? [];

    // Safely blend layouts even if shapes contain a mismatched count of points
    int maxPoints = start.length > finish.length ? start.length : finish.length;

    List<Offset> interpolated = [];
    for (int i = 0; i < maxPoints; i++) {
      final pStart = i < start.length
          ? start[i]
          : (finish.isNotEmpty ? finish.last : Offset.zero);
      final pFinish = i < finish.length
          ? finish[i]
          : (start.isNotEmpty ? start.last : Offset.zero);

      interpolated.add(Offset.lerp(pStart, pFinish, t)!);
    }
    return interpolated;
  }
}

/// =========================================================================
/// 4. NATIVE CANVAS GRAPHICS ENGINE (PAINTER)
/// =========================================================================
class _SmoothAyaPainter extends CustomPainter {
  final List<Offset> points;
  final Color fillColor;
  final Color glowColor;

  _SmoothAyaPainter({
    required this.points,
    required this.fillColor,
    required this.glowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    // Solid inner fill setup
    final paint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    // Soft blur edge highlight stroke setup
    final outerGlowPaint = Paint()
      ..color = glowColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    // Build vector path path loop
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    path.close();

    // Render layers on GPU
    canvas.drawPath(path, paint);
    canvas.drawPath(path, outerGlowPaint);
  }

  @override
  bool shouldRepaint(covariant _SmoothAyaPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.glowColor != glowColor;
  }
}
