import 'dart:async';
import 'package:acoms_app/remote.dart';
import 'package:acoms_app/widgets/fictional.dart';
import 'package:flutter/material.dart';

class StatusIndicator extends StatefulWidget {
  const StatusIndicator({super.key});

  @override
  State<StatusIndicator> createState() => _StatusIndicatorState();
}

class _StatusIndicatorState extends State<StatusIndicator> {
  bool _isOnline = false;
  Timer? _heartbeatTimer;
  final Remote _remote = Remote();

  @override
  void initState() {
    super.initState();
    _checkHeartbeat();
    _startHeartbeatTimer();
  }

  @override
  void dispose() {
    _heartbeatTimer?.cancel();
    super.dispose();
  }

  void _startHeartbeatTimer() {
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _checkHeartbeat();
    });
  }

  Future<void> _checkHeartbeat() async {
    final isOnline = await _remote.heartbeat();
    if (mounted) {
      setState(() {
        _isOnline = isOnline;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: _isOnline ? FiColors.green1 : FiColors.red,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(_isOnline ? "Online" : "Offline"),
      ],
    );
  }
}
