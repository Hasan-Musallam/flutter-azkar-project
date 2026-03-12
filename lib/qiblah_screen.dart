import 'dart:async';
import 'dart:math' show pi, cos, sin;

import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';

class QiblahScreen extends StatefulWidget {
  const QiblahScreen({super.key});

  @override
  State<QiblahScreen> createState() => _QiblahScreenState();
}

class _QiblahScreenState extends State<QiblahScreen> {
  final _locationStreamController =
      StreamController<LocationStatus>.broadcast();

  Stream<LocationStatus> get stream => _locationStreamController.stream;

  @override
  void initState() {
    super.initState();
    _checkLocationStatus();
  }

  @override
  void dispose() {
    _locationStreamController.close();
    FlutterQiblah().dispose();
    super.dispose();
  }

  Future<void> _checkLocationStatus() async {
    final locationStatus = await FlutterQiblah.checkLocationStatus();
    if (locationStatus.enabled &&
        locationStatus.status == LocationPermission.denied) {
      await FlutterQiblah.requestPermissions();
      final s = await FlutterQiblah.checkLocationStatus();
      _locationStreamController.sink.add(s);
    } else {
      _locationStreamController.sink.add(locationStatus);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
                : [const Color(0xFFF0FDFA), const Color(0xFFCCFBF1)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back_ios_rounded,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'اتجاه القبلة',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Amiri',
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder<LocationStatus>(
                  stream: stream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return _buildErrorWidget('حدث خطأ غير متوقع', isDark);
                    }

                    final data = snapshot.data;
                    if (data == null) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (data.enabled) {
                      switch (data.status) {
                        case LocationPermission.always:
                        case LocationPermission.whileInUse:
                          return const _QiblahCompassWidget();
                        case LocationPermission.denied:
                          return _buildErrorWidget(
                            'تم رفض إذن الموقع',
                            isDark,
                            showRetry: true,
                          );
                        case LocationPermission.deniedForever:
                          return _buildErrorWidget(
                            'تم رفض إذن الموقع بشكل دائم.\nيرجى تفعيله من الإعدادات.',
                            isDark,
                            showRetry: true,
                          );
                        default:
                          return const SizedBox();
                      }
                    } else {
                      return _buildErrorWidget(
                        'يرجى تفعيل خدمة الموقع',
                        isDark,
                        showRetry: true,
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(
    String message,
    bool isDark, {
    bool showRetry = false,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.08)
                    : const Color(0xFF0D9488).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_off_rounded,
                size: 48,
                color: isDark ? Colors.white70 : const Color(0xFF0D9488),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            if (showRetry) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _checkLocationStatus,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('إعادة المحاولة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D9488),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ================= Qiblah Compass Widget =================
class _QiblahCompassWidget extends StatelessWidget {
  const _QiblahCompassWidget();

  String _getDirectionStatus(double qiblahOffset) {
    final absOffset = qiblahOffset.abs();
    if (absOffset <= 3) return '✅ أنت في اتجاه القبلة!';
    if (absOffset <= 10) return '🔥 قريب جداً! استمر';
    if (absOffset <= 30) return 'حرّك الهاتف قليلاً';
    return 'حرّك هاتفك لتحديد اتجاه القبلة';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return StreamBuilder<QiblahDirection>(
      stream: FlutterQiblah.qiblahStream,
      builder: (_, AsyncSnapshot<QiblahDirection> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData) {
          return const Center(child: Text('لا توجد بيانات'));
        }

        final qiblahDirection = snapshot.data!;
        final qiblahOffset = qiblahDirection.qiblah;
        final isAligned = qiblahOffset.abs() <= 3;

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Mecca icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isAligned
                    ? const Color(0xFF10B981).withOpacity(0.15)
                    : Colors.transparent,
              ),
              child: SvgPicture.asset(
                'assets/data/svgIcons/mecca.svg',
                width: 80,
                height: 80,
              ),
            ),
            const SizedBox(height: 12),

            // Status text
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                _getDirectionStatus(qiblahOffset),
                key: ValueKey<String>(_getDirectionStatus(qiblahOffset)),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isAligned ? FontWeight.bold : FontWeight.normal,
                  color: isAligned
                      ? const Color(0xFF10B981)
                      : theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Compass
            SizedBox(
              width: 280,
              height: 280,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Glow effect when aligned
                  if (isAligned)
                    Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF10B981).withOpacity(0.3),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                    ),
                  // Compass dial
                  Transform.rotate(
                    angle: qiblahDirection.direction * (pi / 180) * -1,
                    child: CustomPaint(
                      size: const Size(280, 280),
                      painter: _CompassDialPainter(
                        cardinalColor: isDark
                            ? Colors.white.withOpacity(0.7)
                            : theme.colorScheme.onSurface.withOpacity(0.7),
                        tickColor: isDark
                            ? Colors.white.withOpacity(0.3)
                            : theme.colorScheme.onSurface.withOpacity(0.3),
                        circleColor: isDark
                            ? Colors.white.withOpacity(0.12)
                            : theme.colorScheme.onSurface.withOpacity(0.12),
                      ),
                    ),
                  ),
                  // Qiblah needle
                  Transform.rotate(
                    angle: qiblahDirection.qiblah * (pi / 180) * -1,
                    child: CustomPaint(
                      size: const Size(280, 280),
                      painter: _QiblahNeedlePainter(isAligned: isAligned),
                    ),
                  ),
                  // Center dot
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0D9488), Color(0xFF10B981)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10B981).withOpacity(0.4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Degree info
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.08)
                    : const Color(0xFF0D9488).withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${qiblahDirection.direction.toStringAsFixed(1)}°',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white70 : const Color(0xFF0D9488),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ================= Compass Dial Painter =================
class _CompassDialPainter extends CustomPainter {
  final Color cardinalColor;
  final Color tickColor;
  final Color circleColor;

  _CompassDialPainter({
    required this.cardinalColor,
    required this.tickColor,
    required this.circleColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Outer circle
    final circlePaint = Paint()
      ..color = circleColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius - 4, circlePaint);

    // Inner circle
    canvas.drawCircle(center, radius - 24, circlePaint);

    // Tick marks & cardinal labels
    final tickPaint = Paint()
      ..color = tickColor
      ..strokeWidth = 1.5;

    final majorTickPaint = Paint()
      ..color = cardinalColor
      ..strokeWidth = 2.5;

    const arabicCardinals = ['شمال', 'شرق', 'جنوب', 'غرب'];

    for (int i = 0; i < 360; i += 5) {
      final angle = i * (pi / 180) - pi / 2;
      final isCardinal = i % 90 == 0;
      final isMajor = i % 30 == 0;

      final outerPoint = Offset(
        center.dx + (radius - 6) * cos(angle),
        center.dy + (radius - 6) * sin(angle),
      );

      double innerRadius;
      if (isCardinal) {
        innerRadius = radius - 22;
      } else if (isMajor) {
        innerRadius = radius - 18;
      } else {
        innerRadius = radius - 14;
      }

      final innerPoint = Offset(
        center.dx + innerRadius * cos(angle),
        center.dy + innerRadius * sin(angle),
      );

      canvas.drawLine(
        innerPoint,
        outerPoint,
        isCardinal || isMajor ? majorTickPaint : tickPaint,
      );

      if (isCardinal) {
        final cardinalIndex = i ~/ 90;
        final textPainter = TextPainter(
          text: TextSpan(
            text: arabicCardinals[cardinalIndex],
            style: TextStyle(
              color: cardinalIndex == 0
                  ? const Color(0xFFEF4444)
                  : cardinalColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.rtl,
        );
        textPainter.layout();
        final labelRadius = radius - 38;
        final labelOffset = Offset(
          center.dx + labelRadius * cos(angle) - textPainter.width / 2,
          center.dy + labelRadius * sin(angle) - textPainter.height / 2,
        );
        textPainter.paint(canvas, labelOffset);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ================= Qiblah Needle Painter =================
class _QiblahNeedlePainter extends CustomPainter {
  final bool isAligned;

  _QiblahNeedlePainter({this.isAligned = false});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final needleColor = isAligned
        ? const Color(0xFF10B981)
        : const Color(0xFF0D9488);

    // Needle pointing up
    final needlePaint = Paint()
      ..color = needleColor
      ..style = PaintingStyle.fill;

    final needlePath = Path()
      ..moveTo(center.dx, center.dy - radius + 30)
      ..lineTo(center.dx - 10, center.dy - 20)
      ..lineTo(center.dx + 10, center.dy - 20)
      ..close();

    canvas.drawPath(needlePath, needlePaint);

    // Kaaba icon circle at tip
    final kaabaPaint = Paint()
      ..color = needleColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(center.dx, center.dy - radius + 22),
      14,
      kaabaPaint,
    );

    // Kaaba symbol
    final kaabaSquarePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy - radius + 22),
        width: 12,
        height: 12,
      ),
      kaabaSquarePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
