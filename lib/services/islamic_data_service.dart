// Islamic Data Service for managing Quran and Adhkar data

class IslamicDataService {
  static final IslamicDataService _instance = IslamicDataService._internal();
  factory IslamicDataService() => _instance;
  IslamicDataService._internal();

  // Quran data
  static List<dynamic>? _surahs;
  static List<dynamic>? _ayahs;
  static List<dynamic>? _translations;

  // Adhkar data
  static List<Map<String, dynamic>>? _adhkarCategories;
  static List<Map<String, dynamic>>? _adhkarItems;

  // Prayer times data
  static List<Map<String, dynamic>>? _prayerTimes;

  static Future<void> initialize() async {
    try {
      // Initialize Quran data
      await _loadQuranData();
      
      // Initialize Adhkar data
      await _loadAdhkarData();
      
      // Initialize Prayer times
      await _loadPrayerTimes();
    } catch (e) {
      print('Error initializing Islamic data: $e');
    }
  }

  static Future<void> _loadQuranData() async {
    try {
      // Use quran_library to get surahs
      _surahs = [];
      _ayahs = [];
      _translations = [];
    } catch (e) {
      print('Error loading Quran data: $e');
    }
  }

  static Future<void> _loadAdhkarData() async {
    try {
      _adhkarCategories = [
        {'id': 'morning', 'name': 'Morning Adhkar', 'arabic': 'أذكار الصباح'},
        {'id': 'evening', 'name': 'Evening Adhkar', 'arabic': 'أذكار المساء'},
        {'id': 'prayer', 'name': 'Prayer Adhkar', 'arabic': 'أذكار الصلاة'},
        {'id': 'sleep', 'name': 'Sleep Adhkar', 'arabic': 'أذكار النوم'},
        {'id': 'travel', 'name': 'Travel Adhkar', 'arabic': 'أذكار السفر'},
        {'id': 'eating', 'name': 'Eating Adhkar', 'arabic': 'أذكار الطعام'},
      ];
      
      _adhkarItems = [
        {
          'id': '1',
          'category': 'morning',
          'title': 'Morning Dhikr',
          'arabicText': 'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ ۖ وَالْحَمْدُ لِلَّهِ',
          'translation': 'We have reached the morning and at this very time unto Allah belongs all sovereignty, and all praise is for Allah.',
        },
        {
          'id': '2',
          'category': 'evening',
          'title': 'Evening Dhikr',
          'arabicText': 'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ ۖ وَالْحَمْدُ لِلَّهِ',
          'translation': 'We have reached the evening and at this very time unto Allah belongs all sovereignty, and all praise is for Allah.',
        },
      ];
    } catch (e) {
      print('Error loading Adhkar data: $e');
    }
  }

  static Future<void> _loadPrayerTimes() async {
    try {
      _prayerTimes = [
        {'name': 'Fajr', 'hour': 5, 'minute': 30},
        {'name': 'Dhuhr', 'hour': 12, 'minute': 0},
        {'name': 'Asr', 'hour': 15, 'minute': 30},
        {'name': 'Maghrib', 'hour': 18, 'minute': 0},
        {'name': 'Isha', 'hour': 19, 'minute': 30},
      ];
    } catch (e) {
      print('Error loading prayer times: $e');
    }
  }

  // Quran methods
  static List<dynamic> getSurahs() {
    return _surahs ?? [];
  }

  static dynamic getSurah(int surahNumber) {
    return _surahs?.firstWhere(
      (surah) => surah['number'] == surahNumber,
      orElse: () => null,
    );
  }

  static List<dynamic> getAyahsForSurah(int surahNumber) {
    return _ayahs?.where((ayah) => ayah['surahNumber'] == surahNumber).toList() ?? [];
  }

  static dynamic getAyah(int surahNumber, int ayahNumber) {
    return _ayahs?.firstWhere(
      (ayah) => ayah['surahNumber'] == surahNumber && ayah['number'] == ayahNumber,
      orElse: () => null,
    );
  }

  static List<dynamic> getTranslations() {
    return _translations ?? [];
  }

  static dynamic getTranslation(int surahNumber, int ayahNumber, String language) {
    return _translations?.firstWhere(
      (translation) => 
          translation['surahNumber'] == surahNumber && 
          translation['ayahNumber'] == ayahNumber && 
          translation['language'] == language,
      orElse: () => null,
    );
  }

  // Adhkar methods
  static List<Map<String, dynamic>> getAdhkarCategories() {
    return _adhkarCategories ?? [];
  }

  static List<Map<String, dynamic>> getAdhkarItemsForCategory(String category) {
    return _adhkarItems?.where((item) => item['category'] == category).toList() ?? [];
  }

  static List<Map<String, dynamic>> getMorningAdhkar() {
    return _adhkarItems?.where((item) => item['category'] == 'morning').toList() ?? [];
  }

  static List<Map<String, dynamic>> getEveningAdhkar() {
    return _adhkarItems?.where((item) => item['category'] == 'evening').toList() ?? [];
  }

  static List<Map<String, dynamic>> getPrayerAdhkar() {
    return _adhkarItems?.where((item) => item['category'] == 'prayer').toList() ?? [];
  }

  static List<Map<String, dynamic>> getSleepAdhkar() {
    return _adhkarItems?.where((item) => item['category'] == 'sleep').toList() ?? [];
  }

  static List<Map<String, dynamic>> getTravelAdhkar() {
    return _adhkarItems?.where((item) => item['category'] == 'travel').toList() ?? [];
  }

  static List<Map<String, dynamic>> getEatingAdhkar() {
    return _adhkarItems?.where((item) => item['category'] == 'eating').toList() ?? [];
  }

  // Search methods
  static List<dynamic> searchQuran(String query) {
    if (_ayahs == null) return [];
    
    return _ayahs!.where((ayah) {
      return ayah['arabicText']?.toLowerCase().contains(query.toLowerCase()) == true ||
             ayah['translation']?.toLowerCase().contains(query.toLowerCase()) == true;
    }).toList();
  }

  static List<Map<String, dynamic>> searchAdhkar(String query) {
    if (_adhkarItems == null) return [];
    
    return _adhkarItems!.where((item) {
      return item['arabicText']?.toLowerCase().contains(query.toLowerCase()) == true ||
             item['translation']?.toLowerCase().contains(query.toLowerCase()) == true ||
             item['title']?.toLowerCase().contains(query.toLowerCase()) == true;
    }).toList();
  }

  // Prayer times methods
  static List<Map<String, dynamic>> getPrayerTimes() {
    return _prayerTimes ?? [];
  }

  static Map<String, dynamic>? getNextPrayer() {
    final now = DateTime.now();
    
    final todayPrayers = _prayerTimes?.where((prayer) {
      final prayerTime = DateTime(
        now.year,
        now.month,
        now.day,
        prayer['hour'],
        prayer['minute'],
      );
      return prayerTime.isAfter(now);
    }).toList();
    
    return todayPrayers?.isNotEmpty == true ? todayPrayers!.first : null;
  }

  // Popular surahs
  static List<dynamic> getPopularSurahs() {
    final popularNumbers = [1, 2, 18, 36, 55, 67, 78, 112, 113, 114];
    return _surahs?.where((surah) => popularNumbers.contains(surah['number'])).toList() ?? [];
  }

  // Juz information
  static List<dynamic> getAyahsForJuz(int juzNumber) {
    return _ayahs?.where((ayah) => ayah['juz'] == juzNumber).toList() ?? [];
  }

  // Verse of the day
  static dynamic getVerseOfTheDay() {
    if (_ayahs == null || _ayahs!.isEmpty) return null;
    
    final today = DateTime.now();
    final dayOfYear = today.difference(DateTime(today.year, 1, 1)).inDays;
    final index = dayOfYear % _ayahs!.length;
    
    return _ayahs![index];
  }
}
