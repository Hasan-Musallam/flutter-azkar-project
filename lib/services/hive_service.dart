import 'package:hive_flutter/hive_flutter.dart';
import '../models/hive_models.dart';

class HiveService {
  static late Box<HiveBookmark> _bookmarksBox;
  static late Box<HiveUserProgress> _progressBox;
  static late Box<HiveAppSettings> _settingsBox;
  static late Box<HiveReadingSession> _sessionsBox;

  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Register adapters
    Hive.registerAdapter(HiveBookmarkAdapter());
    Hive.registerAdapter(HiveUserProgressAdapter());
    Hive.registerAdapter(HiveAppSettingsAdapter());
    Hive.registerAdapter(HiveReadingSessionAdapter());

    // Open boxes
    _bookmarksBox = await Hive.openBox<HiveBookmark>('bookmarks');
    _progressBox = await Hive.openBox<HiveUserProgress>('progress');
    _settingsBox = await Hive.openBox<HiveAppSettings>('settings');
    _sessionsBox = await Hive.openBox<HiveReadingSession>('sessions');

    // Initialize default data if empty
    await _initializeDefaultData();
  }

  static Future<void> _initializeDefaultData() async {
    // Initialize settings if empty
    if (_settingsBox.isEmpty) {
      await _settingsBox.put('default', HiveAppSettings());
    }

    // Initialize progress if empty
    if (_progressBox.isEmpty) {
      await _progressBox.put('default', HiveUserProgress());
    }

    // Add sample bookmarks if empty
    if (_bookmarksBox.isEmpty) {
      await _addSampleBookmarks();
    }
  }

  static Future<void> _addSampleBookmarks() async {
    final sampleBookmarks = [
      HiveBookmark(
        id: '1',
        type: 'verse',
        title: 'Ayat al-Kursi',
        subtitle: 'Al-Baqarah 255',
        arabicText: 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَّهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ ۗ مَن ذَا الَّذِي يَشْفَعُ عِندَهُ إِلَّا بِإِذْنِهِ ۚ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ ۖ وَلَا يُحِيطُونَ بِشَيْءٍ مِّنْ عِلْمِهِ إِلَّا بِمَا شَاءَ ۚ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ ۖ وَلَا يَئُودُهُ حِفْظُهُمَا ۚ وَهُوَ الْعَلِيُّ الْعَظِيمُ',
        translation: 'Allah - there is no deity except Him, the Ever-Living, the Sustainer of existence. Neither drowsiness overtakes Him nor sleep. To Him belongs whatever is in the heavens and whatever is on the earth. Who is it that can intercede with Him except by His permission? He knows what is before them and what will be after them, and they encompass not a thing of His knowledge except for what He wills. His Kursi extends over the heavens and the earth, and their preservation tires Him not. And He is the Most High, the Most Great.',
        dateAdded: DateTime.now().subtract(const Duration(days: 2)),
        surahName: 'Al-Baqarah',
        verseNumber: 255,
        surahNumber: 2,
      ),
      HiveBookmark(
        id: '2',
        type: 'adhkar',
        title: 'Morning Dhikr',
        subtitle: 'Daily Protection',
        arabicText: 'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ ۖ وَالْحَمْدُ لِلَّهِ ۖ لَا إِلَٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ ۖ لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ',
        translation: 'We have reached the morning and at this very time unto Allah belongs all sovereignty, and all praise is for Allah. None has the right to be worshipped except Allah, alone, without partner, to Him belongs all sovereignty and praise and He is over all things omnipotent.',
        dateAdded: DateTime.now().subtract(const Duration(days: 1)),
        adhkarCategory: 'morning',
      ),
      HiveBookmark(
        id: '3',
        type: 'verse',
        title: 'Surah Al-Ikhlas',
        subtitle: 'Complete Chapter',
        arabicText: 'قُلْ هُوَ اللَّهُ أَحَدٌ ۞ اللَّهُ الصَّمَدُ ۞ لَمْ يَلِدْ وَلَمْ يُولَدْ ۞ وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ',
        translation: 'Say, "He is Allah, [who is] One, Allah, the Eternal Refuge. He neither begets nor is born, Nor is there to Him any equivalent."',
        dateAdded: DateTime.now().subtract(const Duration(days: 3)),
        surahName: 'Al-Ikhlas',
        verseNumber: 1,
        surahNumber: 112,
      ),
    ];

    for (final bookmark in sampleBookmarks) {
      await _bookmarksBox.add(bookmark);
    }
  }

  // Bookmark operations
  static Future<void> addBookmark(HiveBookmark bookmark) async {
    await _bookmarksBox.add(bookmark);
  }

  static Future<void> deleteBookmark(String bookmarkId) async {
    final index = _bookmarksBox.values.toList().indexWhere((b) => b.id == bookmarkId);
    if (index != -1) {
      await _bookmarksBox.deleteAt(index);
    }
  }

  static List<HiveBookmark> getAllBookmarks() {
    return _bookmarksBox.values.toList();
  }

  static List<HiveBookmark> getBookmarksByType(String type) {
    return _bookmarksBox.values.where((b) => b.type == type).toList();
  }

  // Progress operations
  static HiveUserProgress getProgress() {
    return _progressBox.get('default') ?? HiveUserProgress();
  }

  static Future<void> updateProgress(HiveUserProgress progress) async {
    await _progressBox.put('default', progress);
  }

  static Future<void> updatePagesRead(int pages) async {
    final progress = getProgress();
    progress.pagesRead = pages;
    await updateProgress(progress);
  }

  static Future<void> updateAdhkarCompleted(int count) async {
    final progress = getProgress();
    progress.adhkarCompleted = count;
    await updateProgress(progress);
  }

  static Future<void> updateReadingStreak(int streak) async {
    final progress = getProgress();
    progress.readingStreak = streak;
    await updateProgress(progress);
  }

  static Future<void> updateLastReadPosition(int surahNumber, String surahName, int verse) async {
    final progress = getProgress();
    progress.lastReadSurahNumber = surahNumber;
    progress.lastReadSurah = surahName;
    progress.lastReadVerse = verse;
    progress.lastActivityDate = DateTime.now();
    await updateProgress(progress);
  }

  static Future<void> markAdhkarCompleted(String adhkarType) async {
    final progress = getProgress();
    progress.dailyAdhkar[adhkarType] = true;
    await updateProgress(progress);
  }

  // Settings operations
  static HiveAppSettings getSettings() {
    return _settingsBox.get('default') ?? HiveAppSettings();
  }

  static Future<void> updateSettings(HiveAppSettings settings) async {
    await _settingsBox.put('default', settings);
  }

  // Reading session operations
  static Future<void> addReadingSession(HiveReadingSession session) async {
    await _sessionsBox.add(session);
  }

  static List<HiveReadingSession> getRecentSessions({int limit = 10}) {
    final sessions = _sessionsBox.values.toList();
    sessions.sort((a, b) => b.startTime.compareTo(a.startTime));
    return sessions.take(limit).toList();
  }

  static Future<void> close() async {
    await _bookmarksBox.close();
    await _progressBox.close();
    await _settingsBox.close();
    await _sessionsBox.close();
  }
}
