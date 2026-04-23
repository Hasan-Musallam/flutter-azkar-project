// lib/pages/surahDetailScreen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:quran/quran.dart' as quran;
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/app_provider.dart';

class SurahDetailScreen extends StatefulWidget {
  final int surahNumber;
  final int? initialPage;

  const SurahDetailScreen({
    super.key,
    required this.surahNumber,
    this.initialPage,
  });

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  late PageController _pageController;
  List<dynamic> _pages = [];
  bool _isLoading = true;
  int _currentPageIndex = 0;
  int? _bookmarkedPage;

  @override
  void initState() {
    super.initState();
    _loadPagesData();
    _loadBookmark();
  }

  Future<void> _loadBookmark() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _bookmarkedPage = prefs.getInt('bookmarkedPage');
    });
  }

  Future<void> _saveBookmark(int pageNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('bookmarkedPage', pageNumber);

    final currentSurahNumber =
        _pages[_currentPageIndex]['start']['surah_number'];
    await prefs.setInt('bookmarkedSurah', currentSurahNumber);

    setState(() {
      _bookmarkedPage = pageNumber;
    });

    final appProvider = Provider.of<AppProvider>(context, listen: false);
    appProvider.updateLastReadPosition(
      currentSurahNumber,
      quran.getSurahName(currentSurahNumber),
      pageNumber,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Center(child: Text('تم حفظ الصفحة بنجاح')),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _loadPagesData() async {
    final jsonString = await rootBundle.loadString('assets/pagesQuran.json');
    final List<dynamic> data = json.decode(jsonString);

    int initialPageIndex = 0;

    // إذا تم تمرير initialPage، اجعلها البداية
    if (widget.initialPage != null) {
      initialPageIndex = data.indexWhere(
        (p) => p['page'] == widget.initialPage,
      );
      if (initialPageIndex == -1) initialPageIndex = 0;
    } else {
      // ابحث عن أول صفحة تحتوي على السورة (في البداية أو النهاية)
      initialPageIndex = data.indexWhere((p) {
        final startSurah = p['start']['surah_number'];
        final endSurah = p['end']['surah_number'];

        // الصفحة تحتوي على السورة إذا كانت:
        // 1. السورة المطلوبة تبدأ في هذه الصفحة
        // 2. أو السورة المطلوبة تنتهي في هذه الصفحة
        // 3. أو السورة المطلوبة بين بداية ونهاية الصفحة
        return widget.surahNumber >= startSurah &&
            widget.surahNumber <= endSurah;
      });

      if (initialPageIndex == -1) initialPageIndex = 0;
    }

    setState(() {
      _pages = data;
      _isLoading = false;
      _pageController = PageController(initialPage: initialPageIndex);
      _currentPageIndex = initialPageIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context, listen: false);

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final currentSurahNumber =
        _pages[_currentPageIndex]['start']['surah_number'];
    final currentSurahName = quran.getSurahNameArabic(currentSurahNumber);
    final currentJuz = quran.getJuzNumber(
      currentSurahNumber,
      _pages[_currentPageIndex]['start']['verse'],
    );
    final currentPageNum = _pages[_currentPageIndex]['page'];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFE0DED6),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'سورة $currentSurahName',
              style: GoogleFonts.amiriQuran(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2D2D2D),
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _bookmarkedPage == currentPageNum
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              color: _bookmarkedPage == currentPageNum
                  ? const Color(0xFFE53E3E)
                  : const Color(0xFF5A5A5A),
              size: 26,
            ),
            onPressed: () {
              _saveBookmark(currentPageNum);
            },
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() => _currentPageIndex = index);

          final currentPage = _pages[index];
          final currentSurah = currentPage['start']['surah_number'];
          final pageNumber = currentPage['page'];
          appProvider.updateLastReadPosition(
            currentSurah,
            quran.getSurahName(currentSurah),
            pageNumber,
          );
        },
        itemCount: _pages.length,

        itemBuilder: (context, index) {
          final page = _pages[index];
          final imagePath = page['image']['url'];
          final pageNumber = page['page'];
          final isBookmarked = pageNumber == _bookmarkedPage;
          final surahNum = page['start']['surah_number'];
          final surahName = quran.getSurahNameArabic(surahNum);
          final juzNum = quran.getJuzNumber(surahNum, page['start']['verse']);
          final hizbNum = getHizbNumber(surahNum, page['start']['verse']);

          return LayoutBuilder(
            builder: (context, constraints) {
              final availableWidth = constraints.maxWidth;
              return Stack(
                children: [
                  Column(
                    children: [
                      Expanded(
                        child: Container(
                          color: const Color(0xFFF0EFEA),
                          width: availableWidth,
                          child: Image.asset(
                            'assets$imagePath',
                            fit: BoxFit.fill,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Text(
                                  'لم يتم العثور على الصورة',
                                  style: TextStyle(fontSize: 18),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      // Bottom info bar
                      Container(
                        color: const Color(0xFFE0DED6),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 20,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Hizb Number (right side in RTL)
                            Text(
                              'حزب $hizbNum',
                              style: GoogleFonts.amiri(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF4A4A4A),
                              ),
                            ),
                            // Page number center badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF0D9488),
                                    Color(0xFF0F766E),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF0D9488,
                                    ).withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                '$pageNumber',
                                style: GoogleFonts.amiri(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            // Juz number (left side in RTL)
                            Text(
                              'الجزء $juzNum',
                              style: GoogleFonts.amiri(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF4A4A4A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (isBookmarked)
                    Positioned(
                      top: 0,
                      left: 20,
                      child: Icon(
                        Icons.bookmark_rounded,
                        color: Colors.red.withOpacity(0.8),
                        size: 50,
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  int getHizbNumber(int surah, int ayah) {
    int juz = quran.getJuzNumber(surah, ayah);

    // نحصل على رقم الصفحة
    int page = quran.getPageNumber(surah, ayah);

    // كل جزء فيه تقريبًا 20 صفحة (تقريب)
    int firstPageOfJuz = (juz - 1) * 20 + 1;

    int offset = page - firstPageOfJuz;

    // إذا في أول نصف الجزء => حزب 1
    if (offset < 10) {
      return (juz - 1) * 2 + 1;
    } else {
      return (juz - 1) * 2 + 2;
    }
  }
}
