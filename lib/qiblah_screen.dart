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
    return Scaffold(
      appBar: AppBar(title: const Text('اتجاه القبلة'), centerTitle: true),
      body: StreamBuilder<LocationStatus>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _buildErrorWidget('حدث خطأ غير متوقع');
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
                return _buildErrorWidget('تم رفض إذن الموقع', showRetry: true);
              case LocationPermission.deniedForever:
                return _buildErrorWidget(
                  'تم رفض إذن الموقع بشكل دائم.\nيرجى تفعيله من الإعدادات.',
                  showRetry: true,
                );
              default:
                return const SizedBox();
            }
          } else {
            return _buildErrorWidget('يرجى تفعيل خدمة الموقع', showRetry: true);
          }
        },
      ),
    );
  }

  Widget _buildErrorWidget(String message, {bool showRetry = false}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            if (showRetry) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _checkLocationStatus,
                icon: const Icon(Icons.refresh),
                label: const Text('إعادة المحاولة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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

  @override
  Widget build(BuildContext context) {
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
        final theme = Theme.of(context);

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(shape: BoxShape.circle),
                child: SvgPicture.asset(
                  'assets/data/svgIcons/mecca.svg',
                  width: 100,
                  height: 100,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'حرّك هاتفك لتحديد اتجاه القبلة',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: 280,
                height: 280,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Compass dial
                    Transform.rotate(
                      angle: qiblahDirection.direction * (pi / 180) * -1,
                      child: CustomPaint(
                        size: const Size(280, 280),
                        painter: _CompassDialPainter(
                          cardinalColor: theme.colorScheme.onSurface
                              .withOpacity(0.7),
                          tickColor: theme.colorScheme.onSurface.withOpacity(
                            0.3,
                          ),
                          circleColor: theme.colorScheme.onSurface.withOpacity(
                            0.15,
                          ),
                        ),
                      ),
                    ),
                    // Qiblah needle
                    Transform.rotate(
                      angle: qiblahDirection.qiblah * (pi / 180) * -1,
                      child: CustomPaint(
                        size: const Size(280, 280),
                        painter: _QiblahNeedlePainter(),
                      ),
                    ),
                    // Center dot
                    Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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

      // Cardinal labels
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
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Needle pointing up (towards Qiblah)
    final needlePaint = Paint()
      ..color = const Color(0xFF10B981)
      ..style = PaintingStyle.fill;

    final needlePath = Path()
      ..moveTo(center.dx, center.dy - radius + 30)
      ..lineTo(center.dx - 10, center.dy - 20)
      ..lineTo(center.dx + 10, center.dy - 20)
      ..close();

    canvas.drawPath(needlePath, needlePaint);

    // Kaaba icon circle at tip
    final kaabaPaint = Paint()
      ..color = const Color(0xFF10B981)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(center.dx, center.dy - radius + 22),
      14,
      kaabaPaint,
    );

    // Kaaba symbol (small square)
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
