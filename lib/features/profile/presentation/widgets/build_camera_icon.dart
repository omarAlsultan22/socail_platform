import 'package:flutter/material.dart';


class BuildCameraIcon extends StatelessWidget {
  final double left;
  final double top;
  final VoidCallback onTap;

  const BuildCameraIcon({
    required this.left,
    required this.top,
    required this.onTap,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: left, top: top),
      child: ClipOval(
        child: Material(
          child: InkWell(
            splashColor: Colors.blue,
            onTap: onTap,
            child:
            SizedBox(
              width: 30.0,
              height: 30.0,
              child: Icon(Icons.camera),
            ),
          ),
        ),
      ),
    );
  }
}