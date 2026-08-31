import 'package:flutter/material.dart';
import '../../../constants/user_details.dart';
import '../../../../features/public/constants/public_constants.dart';


class BuildUserInfoSection extends StatefulWidget {
  Function(String) onPressed;
  BuildUserInfoSection({
    required this.onPressed,
    super.key
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
              border: UserDetails.image.isEmpty? Border.all(color: Theme.of(context).brightness == Brightness.light?
              Colors.black : Colors.white
              ) : null,
              image: DecorationImage(
                image: NetworkImage(UserDetails.image),
                fit: BoxFit.cover,
              ),
            ),
            child: UserDetails.image.isEmpty?
            Icon(Icons.person) : SizedBox(),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              UserDetails.name,
              style: TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.bold,
                fontFamily: UserDetails.name,
              ),
            ),
            DropdownButton<String>(
              value: selectedValue ?? 'public',
              items: PublicConstants.statusesElements.map((e) {
                return DropdownMenuItem<String>(
                  value: e.value,
                  child: Row(
                    children: [
                      e.icon,
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
