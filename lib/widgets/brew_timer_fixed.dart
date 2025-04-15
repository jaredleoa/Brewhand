import 'dart:async';
import 'package:flutter/material.dart';

class BrewTimer extends StatefulWidget {
  final int durationInSeconds;
  final VoidCallback onComplete;
  final Color backgroundColor;
  final Color progressColor;
  final Color textColor;

  const BrewTimer({
    super.key,
    required this.durationInSeconds,
    required this.onComplete,
    required this.backgroundColor,
    required this.progressColor,
    required this.textColor,
  });

  @override
  State<BrewTimer> createState() => _BrewTimerState();
}

class _BrewTimerState extends State<BrewTimer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _isRunning = false;
  bool _isComplete = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.durationInSeconds;
    
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.durationInSeconds),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isComplete = true;
          _isRunning = false;
        });
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    setState(() {
      _isRunning = true;
    });
    
    _controller.forward();
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _timer?.cancel();
          _isRunning = false;
          _isComplete = true;
        }
      });
    });
  }

  void pauseTimer() {
    if (_isRunning) {
      _controller.stop();
      _timer?.cancel();
      setState(() {
        _isRunning = false;
      });
    }
  }

  void resetTimer() {
    _controller.reset();
    setState(() {
      _remainingSeconds = widget.durationInSeconds;
      _isRunning = false;
      _isComplete = false;
    });
    _timer?.cancel();
  }

  String get timeString {
    final minutes = (_remainingSeconds / 60).floor();
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Brewing in progress...',
          style: TextStyle(
            color: widget.textColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: 1 - (_remainingSeconds / widget.durationInSeconds),
          backgroundColor: widget.backgroundColor,
          valueColor: AlwaysStoppedAnimation<Color>(widget.progressColor),
          minHeight: 8,
        ),
        const SizedBox(height: 16),
        Text(
          timeString,
          style: TextStyle(
            color: widget.textColor,
            fontSize: 36,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_isRunning && !_isComplete)
              ElevatedButton(
                onPressed: startTimer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.progressColor,
                  foregroundColor: widget.backgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text('Start'),
              ),
            if (_isRunning)
              ElevatedButton(
                onPressed: pauseTimer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[700],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text('Pause'),
              ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: resetTimer,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text('Reset'),
            ),
          ],
        ),
      ],
    );
  }
}
