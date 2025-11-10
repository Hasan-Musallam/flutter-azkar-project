// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/surahDetailScreen.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran/quran.dart' as quran;
import 'package:shared_preferences/shared_preferences.dart';

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
    setState(() {
      _bookmarkedSurah = prefs.getInt('bookmarkedSurah') ?? 1;
      _bookmarkedPage = prefs.getInt('bookmarkedPage') ?? 1;
    });
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
        }).where((surah) {
          return surah['name']
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              surah['nameEnglish']
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('القرآن الكريم'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Quran Info'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('عدد السور : ${quran.totalSurahCount}'),
                      Text('عدد الآيات  ${quran.totalVerseCount}'),
                      Text('عدد الصفحات: ${quran.totalPagesCount}'),
                      Text('عدد الأجزاء: ${quran.totalJuzCount}'),
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(200),
          child: Column(
            children: [
              // Continue Reading Banner
              GestureDetector(
                onTap: () {
                  _loadBookmarkData(); // Refresh bookmark data before navigating
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SurahDetailScreen(
                        surahNumber: _bookmarkedSurah,
                        initialPage: _bookmarkedPage,
                      ),
                    ),
                  ).then((_) => _loadBookmarkData()); // Refresh when returning
                },
                child:
              Container(
                height: 80,
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white54,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.black54),
                         
                        ),
                        child: Center(
                          child: Text(
                            'أضغط هنا لمتابعة القراءة ',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            
                          ),
                        ),
                      ),
                    ),

                  ],
                ),
              ),),
              // Search Bar

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: TextField(
                  controller: _searchController,
                  onChanged: _searchSurahs,
                  decoration: InputDecoration(
                    hintText: 'أبحث عن سورة...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _isSearching
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _searchSurahs('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor:
                        theme.colorScheme.surfaceVariant.withOpacity(0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              // Tabs
            ],
          ),
        ),
      ),
      body: _SurahsList(surahs: _filteredSurahs),
    );
  }
}

class _SurahsList extends StatelessWidget {
  final List<Map<String, dynamic>> surahs;

  const _SurahsList({required this.surahs});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (surahs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No surahs found',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: surahs.length,
      itemBuilder: (context, index) {
        final surah = surahs[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: theme.colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  '${surah['number']}',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
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
              '',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
           trailing:Row(
  mainAxisSize: MainAxisSize.min, // <--- هذا هو الحل الأهم
  children: [
    // تم حذف Expanded من هنا
    surah['type'] == 'Madinah'
        ?  SvgPicture.asset(
              'assets/data/svgIcons/masjid-al-nabawi.svg',
              width: 24,
              height: 24,
              
            )
        :  SvgPicture.asset(
              'assets/data/svgIcons/mecca.svg',
              width: 24,
              height: 24,
              
            ),

    const SizedBox(width: 8), // <--- إضافة مسافة فاصلة اختيارية لتحسين الشكل

    Text(
      ''' آياتها
 ${surah['verses']}''', // لا داعي للمسافة في البداية
      style: TextStyle(
        fontSize: 12,
        color: theme.colorScheme.onSurface.withOpacity(0.6),
      ),
    ),
  ],
),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SurahDetailScreen(
                    surahNumber: surah['number'],
                  ),
                ),
              ).then((_) =>
                  (context as Element).reassemble()); // To refresh bookmark data
            },
          ),
        );
      },
    );
  }
}