import 'package:flutter/material.dart';


class PublicConstants {
  static const Map<String, IconData> postStatuses = {
    'only_me': Icons.lock,
    'public': Icons.public,
    'friends': Icons.person,
  };

  static const List<StatusElement> statusesElements = [
    StatusElement(value: 'only_me', icon: Icons.lock, text: 'Only me'),
    StatusElement(value: 'public', icon: Icons.public, text: 'Public'),
    StatusElement(value: 'friends', icon: Icons.person, text: 'Friends'),
  ];

  static IconData getStatus(String status){
    return postStatuses[status] ?? Icons.public;
  }
}

class StatusElement {/
  final String value;
  final IconData icon;
  final String text;

  const StatusElement({
    required this.value,
    required this.icon,
    required this.text,
  });
}