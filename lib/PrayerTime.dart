import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hijri/hijri_calendar.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/notification_service.dart';

class PrayerTimesPage extends StatefulWidget {
  const PrayerTimesPage({super.key});
  @override
  State<PrayerTimesPage> createState() => _PrayerTimesPageState();
}

class _PrayerTimesPageState extends State<PrayerTimesPage>
    with SingleTickerProviderStateMixin {
  PrayerTimes? _prayerTimes;
  String _nextPrayer = '';
  Duration _timeRemaining = Duration.zero;
  int _completedPrayers = 0;
  String _locationName = 'جاري تحديد الموقع...';
  bool _isLoading = true;
  String? _errorMessage;
  Timer? _timer;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _initializeApp();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    await _checkConnectivity();
    await _loadPrayerTimes();
    _startTimer();
    _animController.forward();
  }

  Future<void> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (!mounted) return;
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        _errorMessage = 'لا يوجد اتصال بالإنترنت';
        _isLoading = false;
      });
      return;
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _calculateCurrentPrayer();
        });
      }
    });
  }

  Future<void> _loadPrayerTimes() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (!mounted) return;
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (!mounted) return;
        if (permission == LocationPermission.denied) {
          setState(() {
            _errorMessage = 'تم رفض صلاحيات الموقع';
            _isLoading = false;
          });
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _errorMessage =
              'صلاحيات الموقع مرفوضة بشكل دائم. يرجى تفعيلها من الإعدادات';
          _isLoading = false;
        });
        return;
      }
      setState(() {
        _locationName = 'جاري تحديد موقعك...';
      });
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setDouble('last_lat', position.latitude);
        await prefs.setDouble('last_lng', position.longitude);
      } catch (e) {
        // Ignored
      }
      if (!mounted) return;
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (!mounted) return;
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          setState(() {
            _locationName =
                '${place.locality ?? place.administrativeArea ?? 'موقعك الحالي'}، ${place.country ?? ''}';
          });
        }
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _locationName = 'موقعك الحالي';
        });
      }
      final coordinates = Coordinates(position.latitude, position.longitude);
      final params = CalculationMethod.umm_al_qura.getParameters();
      params.madhab = Madhab.shafi;
      final times = PrayerTimes.today(coordinates, params);

      if (!mounted) return;
      setState(() {
        _prayerTimes = times;
        _isLoading = false;
        _errorMessage = null;
        _calculateCurrentPrayer();
      });

      _scheduleNotificationsForNextDays(coordinates, params);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'حدث خطأ في تحديد الموقع: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _calculateCurrentPrayer() {
    if (_prayerTimes == null) return;
    final now = DateTime.now();
    final prayers = [
      {'name': 'الفجر', 'time': _prayerTimes!.fajr},
      {'name': 'الشروق', 'time': _prayerTimes!.sunrise},
      {'name': 'الظهر', 'time': _prayerTimes!.dhuhr},
      {'name': 'العصر', 'time': _prayerTimes!.asr},
      {'name': 'المغرب', 'time': _prayerTimes!.maghrib},
      {'name': 'العشاء', 'time': _prayerTimes!.isha},
    ];
    _completedPrayers = 0;
    _nextPrayer = '';
    for (int i = 0; i < prayers.length; i++) {
      final prayerTime = prayers[i]['time'] as DateTime;
      if (now.isBefore(prayerTime)) {
        _nextPrayer = prayers[i]['name'] as String;
        _timeRemaining = prayerTime.difference(now);
        if (i > 0) {
          _completedPrayers = i > 1 ? i - 1 : 0;
        }
        break;
      }
    }
    if (_nextPrayer.isEmpty) {
      _nextPrayer = 'الفجر';
      _completedPrayers = 5;
    }
  }

  String _formatTime(DateTime time) {
    final hour24 = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = hour24 >= 12 ? 'م' : 'ص';
    final hour12 = hour24 == 0 ? 12 : (hour24 > 12 ? hour24 - 12 : hour24);
    return '$hour12:$minute $period';
  }

  String _getTimeRemaining() {
    final hours = _timeRemaining.inHours;
    final minutes = _timeRemaining.inMinutes % 60;
    final seconds = _timeRemaining.inSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _getHijriDate() {
    final now = DateTime.now();
    final hijri = HijriCalendar.fromDate(now);
    const arabicMonths = [
      'محرم',
      'صفر',
      'ربيع الأول',
      'ربيع الآخر',
      'جمادى الأولى',
      'جمادى الآخرة',
      'رجب',
      'شعبان',
      'رمضان',
      'شوال',
      'ذو القعدة',
      'ذو الحجة',
    ];
    final monthName = arabicMonths[hijri.hMonth - 1];
    return '${hijri.hDay} $monthName ${hijri.hYear} هـ';
  }

  void _scheduleNotificationsForNextDays(
    Coordinates coordinates,
    CalculationParameters params,
  ) async {
    await NotificationService.cancelAllNotifications();

    final now = DateTime.now();
    int notificationId = 1;

    for (int i = 0; i < 7; i++) {
      final date = now.add(Duration(days: i));
      final dateComponents = DateComponents(date.year, date.month, date.day);
      final times = PrayerTimes(coordinates, dateComponents, params);

      await NotificationService.schedulePrayerNotification(
        notificationId++,
        'حان الآن موعد أذان الفجر',
        'الصلاة خير من النوم',
        times.fajr,
      );

      await NotificationService.schedulePrayerNotification(
        notificationId++,
        'حان الآن موعد أذان الظهر',
        'حي على الصلاة',
        times.dhuhr,
      );

      await NotificationService.schedulePrayerNotification(
        notificationId++,
        'حان الآن موعد أذان العصر',
        'حي على الصلاة',
        times.asr,
      );

      await NotificationService.schedulePrayerNotification(
        notificationId++,
        'حان الآن موعد أذان المغرب',
        'حي على الصلاة',
        times.maghrib,
      );

      await NotificationService.schedulePrayerNotification(
        notificationId++,
        'حان الآن موعد أذان العشاء',
        'حي على الصلاة',
        times.isha,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
                  : [const Color(0xFF0D9488), const Color(0xFF0F766E)],
            ),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(height: 20),
                Text(
                  'جاري تحديد موقعك وحساب أوقات الصلاة...',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
                  : [const Color(0xFF0D9488), const Color(0xFF0F766E)],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.error_outline,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isLoading = true;
                      _errorMessage = null;
                    });
                    _initializeApp();
                  },
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text(
                    'إعادة المحاولة',
                    style: TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF0D9488),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final now = DateTime.now();
    final gregorianDate = DateFormat('EEEE، d MMMM', 'ar').format(now);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
                : [const Color(0xFF0D9488), const Color(0xFF0F766E)],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Location
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.location_on_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              _locationName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.refresh_rounded,
                              color: Colors.white70,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() => _isLoading = true);
                              _loadPrayerTimes();
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Next prayer label
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'الصلاة القادمة: $_nextPrayer',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Countdown timer
                      Text(
                        _getTimeRemaining(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 64,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Dates
                      Text(
                        gregorianDate,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _getHijriDate(),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),

                // Prayer times list
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E293B).withOpacity(0.9)
                          : Colors.white.withOpacity(0.95),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(32),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 4),
                          _buildPrayerCard(
                            'الفجر',
                            _prayerTimes!.fajr,
                            SvgPicture.asset(
                              'assets/data/svgIcons/Fajr.svg',
                              width: 28,
                              height: 28,
                            ),
                            isDark,
                          ),
                          _buildPrayerCard(
                            'الشروق',
                            _prayerTimes!.sunrise,
                            SvgPicture.asset(
                              'assets/data/svgIcons/Duha.svg',
                              width: 28,
                              height: 28,
                            ),
                            isDark,
                          ),
                          _buildPrayerCard(
                            'الظهر',
                            _prayerTimes!.dhuhr,
                            SvgPicture.asset(
                              'assets/data/svgIcons/Dhuhr.svg',
                              width: 28,
                              height: 28,
                            ),
                            isDark,
                          ),
                          _buildPrayerCard(
                            'العصر',
                            _prayerTimes!.asr,
                            SvgPicture.asset(
                              'assets/data/svgIcons/Asr.svg',
                              width: 28,
                              height: 28,
                            ),
                            isDark,
                          ),
                          _buildPrayerCard(
                            'المغرب',
                            _prayerTimes!.maghrib,
                            SvgPicture.asset(
                              'assets/data/svgIcons/Maghrib.svg',
                              width: 28,
                              height: 28,
                            ),
                            isDark,
                          ),
                          _buildPrayerCard(
                            'العشاء',
                            _prayerTimes!.isha,
                            SvgPicture.asset(
                              'assets/data/svgIcons/Isha.svg',
                              width: 28,
                              height: 28,
                            ),
                            isDark,
                          ),
                          const SizedBox(height: 12),
                          // Prayer progress
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withOpacity(0.05)
                                  : const Color(0xFF0D9488).withOpacity(0.08),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ...List.generate(5, (index) {
                                  final isCompleted = index < _completedPrayers;
                                  return Container(
                                    width: 40,
                                    height: 40,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: isCompleted
                                          ? const LinearGradient(
                                              colors: [
                                                Color(0xFF10B981),
                                                Color(0xFF059669),
                                              ],
                                            )
                                          : null,
                                      color: isCompleted
                                          ? null
                                          : (isDark
                                                ? Colors.white.withOpacity(0.1)
                                                : Colors.grey.shade200),
                                    ),
                                    child: Icon(
                                      isCompleted
                                          ? Icons.check_rounded
                                          : Icons.circle_outlined,
                                      color: isCompleted
                                          ? Colors.white
                                          : Colors.grey.shade400,
                                      size: 20,
                                    ),
                                  );
                                }),
                                const SizedBox(width: 12),
                                Text(
                                  '$_completedPrayers / 5',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrayerCard(
    String name,
    DateTime time,
    Widget icon,
    bool isDark,
  ) {
    final isNext = name == _nextPrayer;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: isNext
            ? (isDark
                  ? const Color(0xFF0D9488).withOpacity(0.15)
                  : const Color(0xFF0D9488).withOpacity(0.1))
            : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: isNext
            ? Border.all(
                color: const Color(0xFF0D9488).withOpacity(0.3),
                width: 1.5,
              )
            : null,
      ),
      child: Row(
        children: [
          SizedBox(width: 28, height: 28, child: icon),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontSize: 18,
                fontWeight: isNext ? FontWeight.bold : FontWeight.normal,
                color: isNext
                    ? const Color(0xFF0D9488)
                    : (isDark ? Colors.white70 : Colors.black87),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isNext
                  ? const Color(0xFF0D9488).withOpacity(0.15)
                  : (isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.grey.shade100),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              _formatTime(time),
              style: TextStyle(
                fontSize: 18,
                fontWeight: isNext ? FontWeight.bold : FontWeight.w500,
                color: isNext
                    ? const Color(0xFF0D9488)
                    : (isDark ? Colors.white70 : Colors.black87),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
