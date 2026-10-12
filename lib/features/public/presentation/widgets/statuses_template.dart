import 'package:flutter/material.dart';


class StatusesTemplate extends StatelessWidget {
  final bool animationToggle;

  const StatusesTemplate({
    super.key,
    required this.animationToggle
  });

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
                    color: Theme
                        .of(context)
                        .brightness == Brightness.light ?
                    animationToggle ? Colors.transparent : Colors.black12 :
                    animationToggle ? Colors.transparent : Colors.black87,
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
                      color: Theme
                          .of(context)
                          .brightness == Brightness.light ?
                      animationToggle ? Colors.transparent : Colors.black12 :
                      animationToggle ? Colors.transparent : Colors.black87,
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
