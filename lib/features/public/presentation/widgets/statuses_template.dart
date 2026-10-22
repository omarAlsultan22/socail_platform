import 'package:flutter/material.dart';
import '../../../../core/themes/app_theme.dart';


class StatusesTemplate extends StatelessWidget {
  final bool animationToggle;

  const StatusesTemplate({
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
    return ListView(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        children: List.generate(10, (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(
                vertical: 10.0, horizontal: 3.0),
            child: Stack(
              children: [
                AnimatedContainer(
                  duration: Duration(seconds: 1),
                  height: 180.0,
                  width: 90.0,
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    color: _toggleTheme(context),
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: Colors.grey, width: 1.0),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4.0,
                          offset: Offset(2.0, 2.0))
                    ],
                  ),
                ),
                Positioned(
                  top: 8.0,
                  left: 8.0,
                  child: AnimatedContainer(
                    duration: Duration(seconds: 1),
                    height: 25.0,
                    width: 25.0,
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      color: _toggleTheme(context),
                      borderRadius: BorderRadius.circular(50.0),
                      border: Border.all(color: Colors.grey, width: 1.0),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4.0,
                            offset: Offset(2.0, 2.0))
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        })
    );
  }
}
