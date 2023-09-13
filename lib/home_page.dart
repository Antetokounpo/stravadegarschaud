

import 'package:flutter/material.dart';
import 'package:stravadegarschaud/activity_page.dart';
import 'package:stravadegarschaud/config_page.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _selectedIndex = 0;

  static const List<Widget> _pages = [
    ActivityPage(),
    ConfigPage()
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: _pages.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        }
        ,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.whatshot),
            label: "Activité"
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Configuration"
          ),
        ],
      ),
    );
  }
}