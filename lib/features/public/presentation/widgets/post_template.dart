import 'package:flutter/material.dart';
import 'package:social_app/core/themes/app_theme.dart';


class PostTemplate extends StatelessWidget {
  final bool animationToggle;

  const PostTemplate({
    super.key,
    required this.animationToggle
  });

  Color _toggleTheme(BuildContext context) =>
      AppTheme.getAdaptiveColor(context,
          firstColor: animationToggle ? Colors.transparent : Colors.black12,
          secondColor: animationToggle ? Colors.transparent : Colors.black87
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: 20.0,
            left: 12.0,
            bottom: 15.0,
            right: 15.0,
          ),
          child: ClipOval(
            child: Material(
              child: InkWell(
                child: AnimatedContainer(
                  duration: Duration(seconds: 1),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                      color: _toggleTheme(context),
                      borderRadius: BorderRadius.circular(50.0),
                      border: Border.all(
                          color: Colors.grey.shade400,
                          width: 1.0),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4.0

                        )
                      ]),
                  width: 50.0,
                  height: 50.0,
                ),
              ),
            ),
          ),
        ),
        AnimatedContainer(
          duration: Duration(seconds: 1),
          width: double.infinity,
          height: 400.0,
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
              color: _toggleTheme(context),
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                  color: Colors.grey.shade400,
                  width: 1.0),
              boxShadow: [
                BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4.0
                )
              ]
          ),
        ),
      ],
    );
  }
}
