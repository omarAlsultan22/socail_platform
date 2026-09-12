import 'package:flutter/material.dart';


class MenuButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;

  const MenuButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 200.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Colors.grey,
        ),
        child: InkWell(
          onTap: () => onTap(), // Call the function here
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 50.0,
              ),
              Text(
                text,
                style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}