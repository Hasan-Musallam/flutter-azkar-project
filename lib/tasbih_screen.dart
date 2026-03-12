import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TasbihScreen extends StatefulWidget {
  const TasbihScreen({super.key});

  @override
  State<TasbihScreen> createState() => _TasbihScreenState();
}

class _TasbihScreenState extends State<TasbihScreen>
    with SingleTickerProviderStateMixin {
  int _count = 0;
  int _totalCount = 0;
  int _selectedIndex = 0;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final List<Map<String, dynamic>> _tasbihTypes = [
    {'text': 'سُبْحَانَ اللهِ', 'color': const Color(0xFF10B981)},
    {'text': 'الحَمْدُ لِلّهِ', 'color': const Color(0xFF3B82F6)},
    {'text': 'اللهُ أَكْبَرُ', 'color': const Color(0xFFF59E0B)},
    {'text': 'لا إلهَ إلّا اللهُ', 'color': const Color(0xFF8B5CF6)},
    {
      'text': 'لا حَوْلَ وَلا قُوَّةَ إلّا بِاللهِ',
      'color': const Color(0xFFEF4444),
    },
    {'text': 'أَسْتَغْفِرُ اللهَ', 'color': const Color(0xFF06B6D4)},
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _incrementCount() {
    HapticFeedback.lightImpact();
    _pulseController.forward().then((_) => _pulseController.reverse());
    setState(() {
      _count++;
      _totalCount++;
    });
  }

  void _resetCount() {
    HapticFeedback.mediumImpact();
    setState(() {
      _count = 0;
    });
  }

  Color get _activeColor => _tasbihTypes[_selectedIndex]['color'] as Color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
                : [_activeColor.withOpacity(0.05), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'المسبحة',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Amiri',
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Tasbih type selector
              SizedBox(
                height: 48,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _tasbihTypes.length,
                  itemBuilder: (context, index) {
                    final isSelected = index == _selectedIndex;
                    final color = _tasbihTypes[index]['color'] as Color;
                    return Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: ChoiceChip(
                          label: Text(
                            _tasbihTypes[index]['text'] as String,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? Colors.white70 : Colors.black87),
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 13,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: color,
                          backgroundColor: isDark
                              ? Colors.white.withOpacity(0.08)
                              : Colors.grey.shade100,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected ? color : Colors.transparent,
                            ),
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedIndex = index;
                                _count = 0;
                              });
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),

              const Spacer(flex: 1),

              // Tasbih text
              Text(
                _tasbihTypes[_selectedIndex]['text'] as String,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Amiri',
                  color: _activeColor,
                ),
              ),

              const SizedBox(height: 32),

              // Count display
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: Text(
                  '$_count',
                  key: ValueKey<int>(_count),
                  style: TextStyle(
                    fontSize: 80,
                    fontWeight: FontWeight.w900,
                    color: _activeColor,
                    height: 1,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'الإجمالي: $_totalCount',
                style: TextStyle(
                  fontSize: 16,
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),

              const Spacer(flex: 1),

              // Big tap button
              GestureDetector(
                onTap: _incrementCount,
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: child,
                    );
                  },
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [_activeColor, _activeColor.withOpacity(0.7)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _activeColor.withOpacity(0.4),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.touch_app_rounded,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              const Spacer(flex: 1),

              // Reset button
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: TextButton.icon(
                  onPressed: _resetCount,
                  icon: Icon(Icons.refresh_rounded, color: _activeColor),
                  label: Text(
                    'إعادة العد',
                    style: TextStyle(
                      color: _activeColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: _activeColor.withOpacity(0.3)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
