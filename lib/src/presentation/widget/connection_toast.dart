import 'dart:async';
import 'package:flutter/material.dart';

class ConnectionToast {
  static OverlayEntry? _overlayEntry;
  static bool _isVisible = false;
  static Timer? _timer;

  static void show({
    required BuildContext context,
    required String message,
    required Color backgroundColor,
    required IconData icon,
  }) {
    // Remove existing toast if any
    dismiss();

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            transform: Matrix4.translationValues(0, _isVisible ? 0 : -100, 0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.white, size: 22),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    // Insert into overlay
    Overlay.of(context).insert(_overlayEntry!);
    _isVisible = true;

    // Auto dismiss after 3 seconds
    _timer = Timer(const Duration(seconds: 3), () {
      dismiss();
    });
  }

  static void dismiss() {
    _timer?.cancel();
    _timer = null;

    if (_isVisible && _overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      _isVisible = false;
    }
  }

  // Connection state methods
  static void showConnected(BuildContext context) {
    show(
      context: context,
      message: '🌐 Connected to internet',
      backgroundColor: const Color(0xFF10B981), // Emerald green
      icon: Icons.wifi_rounded,
    );
  }

  static void showDisconnected(BuildContext context) {
    show(
      context: context,
      message: '📵 No internet connection',
      backgroundColor: const Color(0xFFEF4444), // Red
      icon: Icons.wifi_off_rounded,
    );
  }

  static void showConnecting(BuildContext context) {
    show(
      context: context,
      message: '🔄 Connecting...',
      backgroundColor: const Color(0xFFF59E0B), // Amber
      icon: Icons.network_check_rounded,
    );
  }

  static void showAILoading(BuildContext context) {
    show(
      context: context,
      message: '🤖 AI is thinking...',
      backgroundColor: const Color(0xFF8B5CF6), // Purple
      icon: Icons.auto_awesome_rounded,
    );
  }
}