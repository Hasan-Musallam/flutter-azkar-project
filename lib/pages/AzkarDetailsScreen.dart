import 'package:flutter/material.dart';
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
    required this.categoryKey, required String category,
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
      final int count = rawCount is int ? rawCount : int.tryParse(rawCount.toString()) ?? 1;
      _currentCount[i] = count;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: widget.azkarList.length,
        itemBuilder: (context, index) {
          final item = widget.azkarList[index];
          final count = _currentCount[index] ?? 1;

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    item['zekr'] ?? '',
                    textAlign: TextAlign.right,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: 18,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),

                  if ((item['description'] ?? '').isNotEmpty)
                    Text(
                      item['description'],
                      textAlign: TextAlign.right,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),

                  if ((item['reference'] ?? '').isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        item['reference'],
                        textAlign: TextAlign.right,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.45),
                        ),
                      ),
                    ),

                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: count > 0
                        ? () {
                            setState(() {
                              _currentCount[index] = count - 1;
                            });

                            if (count - 1 == 0) {
                              final appProvider = Provider.of<AppProvider>(context, listen: false);
                              appProvider.completeCategory(widget.categoryKey);

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('تم إكمال هذا الذكر ✅')),
                              );
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor:
                          count > 0 ? theme.colorScheme.primary : const Color.fromARGB(255, 15, 15, 15),
                    ),
                    icon: const Icon(Icons.check_circle_outline),
                    label: Text(
                      count > 0
                          ? 'تبقّى $count مرة'
                          : 'تمّ إكمال الذكر 🎉',
                      style: const TextStyle(fontSize: 16, color: Colors.white),
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
