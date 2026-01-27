import 'package:flutter/material.dart';

class AppBarWidget extends StatelessWidget {
  const AppBarWidget({super.key, this.onPressed});

  final Function? onPressed;

  @override
  Size preferredSize(BuildContext context) {
    return const Size.fromHeight(kTextTabBarHeight);
  }

  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
                'Paaila',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Claim your territory, one step at a time',
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          onPressed: () {
            if (onPressed != null) {
              onPressed!();
            }
          },
        ),
      ],
    );
  }
}
