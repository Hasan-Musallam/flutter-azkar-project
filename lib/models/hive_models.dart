import 'package:hive/hive.dart';

part 'hive_models.g.dart';

@HiveType(typeId: 0)
class HiveBookmark extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String type; // 'verse' or 'adhkar'

  @HiveField(2)
  String title;

  @HiveField(3)
  String subtitle;

  @HiveField(4)
  String arabicText;

  @HiveField(5)
  String translation;

  @HiveField(6)
  DateTime dateAdded;

  @HiveField(7)
  String? surahName;

  @HiveField(8)
  int? verseNumber;

  @HiveField(9)
  int? surahNumber;

  @HiveField(10)
  String? adhkarCategory;

  HiveBookmark({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.arabicText,
    required this.translation,
    required this.dateAdded,
    this.surahName,
    this.verseNumber,
    this.surahNumber,
    this.adhkarCategory,
  });
}

@HiveType(typeId: 1)
class HiveUserProgress extends HiveObject {
  @HiveField(0)
  int pagesRead;

  @HiveField(1)
  int adhkarCompleted;

  @HiveField(2)
  int readingStreak;

  @HiveField(3)
  String lastReadSurah;

  @HiveField(4)
  int lastReadVerse;

  @HiveField(5)
  int lastReadSurahNumber;

  @HiveField(6)
  Map<String, bool> dailyAdhkar;

  @HiveField(7)
  DateTime lastActivityDate;

  @HiveField(8)
  Map<String, int> weeklyProgress;

  HiveUserProgress({
    this.pagesRead = 0,
    this.adhkarCompleted = 0,
    this.readingStreak = 0,
    this.lastReadSurah = 'Al-Fatihah',
    this.lastReadVerse = 1,
    this.lastReadSurahNumber = 1,
    this.dailyAdhkar = const {},
    DateTime? lastActivityDate,
    this.weeklyProgress = const {},
  }) : lastActivityDate = lastActivityDate ?? DateTime.now();

  get values => null;
}

@HiveType(typeId: 2)
class HiveAppSettings extends HiveObject {
  @HiveField(0)
  bool isDarkMode;

  @HiveField(1)
  double fontSize;

  @HiveField(2)
  String language;

  @HiveField(3)
  bool notificationsEnabled;

  @HiveField(4)
  bool morningAdhkar;

  @HiveField(5)
  bool eveningAdhkar;

  @HiveField(6)
  bool prayerReminders;

  @HiveField(7)
  String morningTime;

  @HiveField(8)
  String eveningTime;

  @HiveField(9)
  String audioReciter;

  @HiveField(10)
  String translationLanguage;

  HiveAppSettings({
    this.isDarkMode = false,
    this.fontSize = 16.0,
    this.language = 'en',
    this.notificationsEnabled = true,
    this.morningAdhkar = true,
    this.eveningAdhkar = true,
    this.prayerReminders = false,
    this.morningTime = '06:00',
    this.eveningTime = '18:00',
    this.audioReciter = 'Mishary Rashid Alafasy',
    this.translationLanguage = 'English',
  });
}

@HiveType(typeId: 3)
class HiveReadingSession extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  int surahNumber;

  @HiveField(2)
  String surahName;

  @HiveField(3)
  int startVerse;

  @HiveField(4)
  int endVerse;

  @HiveField(5)
  DateTime startTime;

  @HiveField(6)
  DateTime? endTime;

  @HiveField(7)
  int pagesRead;

  @HiveField(8)
  bool isCompleted;

  HiveReadingSession({
    required this.id,
    required this.surahNumber,
    required this.surahName,
    required this.startVerse,
    required this.endVerse,
    required this.startTime,
    this.endTime,
    this.pagesRead = 0,
    this.isCompleted = false,
  });
}
