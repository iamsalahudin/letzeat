import 'package:flutter/material.dart';
import 'package:letzeat/utils/constant.dart';

class BannerToExplore extends StatelessWidget {
  const BannerToExplore({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 170,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: kBannerColor,
      ),
      child: Stack(
        children: [
          Positioned(
            top: 50,
            left: 20,
            child: Text(
              'Cook the best\nrecipes at home',
              style: TextStyle(
                height: 1.1,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Positioned(
            top: 0,
            bottom: 0,
            right: -20,
            child: Image.asset('assets/images/chef.png'),
          ),
        ],
      ),
    );
  }
}
