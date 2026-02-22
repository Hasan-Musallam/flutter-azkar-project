import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hijri/hijri_calendar.dart';

class PrayerTimesPage extends StatefulWidget {
  const PrayerTimesPage({super.key});
  @override
  State<PrayerTimesPage> createState() => _PrayerTimesPageState();
}

class _PrayerTimesPageState extends State<PrayerTimesPage> {
  PrayerTimes? _prayerTimes;
  String _nextPrayer = '';
  Duration _timeRemaining = Duration.zero;
  int _completedPrayers = 0;
  String _locationName = 'جاري تحديد الموقع...';
  bool _isLoading = true;
  String? _errorMessage;
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await _checkConnectivity();
    await _loadPrayerTimes();
    _updateTimer();
  }

  Future<void> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        _errorMessage = 'لا يوجد اتصال بالإنترنت';
        _isLoading = false;
      });
      return;
    }
  }

  void _updateTimer() {
    if (mounted) {
      setState(() {
        _calculateCurrentPrayer();
      });
      Future.delayed(const Duration(minutes: 1), _updateTimer);
    }
  }

  Future<void> _loadPrayerTimes() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
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
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          setState(() {
            _locationName =
                '${place.locality ?? place.administrativeArea ?? 'موقعك الحالي'}، ${place.country ?? ''}';
          });
        }
      } catch (e) {
        setState(() {
          _locationName = 'موقعك الحالي';
        });
      }
      final coordinates = Coordinates(position.latitude, position.longitude);
      final params = CalculationMethod.umm_al_qura.getParameters();
      params.madhab = Madhab.shafi;
      final times = PrayerTimes.today(coordinates, params);
      setState(() {
        _prayerTimes = times;
        _isLoading = false;
        _errorMessage = null;
        _calculateCurrentPrayer();
      });
    } catch (e) {
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
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _getTimeRemaining() {
    final hours = _timeRemaining.inHours;
    final minutes = _timeRemaining.inMinutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  String _getHijriDate() {
    final now = DateTime.now();
    final hijri = HijriCalendar.fromDate(now);
    return '${hijri.hDay} ${hijri.longMonthName} ${hijri.hYear} هـ';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.green.shade700,
                  Colors.green.shade500,
                  Colors.green.shade300,
                ],
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
              colors: [
                Colors.green.shade700,
                Colors.green.shade500,
                Colors.green.shade300,
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 64),
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
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isLoading = true;
                      _errorMessage = null;
                    });
                    _initializeApp();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.green.shade700,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                  ),
                  child: const Text(
                    'إعادة المحاولة',
                    style: TextStyle(fontSize: 16),
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
            colors: [
              Colors.green.shade700,
              Colors.green.shade500,
              Colors.green.shade300,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            _locationName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh, color: Colors.white),
                          onPressed: () {
                            setState(() {
                              _isLoading = true;
                            });
                            _loadPrayerTimes();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'الصلاة القادمة : $_nextPrayer',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _getTimeRemaining(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 72,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      gregorianDate,
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _getHijriDate(),
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildPrayerRow(
                          'الفجر',
                          _prayerTimes!.fajr,
                          SvgPicture.asset(
                            'assets/data/svgIcons/Fajr.svg',
                            width: 28,
                            height: 28,
                          ),
                        ),
                        const Divider(height: 1),
                        _buildPrayerRow(
                          'الشروق',
                          _prayerTimes!.sunrise,
                          SvgPicture.asset(
                            'assets/data/svgIcons/Duha.svg',
                            width: 28,
                            height: 28,
                          ),
                        ),
                        const Divider(height: 1),
                        _buildPrayerRow(
                          'الظهر',
                          _prayerTimes!.dhuhr,
                          SvgPicture.asset(
                            'assets/data/svgIcons/Dhuhr.svg',
                            width: 28,
                            height: 28,
                          ),
                        ),
                        const Divider(height: 1),
                        _buildPrayerRow(
                          'العصر',
                          _prayerTimes!.asr,
                          SvgPicture.asset(
                            'assets/data/svgIcons/Asr.svg',
                            width: 28,
                            height: 28,
                          ),
                        ),
                        const Divider(height: 1),
                        _buildPrayerRow(
                          'المغرب',
                          _prayerTimes!.maghrib,
                          SvgPicture.asset(
                            'assets/data/svgIcons/Maghrib.svg',
                            width: 28,
                            height: 28,
                          ),
                        ),
                        const Divider(height: 1),
                        _buildPrayerRow(
                          'العشاء',
                          _prayerTimes!.isha,
                          SvgPicture.asset(
                            'assets/data/svgIcons/Isha.svg',
                            width: 28,
                            height: 28,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'لقد قمت بأداء $_completedPrayers / 5 صلوات اليوم',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(5, (index) {
                  final isCompleted = index < _completedPrayers;
                  return Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted
                          ? Colors.green.shade400
                          : Colors.grey.shade300,
                    ),
                    child: Icon(
                      isCompleted ? Icons.check : Icons.close,
                      color: Colors.white,
                      size: 30,
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrayerRow(String name, DateTime time, Widget icon) {
    final isNext = name == _nextPrayer;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      color: isNext ? Colors.green.shade50 : Colors.transparent,
      child: Row(
        children: [
          SizedBox(width: 28, height: 28, child: icon),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontSize: 20,
                fontWeight: isNext ? FontWeight.bold : FontWeight.normal,
                color: isNext ? Colors.green.shade800 : Colors.black87,
              ),
            ),
          ),
          Text(
            _formatTime(time),
            style: TextStyle(
              fontSize: 20,
              fontWeight: isNext ? FontWeight.bold : FontWeight.normal,
              color: isNext ? Colors.green.shade800 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
