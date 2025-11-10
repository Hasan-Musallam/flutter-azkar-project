import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_application_1/pages/AzkarDetailsScreen.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';

class AdhkarScreen extends StatelessWidget {
  const AdhkarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appProvider = Provider.of<AppProvider>(context);
    final progress = appProvider.dailyAdhkar;

    final totalAdhkar = progress.length;
    final completedCount = progress.values.where((c) => c).length;
    final progressValue = completedCount / totalAdhkar;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
  actions: [
    IconButton(
      icon: const Icon(Icons.refresh),
      tooltip: 'إعادة ضبط التقدم',
      onPressed: () {
        final appProvider = Provider.of<AppProvider>(context, listen: false);
        appProvider.resetProgress();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إعادة ضبط التقدم اليومي')),
        );
      },
    ),
  ],
        title: const Text('الأذكار اليومية'),
      
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("تقدمك اليومي",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                )),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progressValue,
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Text('$completedCount/$totalAdhkar أذكار مكتملة'),
            // بعد قسم "تقدمك اليومي"
const SizedBox(height: 32),

Text(
  "الأقسام",
  style: theme.textTheme.titleMedium?.copyWith(
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(height: 16),

// شبكة البطاقات 2x2
GridView.count(
  crossAxisCount: 2,
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  mainAxisSpacing: 16,
  crossAxisSpacing: 16,
  childAspectRatio: 0.9,
  children: [
    _AdhkarCard(
      icon: Icons.wb_sunny,
      title: 'أذكار الصباح',
      color: const Color(0xFFFEF3C7),
      iconColor: const Color(0xFFF59E0B),
      isCompleted: progress['morning'] ?? false,
      onTap: () => _openAzkarCategory(context, 'أذكار الصباح', 'morning'),
    ),
    _AdhkarCard(
      icon: Icons.nightlight_round,
      title: 'أذكار المساء',
      color: const Color(0xFFDBEAFE),
      iconColor: const Color(0xFF3B82F6),
      isCompleted: progress['evening'] ?? false,
      onTap: () => _openAzkarCategory(context, 'أذكار المساء', 'evening'),
    ),
    _AdhkarCard(
      icon: Icons.bed,
      title: 'أذكار النوم',
      color: const Color(0xFFEDE9FE),
      iconColor: const Color(0xFF8B5CF6),
      isCompleted: progress['sleep'] ?? false,
      onTap: () => _openAzkarCategory(context, 'أذكار النوم', 'sleep'),
    ),
    _AdhkarCard(
      icon: Icons.directions_car,
      title: 'أذكار السفر',
      color: const Color(0xFFDBEAFE),
      iconColor: const Color(0xFF0EA5E9),
      isCompleted: progress['travel'] ?? false,
      onTap: () => _openAzkarCategory(context, 'أذكار السفر', 'travel'),
    ),
    _AdhkarCard(
      icon: Icons.restaurant,
      title: 'أذكار الطعام',
      color: const Color(0xFFFED7AA),
      iconColor: const Color(0xFFF97316),
      isCompleted: progress['eating'] ?? false,
      onTap: () => _openAzkarCategory(context, 'أذكار الطعام', 'eating'),
    ),
    _AdhkarCard(
      icon: Icons.mosque,
      title: 'أذكار ما بعد الصلاة',
      color: const Color(0xFFD1FAE5),
      iconColor: const Color(0xFF059669),
      isCompleted: progress['afterPrayer'] ?? false,
      onTap: () => _openAzkarCategory(context, 'أذكار بعد السلام من الصلاة', 'afterPrayer'),
    ),
  ],
),

          ],
        ),
      ),
    );
  }
}

/// ------------------ تحميل الأذكار ------------------
Future<void> _openAzkarCategory(BuildContext context, String category, String categoryKey) async {
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
          categoryKey: categoryKey, category: '',
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
/// ------------------ بطاقة الذكر (تصميم جديد) ------------------
class _AdhkarCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final Color iconColor;
  final bool isCompleted;
  final VoidCallback? onTap;

  const _AdhkarCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.iconColor,
    required this.isCompleted,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      splashColor: iconColor.withOpacity(0.1),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(
            color: iconColor.withOpacity(0.3),
            width: 1.2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 40, // أيقونة أكبر
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Icon(
              isCompleted ? Icons.check_circle_rounded : Icons.arrow_back_ios,
              color: isCompleted
                  ? const Color(0xFF10B981)
                  : theme.colorScheme.onSurface.withOpacity(0.4),
              size: isCompleted ? 26 : 20,
            ),
          ],
        ),
      ),
    );
  }
}

