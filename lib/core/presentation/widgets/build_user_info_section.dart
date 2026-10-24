import 'package:flutter/material.dart';
import 'package:social_app/core/themes/app_theme.dart';
import 'package:social_app/core/constants/app_spaces.dart';
import 'package:social_app/core/constants/app_borders.dart';
import 'package:social_app/core/constants/app_paddings.dart';
import '../../../features/public/constants/public_constants.dart';


class BuildUserInfoSection extends StatefulWidget {
  final String myName;
  final String myImageUrl;
  final Function(String) onPressed;
  const BuildUserInfoSection({
    super.key,
    required this.myName,
    required this.onPressed,
    required this.myImageUrl
  });

  @override
  State<BuildUserInfoSection> createState() => _BuildUserInfoSectionState();
}

class _BuildUserInfoSectionState extends State<BuildUserInfoSection> {
  String? selectedValue;

  @override
  Widget build(BuildContext context) {
    final hasImage = widget.myImageUrl.isNotEmpty;
    return Row(
      children: [
        Padding(
          padding: AppPaddings.onlyRight10,
          child: Container(
            height: 50.0,
            width: 50.0,
            decoration: BoxDecoration(
              borderRadius: AppBorders.borderRadius_50,
              border: hasImage ? null : Border.all(
                  color: AppTheme.getAdaptiveColor(context)
              ),
              image: DecorationImage(
                image: NetworkImage(widget.myImageUrl),
                fit: BoxFit.cover,
              ),
            ),
            child: hasImage ?
            SizedBox.shrink() : Icon(Icons.person),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.myName,
              style: TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.bold,
                fontFamily: widget.myName,
              ),
            ),
            DropdownButton<String>(
              value: selectedValue ?? PublicConstants.public,
              items: PublicConstants.statusesElements.map((e) {
                return DropdownMenuItem<String>(
                  value: e.value,
                  child: Row(
                    children: [
                      Icon(e.icon),
                      AppSpaces.horizontal_8,
                      Text(e.text),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  widget.onPressed(value);
                  setState(() {
                    selectedValue = value;
                  });
                  widget.onPressed(selectedValue!);
                }
              },
              hint: const Text('Select Visibility'),
            ),
          ],
        ),
      ],
    );
  }
}