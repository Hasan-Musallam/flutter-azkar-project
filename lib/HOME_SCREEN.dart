import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/ADHKAR_SCREEN.dart';
import 'package:flutter_application_1/PrayerTime.dart';
import 'package:flutter_application_1/qiblah_screen.dart';
import 'package:flutter_application_1/pages/surahDetailScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _bookmarkedSurah = 1;
  int _bookmarkedPage = 1;

  final currentPage = 0;

  static final List<Map<String, String>> verses = [
    {'text': '"إِنَّ مَعَ الْعُسْرِ يُسْرًا" (الشرح: 6)'},
    {'text': '"اللَّهُ نُورُ السَّمَاوَاتِ وَالْأَرْضِ" (النور: 35)'},
    {
      'text':
          '"وَمَن يَتَّقِ اللَّهَ يَجْعَل لَّهُ مَخْرَجًا..." (الطلاق: 2-3)',
    },
    {'text': '"فَاذْكُرُونِي أَذْكُرْكُمْ" (البقرة: 152)'},
    {'text': '"وَقُل رَّبِّ زِدْنِي عِلْمًا" (طه: 114)'},
    {'text': '"أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ" (الرعد: 28)'},
    {'text': '"إِنَّ اللَّهَ مَعَ الصَّابِرِينَ" (البقرة: 153)'},
    {'text': '"لَا تَقْنَطُوا مِن رَّحْمَةِ اللَّهِ" (الزمر: 53)'},
    {
      'text':
          '"وَتَوَكَّلْ عَلَى اللَّهِ وَكَفَىٰ بِاللَّهِ وَكِيلًا" (الأحزاب: 3)',
    },
    {'text': '"إِنَّ اللَّهَ يُحِبُّ الْمُتَوَكِّلِينَ" (آل عمران: 159)'},
    {'text': '"رَبِّ اشْرَحْ لِي صَدْرِي" (طه: 25)'},
    {'text': '"وَاصْبِرْ وَمَا صَبْرُكَ إِلَّا بِاللَّهِ" (النحل: 127)'},
    {'text': '"حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ" (آل عمران: 173)'},
    {'text': '"وَاللَّهُ خَيْرُ الرَّازِقِينَ" (الجمعة: 11)'},
    {'text': '"وَمَا تَوْفِيقِي إِلَّا بِاللَّهِ" (هود: 88)'},
    {'text': '"إِنَّ رَبِّي قَرِيبٌ مُّجِيبٌ" (هود: 61)'},
    {'text': '"سَيَجْعَلُ اللَّهُ بَعْدَ عُسْرٍ يُسْرًا" (الطلاق: 7)'},
    {'text': '"وَهُوَ مَعَكُمْ أَيْنَ مَا كُنتُمْ" (الحديد: 4)'},
    {'text': '"إِنَّ رَبِّي لَطِيفٌ لِّمَا يَشَاءُ" (يوسف: 100)'},
    {'text': '"إِنَّ اللَّهَ غَفُورٌ رَّحِيمٌ" (البقرة: 173)'},
    {'text': '"وَاللَّهُ يُحِبُّ الْمُحْسِنِينَ" (آل عمران: 134)'},
    {'text': '"إِنَّ اللَّهَ سَرِيعُ الْحِسَابِ" (إبراهيم: 51)'},

    {'text': '"فَإِنَّ مَعَ الْعُسْرِ يُسْرًا" (الشرح: 5)'},
    {'text': '"وَلَا يَظْلِمُ رَبُّكَ أَحَدًا" (الكهف: 49)'},
    {'text': '"إِنَّ اللَّهَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ" (البقرة: 20)'},
    {'text': '"وَرَحْمَتِي وَسِعَتْ كُلَّ شَيْءٍ" (الأعراف: 156)'},
    {'text': '"وَاللَّهُ خَيْرُ الْحَافِظِينَ" (يوسف: 64)'},
    {'text': '"إِنَّ اللَّهَ لَا يُخْلِفُ الْمِيعَادَ" (آل عمران: 9)'},
    {
      'text':
          '"وَمَن يَتَّقِ اللَّهَ يُكَفِّرْ عَنْهُ سَيِّئَاتِهِ" (الطلاق: 5)',
    },
    {'text': '"وَاللَّهُ وَلِيُّ الْمُؤْمِنِينَ" (آل عمران: 68)'},
  ];

  Future<void> _loadBookmarkData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _bookmarkedSurah = prefs.getInt('bookmarkedSurah') ?? 1;
      _bookmarkedPage = prefs.getInt('bookmarkedPage') ?? 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final randomVerse = verses[Random().nextInt(verses.length)];

    return Scaffold(
      appBar: AppBar(title: const Text('أذكار آمنة'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "هذا التتطبيق عن روح الحاجة آمنة عبد الرزاق الكسواني",
              style: theme.textTheme.headlineMedium?.copyWith(
                fontFamily: 'Amiri',
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 24),

            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF059669)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'آية اليوم',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    randomVerse['text']!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "الوصول السريع",
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _QuickAccessCard(
              icon: Icons.auto_stories,
              iconColor: const Color(0xFF10B981),
              iconBg: const Color(0xFFDCFCE7),
              title: 'أكمل القراءة',

              onTap: () {
                _loadBookmarkData();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SurahDetailScreen(
                      surahNumber: _bookmarkedSurah,
                      initialPage: _bookmarkedPage,
                    ),
                  ),
                ).then((_) => _loadBookmarkData());
              },
            ),
            const SizedBox(height: 12),
            _QuickAccessCard(
              icon: Icons.light_mode,
              iconColor: const Color(0xFFF59E0B),
              iconBg: const Color(0xFFFEF3C7),
              title: 'أذكار الصباح والمساء',

              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdhkarScreen()),
                );
              },
            ),
            const SizedBox(height: 12),
            _QuickAccessCard(
              icon: Icons.mosque,
              iconColor: const Color.fromARGB(255, 121, 79, 238),
              iconBg: const Color.fromARGB(255, 171, 184, 243),
              title: 'مواقيت الصلاة',

              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PrayerTimesPage(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _QuickAccessCard(
              icon: Icons.compass_calibration,
              iconColor: const Color(0xFF0EA5E9),
              iconBg: const Color(0xFFE0F2FE),
              title: 'اتجاه القبلة',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const QiblahScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ================= Quick Access Card =================
class _QuickAccessCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;

  final VoidCallback onTap;

  const _QuickAccessCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,

    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }
}
