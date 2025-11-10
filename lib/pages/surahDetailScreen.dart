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

    final currentSurahNumber = _pages[_currentPageIndex]['start']['surah_number'];
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
    initialPageIndex = data.indexWhere((p) => p['page'] == widget.initialPage);
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
      return widget.surahNumber >= startSurah && widget.surahNumber <= endSurah;
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

    return Scaffold(
      appBar: AppBar(
        backgroundColor:Color(0xFFE0DED6),
        title: Row(
          children: [
            Text(
              quran.getSurahNameArabic(_pages[_currentPageIndex]['start']['surah_number']),
              style: GoogleFonts.amiriQuran(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Text(
              'جزء ${quran.getJuzNumber(_pages[_currentPageIndex]['start']['surah_number'], _pages[_currentPageIndex]['start']['verse'])}',
              style: GoogleFonts.amiriQuran(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.bookmark,
              color: _bookmarkedPage == _pages[_currentPageIndex]['page']
                  ? Colors.red
                  : Theme.of(context).appBarTheme.actionsIconTheme?.color,
            ),
            onPressed: () {
              _saveBookmark(_pages[_currentPageIndex]['page']);
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
          final currentPageNumber = page['page'];
          final isBookmarked = currentPageNumber == _bookmarkedPage;

          return LayoutBuilder(
            builder: (context, constraints) {
              final availableWidth = constraints.maxWidth;
              return Stack(
                children: [
                  Column(
                    children: [
                      Expanded(
                        child: Container(
                          color:  Color(0xFFF0EFEA),
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
                      Container(
                        color: Color(0xFFF0EFEA),
                        padding: const EdgeInsets.only(bottom: 40),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'الصفحة ${page['page']}',
                              style: GoogleFonts.amiriQuran(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
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
                        Icons.bookmark,
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
}
