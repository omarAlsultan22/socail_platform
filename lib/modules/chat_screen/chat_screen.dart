import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  Future<void> openChat() async {
    const String androidUrl = 'fb-messenger://';
    const String iosUrl = 'fb-messenger://';
    const String androidPackage = ''; //'com.example.test_app';
    const String iosBundleId = 'com.example.test_app';
    const String androidFallback =
        'https://play.google.com/store/apps/details?id=$androidPackage';
    const String iosFallback =
        'https://apps.apple.com/us/app/messenger/id454638411';

    try {
      if (Platform.isAndroid) {
        await launchUrl(
          Uri.parse(androidUrl),
          mode: LaunchMode.externalApplication,
        );
      } else if (Platform.isIOS) {
        await launchUrl(
          Uri.parse(iosUrl),
          mode: LaunchMode.externalApplication,
        );
      }
      else if (kIsWeb) {
        await launchUrl(Uri.parse(androidFallback));
      }
    } catch (e) {
      if (Platform.isAndroid) {
        await launchUrl(
          Uri.parse(androidFallback),
          mode: LaunchMode.externalApplication,
        );
      } else if (Platform.isIOS) {
        await launchUrl(
          Uri.parse(iosFallback),
          mode: LaunchMode.externalApplication,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Icon(CupertinoIcons.chat_bubble_2_fill, size: 30.0),
          MaterialButton(
            onPressed: () => openChat(),
            child: Text('Open Chat'),
          )
        ],
      ),
    );
  }
}
