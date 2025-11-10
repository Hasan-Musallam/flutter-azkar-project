import 'package:flutter/material.dart';
import '../models/hive_models.dart';
import '../services/hive_service.dart';
import '../services/islamic_data_service.dart';
import 'package:flutter/foundation.dart';


class AppProvider extends ChangeNotifier {
  HiveAppSettings _settings = HiveAppSettings();
  HiveUserProgress _progress = HiveUserProgress();
  List<HiveBookmark> _bookmarks = [];
  List<HiveReadingSession> _recentSessions = [];
  bool _isLoading = false;

  // Getters
  HiveAppSettings get settings => _settings;
  HiveUserProgress get progress => _progress;
  List<HiveBookmark> get bookmarks => _bookmarks;
  List<HiveReadingSession> get recentSessions => _recentSessions;
  bool get isLoading => _isLoading;
  Map<String, bool> dailyAdhkar = {
    'morning': false,
    'evening': false,
    'sleep': false,
    'travel': false,
    'eating': false,
  };
  
  // في ملف: providers/app_provider.dart
// ... (داخل class AppProvider)

  // ... (بعد باقي الـ Getters)
  
  HiveBookmark? get latestVerseBookmark {
    // 1. نبحث عن كل العلامات المرجعية التي من نوع "آية"
    final verseBookmarks = _bookmarks.where((b) => b.type == 'verse').toList();
    
    // 2. إذا لم نجد أي علامات، نرجع "لا شيء" (null)
    if (verseBookmarks.isEmpty) {
      return null;
    }
    
    // 3. نرجع آخر علامة مرجعية تم إضافتها في القائمة
    return verseBookmarks.last;
  }
  
  // ... (باقي الكود)
void resetProgress() {
  dailyAdhkar.updateAll((key, value) => false);
  notifyListeners();
}

  void completeCategory(String key) {
    dailyAdhkar[key] = true;
    notifyListeners();
  }
 
   void markAzkarCompleted(String categoryKey) {
    progress.dailyAdhkar[categoryKey] = true;
    notifyListeners();
  }
 void resetDailyProgress() {
    progress.dailyAdhkar.updateAll((key, value) => false);
    notifyListeners();
  }
  // Theme methods
  void toggleTheme() {
    _settings.isDarkMode = !_settings.isDarkMode;
    _saveSettings();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }



  // Progress methods
  void updatePagesRead(int pages) {
    _progress.pagesRead = pages;
    _saveProgress();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void updateAdhkarCompleted(int count) {
    _progress.adhkarCompleted = count;
    _saveProgress();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void updateReadingStreak(int streak) {
    _progress.readingStreak = streak;
    _saveProgress();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void updateLastReadPosition(int surahNumber, String surahName, int verse) {
    _progress.lastReadSurahNumber = surahNumber;
    _progress.lastReadSurah = surahName;
    _progress.lastReadVerse = verse;
    _progress.lastActivityDate = DateTime.now();
    _saveProgress();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

void markAdhkarCompleted(String adhkarType) {
  _progress.dailyAdhkar[adhkarType] = true;
  _progress.lastActivityDate = DateTime.now(); // ← تحديث التاريخ
  _saveProgress();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    notifyListeners();
  });
}


void resetDailyAdhkar() {
  final keys = ['morning', 'evening', 'sleep', 'travel', 'eating', 'afterPrayer'];
  for (var key in keys) {
    _progress.dailyAdhkar[key] = false;
  }
  _saveProgress();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    notifyListeners();
  });
}


  // Bookmark methods
  Future<void> addBookmark(HiveBookmark bookmark) async {
    await HiveService.addBookmark(bookmark);
    await _loadBookmarks();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  Future<void> removeBookmark(String bookmarkId) async {
    await HiveService.deleteBookmark(bookmarkId);
    await _loadBookmarks();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  List<HiveBookmark> getBookmarksByType(String type) {
    return _bookmarks.where((bookmark) => bookmark.type == type).toList();
  }

  // Notification methods
  void updateNotificationSettings({
    bool? notificationsEnabled,
    bool? morningAdhkar,
    bool? eveningAdhkar,
    bool? prayerReminders,
    String? morningTime,
    String? eveningTime,
  }) {
    if (notificationsEnabled != null) _settings.notificationsEnabled = notificationsEnabled;
    if (morningAdhkar != null) _settings.morningAdhkar = morningAdhkar;
    if (eveningAdhkar != null) _settings.eveningAdhkar = eveningAdhkar;
    if (prayerReminders != null) _settings.prayerReminders = prayerReminders;
    if (morningTime != null) _settings.morningTime = morningTime;
    if (eveningTime != null) _settings.eveningTime = eveningTime;
    
    _saveSettings();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  // Reading session methods
  Future<void> startReadingSession(int surahNumber, String surahName, int startVerse) async {
    final session = HiveReadingSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      surahNumber: surahNumber,
      surahName: surahName,
      startVerse: startVerse,
      endVerse: startVerse,
      startTime: DateTime.now(),
    );
    
    await HiveService.addReadingSession(session);
    await _loadRecentSessions();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  Future<void> endReadingSession(String sessionId, int endVerse, int pagesRead) async {
    final sessions = _recentSessions.where((s) => s.id == sessionId).toList();
    if (sessions.isNotEmpty) {
      final session = sessions.first;
      session.endTime = DateTime.now();
      session.endVerse = endVerse;
      session.pagesRead = pagesRead;
      session.isCompleted = true;
      
      // Update progress
      _progress.pagesRead += pagesRead;
      _progress.lastReadSurahNumber = session.surahNumber;
      _progress.lastReadSurah = session.surahName;
      _progress.lastReadVerse = endVerse;
      _progress.lastActivityDate = DateTime.now();
      
      await _saveProgress();
      await _loadRecentSessions();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  // Search methods
  List<dynamic> searchContent(String query) {
    final results = <dynamic>[];
    
    // Search Quran
    final quranResults = IslamicDataService.searchQuran(query);
    results.addAll(quranResults);
    
    // Search Adhkar
    final adhkarResults = IslamicDataService.searchAdhkar(query);
    results.addAll(adhkarResults);
    
    return results;
  }

  // Data loading methods
  Future<void> _loadBookmarks() async {
    _bookmarks = HiveService.getAllBookmarks();
  }

  Future<void> _loadRecentSessions() async {
    _recentSessions = HiveService.getRecentSessions();
  }

  // Persistence methods
  Future<void> _saveSettings() async {
    await HiveService.updateSettings(_settings);
  }

  Future<void> _saveProgress() async {
    await HiveService.updateProgress(_progress);
  }

  // Initialize app - simplified version
  Future<void> loadAppState() async {
    if (_isLoading) return;
    
    _isLoading = true;
    
    try {
      // Initialize Hive
      await HiveService.init();
      
      // Load data from Hive
      _settings = HiveService.getSettings();
      _progress = HiveService.getProgress();
      await _loadBookmarks();
      await _loadRecentSessions();
      
      // Check if we need to reset daily adhkar (new day)
      _checkAndResetDailyAdhkar();
      
    } catch (e) {
      print('Error loading app state: $e');
    } finally {
      _isLoading = false;
    }
  }

void _checkAndResetDailyAdhkar() {
  final now = DateTime.now();
  final lastActivity = _progress.lastActivityDate;

  // أول مرة يفتح التطبيق
  // ignore: unnecessary_null_comparison
  if (lastActivity == null) {
    _progress.lastActivityDate = now;
    _saveProgress();
    return;
  }

  // تحقق من اختلاف اليوم
  final isNewDay = now.year != lastActivity.year ||
      now.month != lastActivity.month ||
      now.day != lastActivity.day;

  if (isNewDay) {
    resetDailyAdhkar();
    _progress.lastActivityDate = now;
    _saveProgress();
  }
}


  // Utility methods
  int getTotalBookmarks() => _bookmarks.length;
  int getVerseBookmarks() => _bookmarks.where((b) => b.type == 'verse').length;
  int getAdhkarBookmarks() => _bookmarks.where((b) => b.type == 'adhkar').length;
  
  double getDailyProgress() {
    final totalAdhkar = 6; // morning, evening, prayer, sleep, travel, eating
    final completed = _progress.dailyAdhkar.values.where((completed) => completed).length;
    return completed / totalAdhkar;
  }

  String getNextPrayerName() {
    final nextPrayer = IslamicDataService.getNextPrayer();
    return nextPrayer?['name'] ?? 'Fajr';
  }

  String getNextPrayerTime() {
    final nextPrayer = IslamicDataService.getNextPrayer();
    if (nextPrayer != null) {
      return '${nextPrayer['hour'].toString().padLeft(2, '0')}:${nextPrayer['minute'].toString().padLeft(2, '0')}';
    }
    return '06:00';
  }
}