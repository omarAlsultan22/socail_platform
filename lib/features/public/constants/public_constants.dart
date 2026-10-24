import 'package:flutter/material.dart';
import '../data/models/status_element.dart';


class PublicConstants {
  static const String onlyMe  = 'only_me';
  static const String public  = 'public';
  static const String friends = 'friends';

  static const List<StatusElement> statusesElements = [
    StatusElement(value: onlyMe, icon: Icons.lock, text: 'Only me'),
    StatusElement(value: public, icon: Icons.public, text: 'Public'),
    StatusElement(value: friends, icon: Icons.person, text: 'Friends'),
  ];

  static final Map<String, IconData> postStatuses = {
    for (final e in statusesElements) e.value: e.icon,
  };

  static IconData getStatus(String? status){
    return postStatuses[status] ?? Icons.public;
  }
}

