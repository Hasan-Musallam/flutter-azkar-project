// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/surahDetailScreen.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran/quran.dart' as quran;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredSurahs = [];
  bool _isSearching = false;
  int _bookmarkedSurah = 1;
  int _bookmarkedPage = 1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAllSurahs();
    _loadBookmarkData();
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

  void _loadAllSurahs() {
    _filteredSurahs = List.generate(quran.totalSurahCount, (index) {
      int surahNumber = index + 1;
      return {
        'number': surahNumber,
        'name': quran.getSurahName(surahNumber),
        'nameEnglish': quran.getSurahNameEnglish(surahNumber),
        'arabic': quran.getSurahNameArabic(surahNumber),
        'type': quran.getPlaceOfRevelation(surahNumber),
        'verses': quran.getVerseCount(surahNumber),
      };
    });
  }

  void _searchSurahs(String query) {
    setState(() {
      if (query.isEmpty) {
        _isSearching = false;
        _loadAllSurahs();
      } else {
        _isSearching = true;
        _filteredSurahs =
            List.generate(quran.totalSurahCount, (index) {
              int surahNumber = index + 1;
              return {
                'number': surahNumber,
                'name': quran.getSurahName(surahNumber),
                'nameEnglish': quran.getSurahNameEnglish(surahNumber),
                'arabic': quran.getSurahNameArabic(surahNumber),
                'type': quran.getPlaceOfRevelation(surahNumber),
                'verses': quran.getVerseCount(surahNumber),
              };
            }).where((surah) {
              return surah['name'].toString().toLowerCase().contains(
                    query.toLowerCase(),
                  ) ||
                  surah['nameEnglish'].toString().toLowerCase().contains(
                    query.toLowerCase(),
                  ) ||
                  surah['arabic'].toString().contains(query);
            }).toList();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Reload bookmark on rebuild (e.g. tab switch)
    _loadBookmarkData();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Listens to AppProvider changes to trigger rebuild on tab switch
            Consumer<AppProvider>(
              builder: (context, _, __) => const SizedBox.shrink(),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Text(
                    'القرآن الكريم',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Amiri',
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      Icons.info_outline_rounded,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          title: const Text(
                            'معلومات القرآن',
                            style: TextStyle(fontFamily: 'Amiri'),
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _infoRow('عدد السور', '${quran.totalSurahCount}'),
                              _infoRow(
                                'عدد الآيات',
                                '${quran.totalVerseCount}',
                              ),
                              _infoRow(
                                'عدد الصفحات',
                                '${quran.totalPagesCount}',
                              ),
                              _infoRow('عدد الأجزاء', '${quran.totalJuzCount}'),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('أغلق'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Continue Reading Banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
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
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0D9488), Color(0xFF0F766E)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0D9488).withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.bookmark_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'أكمل القراءة',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'اضغط هنا لمتابعة القراءة من آخر صفحة وصلتها',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.white70,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchController,
                onChanged: _searchSurahs,
                decoration: InputDecoration(
                  hintText: 'ابحث عن سورة...',
                  hintStyle: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.4),
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: theme.colorScheme.onSurface.withOpacity(0.4),
                  ),
                  suffixIcon: _isSearching
                      ? IconButton(
                          icon: Icon(
                            Icons.clear_rounded,
                            color: theme.colorScheme.onSurface.withOpacity(0.4),
                          ),
                          onPressed: () {
                            _searchController.clear();
                            _searchSurahs('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: isDark
                      ? Colors.white.withOpacity(0.06)
                      : Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Surahs List
            Expanded(child: _SurahsList(surahs: _filteredSurahs)),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 15)),
          Text(
            value,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _SurahsList extends StatelessWidget {
  final List<Map<String, dynamic>> surahs;

  const _SurahsList({required this.surahs});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (surahs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'لم يتم العثور على سور',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      itemCount: surahs.length,
      itemBuilder: (context, index) {
        final surah = surahs[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.grey.shade200,
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                          const Color(0xFF0D9488).withOpacity(0.3),
                          const Color(0xFF0D9488).withOpacity(0.1),
                        ]
                      : [
                          const Color(0xFF0D9488).withOpacity(0.15),
                          const Color(0xFF0D9488).withOpacity(0.05),
                        ],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  '${surah['number']}',
                  style: TextStyle(
                    color: const Color(0xFF0D9488),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            title: Text(
              surah['arabic'],
              style: GoogleFonts.amiriQuran(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              '${surah['verses']} آية',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            trailing: surah['type'] == 'Madinah'
                ? SvgPicture.asset(
                    'assets/data/svgIcons/masjid-al-nabawi.svg',
                    width: 22,
                    height: 22,
                  )
                : SvgPicture.asset(
                    'assets/data/svgIcons/mecca.svg',
                    width: 22,
                    height: 22,
                  ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      SurahDetailScreen(surahNumber: surah['number']),
                ),
              ).then((_) => (context as Element).reassemble());
            },
          ),
        );
      },
    );
  }
}
