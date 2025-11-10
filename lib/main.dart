// main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'HOME_SCREEN.dart';
import 'QURAN_SCREEN.dart';
import 'ADHKAR_SCREEN.dart';  
import 'providers/app_provider.dart';
import 'screens/splash_screen.dart';
import 'PrayerTime.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
            locale: const Locale('ar'), // اللغة العربية
  supportedLocales: const [
    Locale('ar'), // عربي
    Locale('en'), // إنجليزي (إذا حابب تدعمه)
  ],
  localizationsDelegates: const [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
   builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl, // جعل كل شيء RTL
          child: child!,
        );
      },

              debugShowCheckedModeBanner: false,
              title: 'Adhkar Amna',
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: const Color.fromRGBO(16, 185, 129, 1),
                  brightness: Brightness.light,
                ),
                useMaterial3: true,
                fontFamily: 'Inter',
                textTheme: TextTheme(
                  bodyLarge: TextStyle(fontSize: appProvider.settings.fontSize),
                  bodyMedium: TextStyle(fontSize: appProvider.settings.fontSize - 2),
                  bodySmall: TextStyle(fontSize: appProvider.settings.fontSize - 4),
                ),
              ),
              darkTheme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: const Color.fromRGBO(16, 185, 129, 1),
                  brightness: Brightness.dark,
                ),
                useMaterial3: true,
                fontFamily: 'Inter',
                textTheme: TextTheme(
                  bodyLarge: TextStyle(fontSize: appProvider.settings.fontSize),
                  bodyMedium: TextStyle(fontSize: appProvider.settings.fontSize - 2),
                  bodySmall: TextStyle(fontSize: appProvider.settings.fontSize - 4),
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
  int _selectedIndex = 0;
  bool _isInitialized = false;

  final List<Widget> _screens = [
    const HomeScreen(),
    const QuranScreen(),
    const AdhkarScreen(),
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
  }

  void navigateToTab(int index) {
    _onDestinationSelected(index);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading...'),
            ],
          ),
        ),
      );
    }
    
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
     
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations:  [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            
            label: 'الرئيسية',
          ),
          NavigationDestination(
            icon: SvgPicture.asset(
              'assets/data/svgIcons/quran-01.svg',
              width: 24,
              height: 24,
              
            ),
            selectedIcon: SvgPicture.asset(
              'assets/data/svgIcons/quran-01.svg',
              width: 24,
              height: 24,
              
            ),
            label: 'القرآن',
          ),
          NavigationDestination(
            icon: SvgPicture.asset(
              'assets/data/svgIcons/zakat.svg',
              width: 24,
              height: 24,
              
            ),
            selectedIcon:SvgPicture.asset(
              'assets/data/svgIcons/zakat.svg',
              width: 24,
              height: 24,
              
            ),
            label: 'الأذكار',
          ),
          NavigationDestination(
            icon: SvgPicture.asset(
              'assets/data/svgIcons/salah-time.svg',
              width: 24,
              height: 24,
              
            ),
            selectedIcon:  SvgPicture.asset(
              'assets/data/svgIcons/salah-time.svg',
              width: 24,
              height: 24,
              
            ),
            label: 'مواقيت الصلاة',
          ),
            
          

        ],
      ),
    );
  }

}