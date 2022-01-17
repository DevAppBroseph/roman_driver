import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:ridbrain_project/screens/admin_accoun.dart';
import 'package:ridbrain_project/screens/admin_calendar.dart';

class AdminScreen extends StatefulWidget {
  AdminScreen({Key? key}) : super(key: key);

  @override
  _AdminScreenState createState() => _AdminScreenState();
}

final List<BottomNavigationBarItem> _tabBar = [
  BottomNavigationBarItem(
    icon: Icon(LineIcons.calendar),
    label: "Календарь",
  ),
  BottomNavigationBarItem(
    icon: Icon(LineIcons.userCircle),
    label: "Профиль",
  ),
];

class _AdminScreenState extends State<AdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabBar.length, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedItemColor: Colors.black,
        backgroundColor: Colors.white,
        onTap: (index) {
          setState(() {
            _tabController.index = index;
            _currentTabIndex = index;
          });
        },
        currentIndex: _currentTabIndex,
        items: _tabBar,
      ),
      backgroundColor: Colors.white,
      body: TabBarView(
        controller: _tabController,
        children: const [
          AdminCalendar(),
          AdminAccount(),
        ],
      ),
    );
  }
}
