import 'package:flutter/material.dart';
import 'package:social_app/core/themes/app_theme.dart';
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
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 10.0),
          child: Container(
            height: 50.0,
            width: 50.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50.0),
              border: widget.myImageUrl.isEmpty ? Border.all(
                  color: AppTheme.getAdaptiveColor(context)
              ) : null,
              image: DecorationImage(
                image: NetworkImage(widget.myImageUrl),
                fit: BoxFit.cover,
              ),
            ),
            child: widget.myImageUrl.isEmpty ?
            Icon(Icons.person) : SizedBox(),
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
              value: selectedValue ?? 'public',
              items: PublicConstants.statusesElements.map((e) {
                return DropdownMenuItem<String>(
                  value: e.value,
                  child: Row(
                    children: [
                      Icon(e.icon),
                      const SizedBox(width: 8.0),
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
