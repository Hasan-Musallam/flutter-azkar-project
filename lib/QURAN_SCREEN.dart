// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/surahDetailScreen.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran/quran.dart' as quran;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';
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

  bool _isAudioMode = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  int? _currentPlayingSurah;
  bool _isPlaying = false;
  quran.Reciter _selectedReciter = quran.Reciter.arAlafasy;

  static const Map<quran.Reciter, String> _reciters = {
    quran.Reciter.arAlafasy: 'مشاري العفاسي',
    quran.Reciter.arHusary: 'محمود خليل الحصري',
    quran.Reciter.arAhmedAjamy: 'أحمد العجمي',
    quran.Reciter.arHudhaify: 'علي الحذيفي',
    quran.Reciter.arMaherMuaiqly: 'ماهر المعيقلي',
    quran.Reciter.arMuhammadAyyoub: 'محمد أيوب',
    quran.Reciter.arMuhammadJibreel: 'محمد جبريل',
    quran.Reciter.arMinshawi: 'محمد صديق المنشاوي',
    quran.Reciter.arShaatree: 'أبو بكر الشاطري',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAllSurahs();
    _loadBookmarkData();

    _audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying =
              state.playing &&
              state.processingState != ProcessingState.completed;
        });
      }
    });
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
    _audioPlayer.dispose();
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

            // Toggle for Reading / Audio
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _isAudioMode = false);
                          if (_isPlaying) {
                            _audioPlayer.pause();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !_isAudioMode
                                ? const Color(0xFF0D9488)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: !_isAudioMode
                                ? [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF0D9488,
                                      ).withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Center(
                            child: Text(
                              'قراءة',
                              style: TextStyle(
                                color: !_isAudioMode
                                    ? Colors.white
                                    : theme.colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                fontFamily: 'Amiri',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isAudioMode = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _isAudioMode
                                ? const Color(0xFF0D9488)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: _isAudioMode
                                ? [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF0D9488,
                                      ).withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Center(
                            child: Text(
                              'استماع',
                              style: TextStyle(
                                color: _isAudioMode
                                    ? Colors.white
                                    : theme.colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                fontFamily: 'Amiri',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Surahs List
            Expanded(
              child: _SurahsList(
                surahs: _filteredSurahs,
                isAudioMode: _isAudioMode,
                currentPlayingSurah: _currentPlayingSurah,
                isPlaying: _isPlaying,
                onSurahTap: (surahNumber) {
                  if (_isAudioMode) {
                    _playSurahAudio(surahNumber);
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            SurahDetailScreen(surahNumber: surahNumber),
                      ),
                    ).then((_) => _loadBookmarkData());
                  }
                },
              ),
            ),
            if (_isAudioMode) _buildAudioPlayer(),
          ],
        ),
      ),
    );
  }

  Future<void> _playSurahAudio(int surahNumber) async {
    try {
      if (_currentPlayingSurah == surahNumber && _isPlaying) {
        await _audioPlayer.pause();
      } else if (_currentPlayingSurah == surahNumber && !_isPlaying) {
        await _audioPlayer.play();
      } else {
        await _audioPlayer.stop();
        final audioUrl = quran.getAudioURLBySurah(
          surahNumber,
          reciter: _selectedReciter,
        );
        await _audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(audioUrl)));
        setState(() {
          _currentPlayingSurah = surahNumber;
        });
        await _audioPlayer.play();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'حدث خطأ أثناء تشغيل الصوت، تأكد من اتصالك بالإنترنت',
            ),
          ),
        );
      }
    }
  }

  Future<void> _changeReciter(quran.Reciter newReciter) async {
    final surahToReplay = _currentPlayingSurah;
    setState(() {
      _selectedReciter = newReciter;
    });

    if (surahToReplay != null) {
      try {
        await _audioPlayer.stop();
        // انتظر لحظة حتى يتم إغلاق الـ Bottom Sheet
        await Future.delayed(const Duration(milliseconds: 300));
        final audioUrl = quran.getAudioURLBySurah(
          surahToReplay,
          reciter: _selectedReciter,
        );
        await _audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(audioUrl)));
        setState(() {
          _currentPlayingSurah = surahToReplay;
        });
        await _audioPlayer.play();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'حدث خطأ أثناء تشغيل الصوت، تأكد من اتصالك بالإنترنت',
              ),
            ),
          );
        }
      }
    }
  }

  void _showReciterPicker() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'اختر القارئ',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Amiri',
                ),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _reciters.length,
                  itemBuilder: (context, index) {
                    final entry = _reciters.entries.elementAt(index);
                    final isSelected = entry.key == _selectedReciter;
                    return ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF0D9488).withOpacity(0.15)
                              : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isSelected
                              ? Icons.check_circle_rounded
                              : Icons.person_rounded,
                          color: isSelected
                              ? const Color(0xFF0D9488)
                              : Colors.grey,
                        ),
                      ),
                      title: Text(
                        entry.value,
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 16,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected ? const Color(0xFF0D9488) : null,
                        ),
                      ),
                      onTap: () {
                        final newReciter = entry.key;
                        Navigator.pop(context);
                        _changeReciter(newReciter);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAudioPlayer() {
    if (_currentPlayingSurah == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF0D9488).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.music_note_rounded,
                  color: Color(0xFF0D9488),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'سورة ${quran.getSurahNameArabic(_currentPlayingSurah!)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        fontFamily: 'Amiri',
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _showReciterPicker(),
                      child: Row(
                        children: [
                          Text(
                            _reciters[_selectedReciter] ?? '',
                            style: TextStyle(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.6,
                              ),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 16,
                            color: theme.colorScheme.onSurface.withOpacity(0.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.replay_10_rounded),
                onPressed: () {
                  final newPosition =
                      _audioPlayer.position - const Duration(seconds: 10);
                  _audioPlayer.seek(
                    newPosition < Duration.zero ? Duration.zero : newPosition,
                  );
                },
              ),
              IconButton(
                icon: Icon(
                  _isPlaying
                      ? Icons.pause_circle_filled_rounded
                      : Icons.play_circle_fill_rounded,
                  size: 40,
                  color: const Color(0xFF0D9488),
                ),
                onPressed: () => _playSurahAudio(_currentPlayingSurah!),
              ),
              IconButton(
                icon: const Icon(Icons.forward_10_rounded),
                onPressed: () {
                  final newPosition =
                      _audioPlayer.position + const Duration(seconds: 10);
                  _audioPlayer.seek(newPosition);
                },
              ),
            ],
          ),
          StreamBuilder<Duration>(
            stream: _audioPlayer.positionStream,
            builder: (context, snapshot) {
              final position = snapshot.data ?? Duration.zero;
              final duration = _audioPlayer.duration ?? Duration.zero;
              if (duration == Duration.zero) return const SizedBox.shrink();
              return SliderTheme(
                data: SliderThemeData(
                  trackHeight: 2,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 6,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 14,
                  ),
                ),
                child: Slider(
                  value: position.inMilliseconds.toDouble().clamp(
                    0.0,
                    duration.inMilliseconds.toDouble(),
                  ),
                  max: duration.inMilliseconds.toDouble(),
                  activeColor: const Color(0xFF0D9488),
                  inactiveColor: const Color(0xFF0D9488).withOpacity(0.2),
                  onChanged: (value) {
                    _audioPlayer.seek(Duration(milliseconds: value.toInt()));
                  },
                ),
              );
            },
          ),
        ],
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
  final bool isAudioMode;
  final int? currentPlayingSurah;
  final bool isPlaying;
  final Function(int) onSurahTap;

  const _SurahsList({
    required this.surahs,
    this.isAudioMode = false,
    this.currentPlayingSurah,
    this.isPlaying = false,
    required this.onSurahTap,
  });

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
            trailing: isAudioMode
                ? Icon(
                    currentPlayingSurah == surah['number'] && isPlaying
                        ? Icons.pause_circle_filled_rounded
                        : Icons.play_circle_fill_rounded,
                    color: const Color(0xFF0D9488),
                    size: 32,
                  )
                : (surah['type'] == 'Madinah'
                      ? SvgPicture.asset(
                          'assets/data/svgIcons/masjid-al-nabawi.svg',
                          width: 22,
                          height: 22,
                        )
                      : SvgPicture.asset(
                          'assets/data/svgIcons/mecca.svg',
                          width: 22,
                          height: 22,
                        )),
            onTap: () => onSurahTap(surah['number']),
          ),
        );
      },
    );
  }
}
