import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import 'assmat_documents_page.dart';
import 'assmat_home_page.dart';
import 'assmat_day_journey_page.dart';
import 'assmat_messages_page.dart';
import 'assmat_profile_page.dart';

/// Shell assmat : 5 onglets persistants + BottomNavigationBar.
class AssMatShell extends StatefulWidget {
  const AssMatShell({super.key});

  @override
  State<AssMatShell> createState() => _AssMatShellState();
}

class _AssMatShellState extends State<AssMatShell> {
  int _currentIndex = 0;

  static const _pages = <Widget>[
    AssMatHomePage(),
    AssMatDayJourneyPage(),
    AssMatMessagesPage(),
    AssMatDocumentsPage(),
    AssMatProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: _AssMatBottomBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

class _AssMatBottomBar extends StatelessWidget {
  const _AssMatBottomBar({
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.secondaryText,
      selectedLabelStyle: AppTextStyles.labelSmall.copyWith(
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: AppTextStyles.labelSmall,
      elevation: 8,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home_rounded),
          label: 'Accueil',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment_outlined),
          activeIcon: Icon(Icons.assignment_rounded),
          label: 'Journal',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline_rounded),
          activeIcon: Icon(Icons.chat_bubble_rounded),
          label: 'Messages',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.description_outlined),
          activeIcon: Icon(Icons.description_rounded),
          label: 'Contrats',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline_rounded),
          activeIcon: Icon(Icons.person_rounded),
          label: 'Profil',
        ),
      ],
    );
  }
}
