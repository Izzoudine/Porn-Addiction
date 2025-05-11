import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionItem {
  final Permission? permission;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  PermissionStatus? status;
  final bool isAccessibility;
  bool isEnabled;

  PermissionItem({
    this.permission,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.status,
    this.isAccessibility = false,
    this.isEnabled = false,
  });
}
