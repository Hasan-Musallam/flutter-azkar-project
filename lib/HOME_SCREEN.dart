import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/ADHKAR_SCREEN.dart';
import 'package:flutter_application_1/PrayerTime.dart';
import 'package:flutter_application_1/qiblah_screen.dart';
import 'package:flutter_application_1/pages/surahDetailScreen.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:adhan/adhan.dart';
import 'providers/app_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _bookmarkedSurah = 1;
  int _bookmarkedPage = 1;
  int _completedPrayers = 0;
  Map<String, String>? _dailyVerse;
  late AnimationController _greetingController;
  late Animation<double> _greetingFade;

  static final List<Map<String, String>> verses = [
    {'text': '"إِنَّ مَعَ الْعُسْرِ يُسْرًا" (الشرح: 6)'},
    {'text': '"اللَّهُ نُورُ السَّمَاوَاتِ وَالْأَرْضِ" (النور: 35)'},
    {
      'text':
          '"وَمَن يَتَّقِ اللَّهَ يَجْعَل لَّهُ مَخْرَجًا..." (الطلاق: 2-3)',
    },
    {'text': '"فَاذْكُرُونِي أَذْكُرْكُمْ" (البقرة: 152)'},
    {'text': '"وَقُل رَّبِّ زِدْنِي عِلْمًا" (طه: 114)'},
    {'text': '"أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ" (الرعد: 28)'},
    {'text': '"إِنَّ اللَّهَ مَعَ الصَّابِرِينَ" (البقرة: 153)'},
    {'text': '"لَا تَقْنَطُوا مِن رَّحْمَةِ اللَّهِ" (الزمر: 53)'},
    {
      'text':
          '"وَتَوَكَّلْ عَلَى اللَّهِ وَكَفَىٰ بِاللَّهِ وَكِيلًا" (الأحزاب: 3)',
    },
    {'text': '"إِنَّ اللَّهَ يُحِبُّ الْمُتَوَكِّلِينَ" (آل عمران: 159)'},
    {'text': '"رَبِّ اشْرَحْ لِي صَدْرِي" (طه: 25)'},
    {'text': '"وَاصْبِرْ وَمَا صَبْرُكَ إِلَّا بِاللَّهِ" (النحل: 127)'},
    {'text': '"حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ" (آل عمران: 173)'},
    {'text': '"وَاللَّهُ خَيْرُ الرَّازِقِينَ" (الجمعة: 11)'},
    {'text': '"وَمَا تَوْفِيقِي إِلَّا بِاللَّهِ" (هود: 88)'},
    {'text': '"إِنَّ رَبِّي قَرِيبٌ مُّجِيبٌ" (هود: 61)'},
    {'text': '"سَيَجْعَلُ اللَّهُ بَعْدَ عُسْرٍ يُسْرًا" (الطلاق: 7)'},
    {'text': '"وَهُوَ مَعَكُمْ أَيْنَ مَا كُنتُمْ" (الحديد: 4)'},
    {'text': '"إِنَّ رَبِّي لَطِيفٌ لِّمَا يَشَاءُ" (يوسف: 100)'},
    {'text': '"إِنَّ اللَّهَ غَفُورٌ رَّحِيمٌ" (البقرة: 173)'},
    {'text': '"وَاللَّهُ يُحِبُّ الْمُحْسِنِينَ" (آل عمران: 134)'},
    {'text': '"فَإِنَّ مَعَ الْعُسْرِ يُسْرًا" (الشرح: 5)'},
    {'text': '"وَلَا يَظْلِمُ رَبُّكَ أَحَدًا" (الكهف: 49)'},
    {'text': '"إِنَّ اللَّهَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ" (البقرة: 20)'},
    {'text': '"وَرَحْمَتِي وَسِعَتْ كُلَّ شَيْءٍ" (الأعراف: 156)'},
    {'text': '"وَاللَّهُ خَيْرُ الْحَافِظِينَ" (يوسف: 64)'},
    {'text': '"إِنَّ اللَّهَ لَا يُخْلِفُ الْمِيعَادَ" (آل عمران: 9)'},
    {'text': '"وَاللَّهُ وَلِيُّ الْمُؤْمِنِينَ" (آل عمران: 68)'},
  ];

  @override
  void initState() {
    super.initState();
    _loadBookmarkData();
    _loadDailyVerse();
    _calculatePrayersProgress();
    _greetingController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _greetingFade = CurvedAnimation(
      parent: _greetingController,
      curve: Curves.easeIn,
    );
    _greetingController.forward();
  }

  @override
  void dispose() {
    _greetingController.dispose();
    super.dispose();
  }

  Future<void> _loadBookmarkData() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _bookmarkedSurah = prefs.getInt('bookmarkedSurah') ?? 1;
        _bookmarkedPage = prefs.getInt('bookmarkedPage') ?? 1;
      });
    }
  }

  Future<void> _loadDailyVerse() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final todayString = '${now.year}-${now.month}-${now.day}';

    final savedDate = prefs.getString('last_verse_date');
    int verseIndex = prefs.getInt('last_verse_index') ?? 0;

    if (savedDate != todayString) {
      verseIndex = Random().nextInt(verses.length);
      await prefs.setString('last_verse_date', todayString);
      await prefs.setInt('last_verse_index', verseIndex);
    }

    if (mounted) {
      setState(() {
        _dailyVerse = verses[verseIndex];
      });
    }
  }

  Future<void> _calculatePrayersProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Default to Makkah explicitly if location hasn't been fetched yet
      double lat = prefs.getDouble('last_lat') ?? 21.4225;
      double lng = prefs.getDouble('last_lng') ?? 39.8262;

      final coordinates = Coordinates(lat, lng);
      final params = CalculationMethod.umm_al_qura.getParameters();
      params.madhab = Madhab.shafi;
      final times = PrayerTimes.today(coordinates, params);

      final now = DateTime.now();
      final prayers = [
        {'name': 'الفجر', 'time': times.fajr},
        {'name': 'الشروق', 'time': times.sunrise},
        {'name': 'الظهر', 'time': times.dhuhr},
        {'name': 'العصر', 'time': times.asr},
        {'name': 'المغرب', 'time': times.maghrib},
        {'name': 'العشاء', 'time': times.isha},
      ];

      int completed = 0;
      String nextPrayer = '';
      for (int i = 0; i < prayers.length; i++) {
        final prayerTime = prayers[i]['time'] as DateTime;
        if (now.isBefore(prayerTime)) {
          nextPrayer = prayers[i]['name'] as String;
          if (i > 0) {
            completed = i > 1 ? i - 1 : 0;
          }
          break;
        }
      }
      if (nextPrayer.isEmpty) {
        completed = 5;
      }

      if (mounted) {
        setState(() {
          _completedPrayers = completed;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _completedPrayers = 0;
        });
      }
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 6) return 'طابت ليلتك 🌙';
    if (hour < 12) return 'صباح الخير ☀️';
    if (hour < 17) return 'مساء النور 🌤️';
    return 'مساء الخير 🌙';
  }

  Widget _buildProgressColumn(
    String title,
    String subtitle,
    double progress,
    Widget iconWidget,
  ) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 58,
              height: 58,
              child: CircularProgressIndicator(
                value: progress,
                backgroundColor: Colors.white.withOpacity(0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 5,
                strokeCap: StrokeCap.round,
              ),
            ),
            iconWidget,
          ],
        ),
        const SizedBox(height: 12),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            fontFamily: 'Amiri',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Whenever AppProvider notifies listeners (e.g. from tab change),
    // we reload the latest bookmark from SharedPreferences.
    _loadBookmarkData();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final verseToDisplay = _dailyVerse ?? verses[0];
    final appProvider = Provider.of<AppProvider>(context);
    final progress = appProvider.dailyAdhkar;
    final completedCount = progress.values.where((v) => v == true).length;

    return Scaffold(
      body: SafeArea(
        child: AnimationLimiter(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: AnimationConfiguration.toStaggeredList(
                duration: const Duration(milliseconds: 500),
                childAnimationBuilder: (widget) => SlideAnimation(
                  verticalOffset: 30.0,
                  child: FadeInAnimation(child: widget),
                ),
                children: [
                  // Greeting & dedication
                  FadeTransition(
                    opacity: _greetingFade,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getGreeting(),
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Amiri',
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'عن روح الحاجة آمنة عبد الرزاق الكسواني',
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                            fontFamily: 'Amiri',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Daily Progress Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [const Color(0xFF1E293B), const Color(0xFF334155)]
                            : [
                                const Color(0xFF0D9488),
                                const Color(0xFF0F766E),
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0D9488).withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'تقدمك اليومي',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Amiri',
                              ),
                            ),
                            Icon(
                              Icons.trending_up,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildProgressColumn(
                              'الأذكار',
                              '$completedCount / 6',
                              completedCount / 6,
                              SvgPicture.asset(
                                'assets/data/svgIcons/dua.svg',
                                width: 28,
                                height: 28,
                                colorFilter: const ColorFilter.mode(
                                  Colors.white,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                            _buildProgressColumn(
                              'القرآن',
                              'صفحة $_bookmarkedPage',
                              (_bookmarkedPage / 604).clamp(0.0, 1.0),
                              const Icon(
                                Icons.auto_stories_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            _buildProgressColumn(
                              'الصلوات',
                              '$_completedPrayers / 5',
                              _completedPrayers / 5,
                              const Icon(
                                Icons.mosque_outlined,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Verse of the day - Glass Card
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [
                                const Color(0xFF312E81).withOpacity(0.6),
                                const Color(0xFF4338CA).withOpacity(0.3),
                              ]
                            : [
                                const Color(0xFF6366F1).withOpacity(0.08),
                                const Color(0xFF8B5CF6).withOpacity(0.05),
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withOpacity(0.1)
                            : const Color(0xFF6366F1).withOpacity(0.15),
                      ),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF6366F1,
                                ).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.auto_stories_rounded,
                                color: Color(0xFF6366F1),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'آية اليوم',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          verseToDisplay['text']!,
                          style: TextStyle(
                            fontSize: 18,
                            height: 1.8,
                            fontFamily: 'Amiri',
                            color: isDark
                                ? Colors.white.withOpacity(0.9)
                                : const Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Quick Access Header
                  Text(
                    'الوصول السريع',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Amiri',
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Quick Access Grid 2x2
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 1.1,
                    children: [
                      _QuickAccessCard(
                        icon: Icons.auto_stories_rounded,
                        title: 'أكمل القراءة',
                        gradient: const [Color(0xFF10B981), Color(0xFF059669)],
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
                      _QuickAccessCard(
                        icon: Icons.wb_sunny_rounded,
                        title: 'أذكار الصباح والمساء',
                        gradient: const [Color(0xFFF59E0B), Color(0xFFD97706)],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AdhkarScreen(),
                            ),
                          );
                        },
                      ),
                      _QuickAccessCard(
                        icon: Icons.mosque_rounded,
                        title: 'مواقيت الصلاة',
                        gradient: const [Color(0xFF6366F1), Color(0xFF4F46E5)],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PrayerTimesPage(),
                            ),
                          );
                        },
                      ),
                      _QuickAccessCard(
                        icon: Icons.explore_rounded,
                        title: 'اتجاه القبلة',
                        gradient: const [Color(0xFF0EA5E9), Color(0xFF0284C7)],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const QiblahScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ================= Quick Access Card =================
class _QuickAccessCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _QuickAccessCard({
    required this.icon,
    required this.title,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(20),
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
                child: Icon(icon, color: Colors.white, size: 32),
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
            ],
          ),
        ),
      ),
    );
  }
}
