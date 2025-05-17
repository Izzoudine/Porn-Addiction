import 'package:flutter/material.dart';
import '../../data/services/accessibility_service.dart';

class AccessibilityPermissionScreen extends StatefulWidget {
  @override
  _AccessibilityPermissionScreenState createState() => _AccessibilityPermissionScreenState();
}

class _AccessibilityPermissionScreenState extends State<AccessibilityPermissionScreen> {
  bool _isAccessibilityEnabled = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _checkAccessibilityStatus();
  }

  Future<void> _checkAccessibilityStatus() async {
    try {
      final isEnabled = await AccessibilityService.isAccessibilityServiceEnabled();
      setState(() {
        _isAccessibilityEnabled = isEnabled;
        _errorMessage = '';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error checking accessibility: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Accessibility Permission')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _isAccessibilityEnabled
                  ? 'Accessibility Service Enabled'
                  : 'Please Enable Accessibility Service',
              style: TextStyle(fontSize: 18),
            ),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  await AccessibilityService.requestAccessibilityPermission();
                  await Future.delayed(Duration(seconds: 1));
                  await _checkAccessibilityStatus();
                } catch (e) {
                  setState(() {
                    _errorMessage = 'Error requesting accessibility: $e';
                  });
                }
              },
              child: Text('Enable Accessibility Service'),
            ),
          ],
        ),
      ),
    );
  }
}