import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_application_1/pages/AzkarDetailsScreen.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';

class AdhkarScreen extends StatelessWidget {
  const AdhkarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final appProvider = Provider.of<AppProvider>(context);
    final progress = appProvider.dailyAdhkar;
    final completedCount = progress.values.where((v) => v == true).length;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                'الأذكار اليومية',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Amiri',
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 20),

              // Progress circle card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF1E293B), const Color(0xFF334155)]
                        : [
                            const Color(0xFF0D9488).withOpacity(0.08),
                            const Color(0xFF6366F1).withOpacity(0.05),
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.08)
                        : const Color(0xFF0D9488).withOpacity(0.15),
                  ),
                ),
                child: Row(
                  children: [
                    // Circular progress
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 80,
                            height: 80,
                            child: CircularProgressIndicator(
                              value: completedCount / 6,
                              strokeWidth: 8,
                              strokeCap: StrokeCap.round,
                              backgroundColor: isDark
                                  ? Colors.white.withOpacity(0.1)
                                  : const Color(0xFF0D9488).withOpacity(0.15),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF0D9488),
                              ),
                            ),
                          ),
                          Text(
                            '$completedCount/6',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'تقدمك اليومي',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              Text(
                'الأقسام',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Amiri',
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),

              // Grid
              AnimationLimiter(
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.95,
                  children: AnimationConfiguration.toStaggeredList(
                    duration: const Duration(milliseconds: 400),
                    childAnimationBuilder: (widget) => SlideAnimation(
                      verticalOffset: 30.0,
                      child: FadeInAnimation(child: widget),
                    ),
                    children: [
                      _AdhkarCard(
                        icon: Icons.wb_sunny_rounded,
                        title: 'أذكار الصباح',
                        gradient: const [Color(0xFFF59E0B), Color(0xFFD97706)],
                        isCompleted: progress['morning'] ?? false,
                        onTap: () => _openAzkarCategory(
                          context,
                          'أذكار الصباح',
                          'morning',
                        ),
                      ),
                      _AdhkarCard(
                        icon: Icons.nightlight_round,
                        title: 'أذكار المساء',
                        gradient: const [Color(0xFF3B82F6), Color(0xFF2563EB)],
                        isCompleted: progress['evening'] ?? false,
                        onTap: () => _openAzkarCategory(
                          context,
                          'أذكار المساء',
                          'evening',
                        ),
                      ),
                      _AdhkarCard(
                        icon: Icons.bedtime_rounded,
                        title: 'أذكار النوم',
                        gradient: const [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                        isCompleted: progress['sleep'] ?? false,
                        onTap: () =>
                            _openAzkarCategory(context, 'أذكار النوم', 'sleep'),
                      ),
                      _AdhkarCard(
                        icon: Icons.flight_takeoff_rounded,
                        title: 'أذكار السفر',
                        gradient: const [Color(0xFF06B6D4), Color(0xFF0891B2)],
                        isCompleted: progress['travel'] ?? false,
                        onTap: () => _openAzkarCategory(
                          context,
                          'أذكار السفر',
                          'travel',
                        ),
                      ),
                      _AdhkarCard(
                        icon: Icons.restaurant_rounded,
                        title: 'أذكار الطعام',
                        gradient: const [Color(0xFFF97316), Color(0xFFEA580C)],
                        isCompleted: progress['eating'] ?? false,
                        onTap: () => _openAzkarCategory(
                          context,
                          'أذكار الطعام',
                          'eating',
                        ),
                      ),
                      _AdhkarCard(
                        icon: Icons.mosque_rounded,
                        title: 'أذكار بعد الصلاة',
                        gradient: const [Color(0xFF10B981), Color(0xFF059669)],
                        isCompleted: progress['afterPrayer'] ?? false,
                        onTap: () => _openAzkarCategory(
                          context,
                          'أذكار بعد السلام من الصلاة',
                          'afterPrayer',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ------------------ تحميل الأذكار ------------------
Future<void> _openAzkarCategory(
  BuildContext context,
  String category,
  String categoryKey,
) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );

  try {
    final jsonData = await rootBundle.loadString('assets/azkar.json');
    final Map<String, dynamic> parsed = jsonDecode(jsonData);

    if (!parsed.containsKey('rows')) {
      throw Exception('الملف لا يحتوي على بيانات rows');
    }

    final columns = parsed['columns'] as List<dynamic>;
    final rows = parsed['rows'] as List<dynamic>;

    final List<Map<String, dynamic>> data = rows.map((row) {
      final rowMap = <String, dynamic>{};
      for (int i = 0; i < columns.length; i++) {
        rowMap[columns[i]['name']] = row[i];
      }
      return rowMap;
    }).toList();

    final filtered = data.where((z) {
      final cat = (z['category'] ?? '').toString().trim();
      return cat.contains(category.replaceAll('أذكار ', '').trim());
    }).toList();

    if (filtered.isEmpty) {
      Navigator.of(context).pop();
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('لم يتم العثور على الأذكار لهذه الفئة')),
      );
      return;
    }

    Navigator.of(context).pop();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AzkarDetailsScreen(
          title: category,
          azkarList: filtered,
          categoryKey: categoryKey,
          category: '',
        ),
      ),
    );
  } catch (e) {
    Navigator.of(context).pop();
    scaffoldMessenger.showSnackBar(
      SnackBar(content: Text('حدث خطأ أثناء تحميل الأذكار: $e')),
    );
  }
}

/// ------------------ بطاقة الذكر ------------------
class _AdhkarCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Color> gradient;
  final bool isCompleted;
  final VoidCallback? onTap;

  const _AdhkarCard({
    required this.icon,
    required this.title,
    required this.gradient,
    required this.isCompleted,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: gradient[0].withOpacity(0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 36),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              if (isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'تم',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
