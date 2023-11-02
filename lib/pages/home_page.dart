

import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:stravadegarschaud/pages/activity_page.dart';
import 'package:stravadegarschaud/pages/config_page.dart';
import 'package:stravadegarschaud/pages/feed_page.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _selectedIndex = 1;

  static const List<Widget> _pages = [
    FeedPage(),
    ActivityPage(),
    ConfigPage(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: _pages.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        }
        ,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Accueil"
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.whatshot),
            label: "Brosse"
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Configuration"
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: "Profil"
          )
        ],
      ),
    );
  }
}