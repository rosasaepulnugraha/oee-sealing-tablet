import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:isuzu_oee_app/profile_screen.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

import '../constants/color_constant.dart';
import '../home_screen.dart';

void main() {
  runApp(NavigateScreen(
    id: 0,
  ));
}

class NavigateScreen extends StatefulWidget {
  static final title = 'salomon_bottom_bar';
  int id;
  NavigateScreen({Key? key, required this.id}) : super(key: key);

  @override
  _NavigateScreenState createState() => _NavigateScreenState();
}

class _NavigateScreenState extends State<NavigateScreen> {
  var _currentIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    // HomeScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    //_getList();
    _currentIndex = widget.id;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: const Locale('en', 'US'),
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [
        Locale('en', 'GB'),
        Locale('en', 'US'),
        Locale('ar'),
        Locale('zh'),
      ],
      title: NavigateScreen.title,
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        body: Container(
          color: Color.fromARGB(0, 231, 231, 231),
          child: Center(child: _widgetOptions.elementAt(_currentIndex)),
        ),
        bottomNavigationBar: Container(
          height: 84,
          decoration: BoxDecoration(
            color: mFillColor,
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 15,
                  offset: Offset(0, 5))
            ],
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: SalomonBottomBar(
            currentIndex: _currentIndex,
            onTap: (i) => setState(() => _currentIndex = i),
            items: [
              /// NavigateScreen
              SalomonBottomBarItem(
                icon: Icon(Icons.space_dashboard_outlined),
                title: Text("Home"),
                selectedColor: mBlueColor,
                unselectedColor: Color.fromARGB(255, 121, 121, 121),
              ),

              /// Search
              SalomonBottomBarItem(
                icon: Icon(Icons.person_rounded),
                title: Text("Profile"),
                selectedColor: mBlueColor,
                unselectedColor: Color.fromARGB(255, 121, 121, 121),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
