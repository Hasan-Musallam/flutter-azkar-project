import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class AzkarDetailsScreen extends StatefulWidget {
  final String title;
  final List<dynamic> azkarList;
  final String categoryKey;

  const AzkarDetailsScreen({
    super.key,
    required this.title,
    required this.azkarList,
    required this.categoryKey,
    required String category,
  });

  @override
  State<AzkarDetailsScreen> createState() => _AzkarDetailsScreenState();
}

class _AzkarDetailsScreenState extends State<AzkarDetailsScreen> {
  final Map<int, int> _currentCount = {};

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.azkarList.length; i++) {
      final rawCount = widget.azkarList[i]['count'] ?? 1;
      final int count = rawCount is int
          ? rawCount
          : int.tryParse(rawCount.toString()) ?? 1;
      _currentCount[i] = count;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(fontFamily: 'Amiri', fontSize: 20),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: widget.azkarList.length,
        itemBuilder: (context, index) {
          final item = widget.azkarList[index];
          final count = _currentCount[index] ?? 1;
          final isCompleted = count <= 0;

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isCompleted
                    ? const Color(0xFF10B981).withOpacity(0.3)
                    : (isDark
                          ? Colors.white.withOpacity(0.08)
                          : Colors.grey.shade200),
                width: isCompleted ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isCompleted
                      ? const Color(0xFF10B981).withOpacity(0.1)
                      : Colors.black.withOpacity(0.03),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Zikr number
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D9488).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Color(0xFF0D9488),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (isCompleted)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                color: Color(0xFF10B981),
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'تم',
                                style: TextStyle(
                                  color: Color(0xFF10B981),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Zikr text
                  Text(
                    item['zekr'] ?? '',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 18,
                      height: 1.8,
                      fontFamily: 'Amiri',
                      color: isCompleted
                          ? theme.colorScheme.onSurface.withOpacity(0.5)
                          : theme.colorScheme.onSurface,
                    ),
                  ),

                  if ((item['description'] ?? '').isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.03)
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        item['description'],
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],

                  if ((item['reference'] ?? '').isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        item['reference'],
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withOpacity(0.4),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Count button
                  GestureDetector(
                    onTap: count > 0
                        ? () {
                            HapticFeedback.lightImpact();
                            setState(() {
                              _currentCount[index] = count - 1;
                            });

                            if (count - 1 == 0) {
                              final appProvider = Provider.of<AppProvider>(
                                context,
                                listen: false,
                              );
                              appProvider.completeCategory(widget.categoryKey);

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.check_circle_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text('تم إكمال هذا الذكر ✅'),
                                    ],
                                  ),
                                  backgroundColor: const Color(0xFF10B981),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  margin: const EdgeInsets.all(16),
                                ),
                              );
                            }
                          }
                        : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: count > 0
                            ? const LinearGradient(
                                colors: [Color(0xFF0D9488), Color(0xFF0F766E)],
                              )
                            : null,
                        color: count <= 0
                            ? (isDark
                                  ? const Color(0xFF10B981).withOpacity(0.15)
                                  : const Color(0xFF10B981).withOpacity(0.1))
                            : null,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: count > 0
                            ? [
                                BoxShadow(
                                  color: const Color(
                                    0xFF0D9488,
                                  ).withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            count > 0
                                ? Icons.touch_app_rounded
                                : Icons.check_circle_rounded,
                            color: count > 0
                                ? Colors.white
                                : const Color(0xFF10B981),
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            count > 0
                                ? 'تبقّى $count مرة'
                                : 'تمّ إكمال الذكر 🎉',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: count > 0
                                  ? Colors.white
                                  : const Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
