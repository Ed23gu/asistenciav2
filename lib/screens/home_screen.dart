import 'package:employee_attendance/screens/attendance_screen.dart';
import 'package:employee_attendance/screens/calender_screen.dart';
import 'package:employee_attendance/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
//import 'package:adaptive_theme/adaptive_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<IconData> navigationIcons = [
    FontAwesomeIcons.solidCalendarDays,
    FontAwesomeIcons.check,
    FontAwesomeIcons.solidUser
  ];

  int currentIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: const [CalenderScreen(), AttendanceScreen(), ProfileScreen()],
      ),
      bottomNavigationBar: Container(
        height: 70,
        margin: const EdgeInsets.only(left: 12, right: 12, bottom: 24),
        decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.white
                //  color: Colors.white,
                : Color.fromARGB(255, 43, 41, 41),
            borderRadius: BorderRadius.all(Radius.circular(40)),
            boxShadow: [
              BoxShadow(
                  color: Color.fromARGB(110, 18, 148, 255),
                  blurRadius: 10,
                  offset: Offset(2, 2))
            ]),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              for (int i = 0; i < navigationIcons.length; i++) ...{
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        currentIndex = i;
                      });
                    },
                    child: Center(
                      child: FaIcon(
                        navigationIcons[i],
                        color: i == currentIndex
                            ? Colors.blue
                            : (Theme.of(context).brightness == Brightness.light
                                ? Colors.black
                                //  color: Colors.white,
                                : Colors.white),
                        size: i == currentIndex ? 30 : 26,
                      ),
                    ),
                  ),
                )
              }
            ]),
      ),
    );
  }
}
