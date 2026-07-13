import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../providers/catalog_providers.dart';
import 'capture_sheet.dart';
import 'habits_view.dart';
import 'ideas_view.dart';
import 'today_view.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _syncMissedLogs();
  }

  Future<void> _syncMissedLogs() async {
    try {
      final service = await ref.read(catalogServiceProvider.future);
      await service.syncMissedLogs();
    } catch (e) {
      debugPrint('syncMissedLogs failed: $e');
    }
  }

  static const _pages = [
    TodayView(),
    HabitsView(),
    IdeasView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/brand/logo.svg',
              height: 26,
              width: 26,
            ),
            const SizedBox(width: 10),
            const Text(
              'Pakai Niat',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
          ],
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          switchInCurve: Curves.easeInOutCubic,
          switchOutCurve: Curves.easeInOutCubic,
          transitionBuilder: (child, animation) {
            final fade = Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeInOutCubic),
            );
            final slide = Tween<Offset>(
              begin: const Offset(0.0, 0.02),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeInOutCubic),
            );
            return FadeTransition(
              opacity: fade,
              child: SlideTransition(position: slide, child: child),
            );
          },
          child: KeyedSubtree(
            key: ValueKey<int>(_currentIndex),
            child: _pages[_currentIndex],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCapture(context),
        child: const Icon(Icons.add_rounded, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.today_outlined),
            selectedIcon: Icon(Icons.today_rounded),
            label: 'Today',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_fire_department_outlined),
            selectedIcon: Icon(Icons.local_fire_department_rounded),
            label: 'Habits',
          ),
          NavigationDestination(
            icon: Icon(Icons.lightbulb_outline_rounded),
            selectedIcon: Icon(Icons.lightbulb_rounded),
            label: 'Ideas',
          ),
        ],
      ),
    );
  }

  void _showCapture(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CaptureSheet(),
    );
  }
}
