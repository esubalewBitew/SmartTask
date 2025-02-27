import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smarttask/core/extensions/context_extensions.dart';
import 'package:smarttask/core/common/presentation/widgets/main_bottom_nav_bar.dart';
import 'package:smarttask/core/common/presentation/widgets/main_bottom_nav_bar_driver.dart';
import 'package:smarttask/features/Main/Home/presentation/view/home_page.dart';
import 'package:smarttask/features/Main/Analytics/presentation/view/analytics_page.dart';
import 'package:smarttask/features/Main/Profile/presentation/view/profile_page.dart';
import 'package:smarttask/features/Main/Tasks/presentation/view/tasks_page.dart';
import 'package:smarttask/features/Main/Workspace/presentation/view/workspace_list_screen.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  late PageController _pageController;

  final List<Widget> _pages = [
    HomePage(),
    TasksPage(),
    WorkspaceListScreen(),
    AnalyticsPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
  }

  void _onItemTapped(int index) {
    _pageController.jumpToPage(index);
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const NeverScrollableScrollPhysics(),
        children: _pages,
      ),
      bottomNavigationBar: MainBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
