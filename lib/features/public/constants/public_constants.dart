import 'package:flutter/material.dart';
import '../data/models/status_element.dart';


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

