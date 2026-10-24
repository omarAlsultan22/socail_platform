import 'package:flutter/material.dart';
import '../../data/models/button_model.dart';
import 'package:social_app/core/constants/app_colors.dart';
import 'package:social_app/core/constants/app_borders.dart';
import 'package:social_app/core/constants/app_paddings.dart';


class BuildButtonsList extends StatefulWidget {
  final List<ButtonModel> items;
  final Function(int)? onTap;

  const BuildButtonsList({
    required this.items,
    this.onTap,
    super.key,
  });

  @override
  State<BuildButtonsList> createState() => _BuildButtonsListState();
}

class _BuildButtonsListState extends State<BuildButtonsList> {
  late int _activeButtonId;

  @override
  void initState() {
    super.initState();
    _activeButtonId = 0;
  }

  void changeIndex(int id) {
    _activeButtonId = id;
    widget.onTap!(id);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.items.length,
        itemBuilder: (context, index) {
          final button = widget.items[index];
          final isActive = button.id == _activeButtonId;

          return _buttonItem(
            button: button,
            isActive: isActive,
            onTap: () {
              changeIndex(button.id);
            },
          );
        },
      ),
    );
  }

  Widget _buttonItem({
    required bool isActive,
    required ButtonModel button,
    required VoidCallback onTap
  }) {
    return Padding(
      padding: AppPaddings.all5,
      child: Container(
        decoration: BoxDecoration(
          color: isActive ? AppColors.black : AppColors.white,
          borderRadius: AppBorders.borderRadius_30,
          border: Border.all(color: AppColors.black),
        ),
        child: TextButton(
          onPressed: onTap,
          child: Center(
            child: Text(
              button.label,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w700,
                color: isActive ? AppColors.white : AppColors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}