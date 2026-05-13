import 'package:flutter/material.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';

class ScreenSecurityHelper extends StatefulWidget {
  final Widget child;
  const ScreenSecurityHelper({super.key, required this.child});

  @override
  State<ScreenSecurityHelper> createState() => _ScreenSecurityHelperState();
}

class _ScreenSecurityHelperState extends State<ScreenSecurityHelper> {
  @override
  void initState() {
    super.initState();
    _enableSecureMode();
  }

  Future<void> _enableSecureMode() async {
    await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
  }

  Future<void> _disableSecureMode() async {
    await FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
  }

  @override
  void dispose() {
    _disableSecureMode();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
