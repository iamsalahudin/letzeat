import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letzeat/utils/constant.dart';
import 'package:letzeat/views/chat_bot.dart';
import 'package:letzeat/views/favorite.dart';
import 'package:letzeat/views/home.dart';
import 'package:letzeat/views/meal_plan.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int selectedIndex = 0;
  late final List<Widget> page;
  @override
  void initState() {
    page = [const Home(), const Favorite(), const MealPlan(), ChatBotPage()];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: selectedIndex,
        elevation: 0,
        selectedItemColor: kPrimaryColor,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(
          color: kPrimaryColor,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        iconSize: 28,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(selectedIndex == 0 ? Iconsax.home5 : Iconsax.home_1),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(selectedIndex == 1 ? Iconsax.heart5 : Iconsax.heart),
            label: 'Favorite',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              selectedIndex == 2 ? Iconsax.calendar5 : Iconsax.calendar,
            ),
            label: 'Meal Plan',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              selectedIndex == 3
                  ? Icons.chat_bubble
                  : Icons.chat_bubble_outline,
            ),
            label: 'My AI',
          ),
        ],
      ),
      body: page[selectedIndex],
    );
  }

  navBarPage(iconName) {
    return Center(child: Icon(iconName, size: 100, color: kPrimaryColor));
  }
}
