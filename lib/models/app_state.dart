
// App Theme State
class AppThemeState {
  final bool isDarkMode;
  final double fontSize;
  final String language;

  AppThemeState({
    this.isDarkMode = false,
    this.fontSize = 16.0,
    this.language = 'en',
  });

  AppThemeState copyWith({
    bool? isDarkMode,
    double? fontSize,
    String? language,
  }) {
    return AppThemeState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      fontSize: fontSize ?? this.fontSize,
      language: language ?? this.language,
    );
  }
}

// User Progress State
class UserProgress {
  final int pagesRead;
  final int adhkarCompleted;
  final int readingStreak;
  final Map<String, bool> dailyAdhkar;
  final String lastReadSurah;
  final int lastReadVerse;

  UserProgress({
    this.pagesRead = 0,
    this.adhkarCompleted = 0,
    this.readingStreak = 0,
    this.dailyAdhkar = const {},
    this.lastReadSurah = 'Al-Fatihah',
    this.lastReadVerse = 1,
  });

  UserProgress copyWith({
    int? pagesRead,
    int? adhkarCompleted,
    int? readingStreak,
    Map<String, bool>? dailyAdhkar,
    String? lastReadSurah,
    int? lastReadVerse,
  }) {
    return UserProgress(
      pagesRead: pagesRead ?? this.pagesRead,
      adhkarCompleted: adhkarCompleted ?? this.adhkarCompleted,
      readingStreak: readingStreak ?? this.readingStreak,
      dailyAdhkar: dailyAdhkar ?? this.dailyAdhkar,
      lastReadSurah: lastReadSurah ?? this.lastReadSurah,
      lastReadVerse: lastReadVerse ?? this.lastReadVerse,
    );
  }
}

// Bookmark Model
class Bookmark {
  final String id;
  final String type; // 'verse' or 'adhkar'
  final String title;
  final String subtitle;
  final String arabicText;
  final String translation;
  final DateTime dateAdded;
  final String? surahName;
  final int? verseNumber;

  Bookmark({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.arabicText,
    required this.translation,
    required this.dateAdded,
    this.surahName,
    this.verseNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'subtitle': subtitle,
      'arabicText': arabicText,
      'translation': translation,
      'dateAdded': dateAdded.toIso8601String(),
      'surahName': surahName,
      'verseNumber': verseNumber,
    };
  }

  factory Bookmark.fromJson(Map<String, dynamic> json) {
    return Bookmark(
      id: json['id'],
      type: json['type'],
      title: json['title'],
      subtitle: json['subtitle'],
      arabicText: json['arabicText'],
      translation: json['translation'],
      dateAdded: DateTime.parse(json['dateAdded']),
      surahName: json['surahName'],
      verseNumber: json['verseNumber'],
    );
  }
}

// Notification Settings
class NotificationSettings {
  final bool notificationsEnabled;
  final bool morningAdhkar;
  final bool eveningAdhkar;
  final bool prayerReminders;
  final String morningTime;
  final String eveningTime;

  NotificationSettings({
    this.notificationsEnabled = true,
    this.morningAdhkar = true,
    this.eveningAdhkar = true,
    this.prayerReminders = false,
    this.morningTime = '06:00',
    this.eveningTime = '18:00',
  });

  NotificationSettings copyWith({
    bool? notificationsEnabled,
    bool? morningAdhkar,
    bool? eveningAdhkar,
    bool? prayerReminders,
    String? morningTime,
    String? eveningTime,
  }) {
    return NotificationSettings(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      morningAdhkar: morningAdhkar ?? this.morningAdhkar,
      eveningAdhkar: eveningAdhkar ?? this.eveningAdhkar,
      prayerReminders: prayerReminders ?? this.prayerReminders,
      morningTime: morningTime ?? this.morningTime,
      eveningTime: eveningTime ?? this.eveningTime,
    );
  }
}
