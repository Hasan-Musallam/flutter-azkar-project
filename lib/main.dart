// main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'HOME_SCREEN.dart';
import 'QURAN_SCREEN.dart';
import 'ADHKAR_SCREEN.dart';
import 'tasbih_screen.dart';
import 'providers/app_provider.dart';
import 'screens/splash_screen.dart';
import 'PrayerTime.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'services/notification_service.dart';
import 'package:alarm/alarm.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة الإشعارات العادية والمنبه
  await NotificationService.initialize();
  await Alarm.init();

  final appProvider = AppProvider();
  await appProvider.loadAppState();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  // Initialize Hive
  await Hive.initFlutter();

  runApp(const AdhkarQuranApp());
}

class AdhkarQuranApp extends StatelessWidget {
  const AdhkarQuranApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppProvider(),
      child: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          return MaterialApp(
            locale: const Locale('ar'),
            supportedLocales: const [Locale('ar'), Locale('en')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            builder: (context, child) {
              return Directionality(
                textDirection: TextDirection.rtl,
                child: child!,
              );
            },
            debugShowCheckedModeBanner: false,
            title: 'أذكار آمنة',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF0D9488),
                primary: const Color(0xFF0D9488),
                secondary: const Color(0xFF6366F1),
                brightness: Brightness.light,
              ),
              useMaterial3: true,
              fontFamily: 'Amiri',
              scaffoldBackgroundColor: const Color(0xFFF8FAFC),
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.transparent,
                elevation: 0,
                scrolledUnderElevation: 0,
                centerTitle: true,
                titleTextStyle: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
                iconTheme: IconThemeData(color: Color(0xFF1E293B)),
              ),
              cardTheme: CardThemeData(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              textTheme: TextTheme(
                bodyLarge: TextStyle(fontSize: appProvider.settings.fontSize),
                bodyMedium: TextStyle(
                  fontSize: appProvider.settings.fontSize - 2,
                ),
                bodySmall: TextStyle(
                  fontSize: appProvider.settings.fontSize - 4,
                ),
              ),
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF0D9488),
                primary: const Color(0xFF2DD4BF),
                secondary: const Color(0xFF818CF8),
                brightness: Brightness.dark,
                surface: const Color(0xFF1E293B),
              ),
              useMaterial3: true,
              fontFamily: 'Amiri',
              scaffoldBackgroundColor: const Color(0xFF0F172A),
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.transparent,
                elevation: 0,
                scrolledUnderElevation: 0,
                centerTitle: true,
                titleTextStyle: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                iconTheme: IconThemeData(color: Colors.white),
              ),
              cardTheme: CardThemeData(
                elevation: 0,
                color: const Color(0xFF1E293B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              textTheme: TextTheme(
                bodyLarge: TextStyle(fontSize: appProvider.settings.fontSize),
                bodyMedium: TextStyle(
                  fontSize: appProvider.settings.fontSize - 2,
                ),
                bodySmall: TextStyle(
                  fontSize: appProvider.settings.fontSize - 4,
                ),
              ),
            ),
            themeMode: appProvider.settings.isDarkMode
                ? ThemeMode.dark
                : ThemeMode.light,
            initialRoute: '/splash',
            routes: {
              '/splash': (context) => const SplashScreen(),
              '/main': (context) => const MainScreen(),
            },
          );
        },
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 2;
  bool _isInitialized = false;

  final List<Widget> _screens = [
    const QuranScreen(),
    const AdhkarScreen(),
    const HomeScreen(),
    const TasbihScreen(),
    const PrayerTimesPage(),
  ];

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      await appProvider.loadAppState();
      await NotificationService.requestPermissions();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      print('Error initializing app: $e');
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    }
  }

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Notify Provider to trigger rebuilds on screens that care about tab switches
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    appProvider.refreshDataOnTabChange();
  }

  void navigateToTab(int index) {
    _onDestinationSelected(index);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              const Text('جاري التحميل...'),
            ],
          ),
        ),
      );
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF1E293B).withOpacity(0.95)
              : Colors.white.withOpacity(0.95),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  svgPath: 'assets/data/svgIcons/quran-01.svg',
                  label: 'القرآن',
                ),
                _buildNavItem(
                  index: 1,
                  svgPath: 'assets/data/svgIcons/dua.svg',
                  label: 'الأذكار',
                ),
                _buildNavItem(
                  index: 2,
                  icon: Icons.home_rounded,
                  label: 'الرئيسية',
                ),
                _buildNavItem(
                  index: 3,
                  svgPath: 'assets/data/svgIcons/tasbih.svg',
                  label: 'المسبحة',
                ),
                _buildNavItem(
                  index: 4,
                  svgPath: 'assets/data/svgIcons/salah-time.svg',
                  label: 'الصلاة',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    IconData? icon,
    String? svgPath,
    required String label,
  }) {
    final isSelected = _selectedIndex == index;
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _onDestinationSelected(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withOpacity(0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null)
              Icon(
                icon,
                size: isSelected ? 26 : 24,
                color: isSelected
                    ? primaryColor
                    : (isDark ? Colors.white54 : Colors.grey.shade500),
              )
            else if (svgPath != null)
              SvgPicture.asset(
                svgPath,
                width: isSelected ? 26 : 24,
                height: isSelected ? 26 : 24,
                colorFilter: ColorFilter.mode(
                  isSelected
                      ? primaryColor
                      : (isDark ? Colors.white54 : Colors.grey.shade500),
                  BlendMode.srcIn,
                ),
              ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                fontSize: isSelected ? 11 : 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? primaryColor
                    : (isDark ? Colors.white54 : Colors.grey.shade500),
                fontFamily: 'Amiri',
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
