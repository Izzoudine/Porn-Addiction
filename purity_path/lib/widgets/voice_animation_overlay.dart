import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

/// Visual voice animation overlay that appears when AI is speaking
/// Shows animated waveforms and voice activity
class VoiceAnimationOverlay extends StatefulWidget {
  final String message;
  final VoidCallback onClose;
  final bool isAISpeaking;

  const VoiceAnimationOverlay({
    super.key,
    required this.message,
    required this.onClose,
    this.isAISpeaking = true,
  });

  @override
  State<VoiceAnimationOverlay> createState() => _VoiceAnimationOverlayState();
}

class _VoiceAnimationOverlayState extends State<VoiceAnimationOverlay>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  Timer? _waveTimer;
  final List<double> _waveBars = List.generate(20, (_) => 0.3);
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    // Wave animation controller for voice bars
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    )..repeat();

    // Pulse animation for the microphone icon
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    // Fade in animation
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();

    // Start wave animation
    _startWaveAnimation();
  }

  void _startWaveAnimation() {
    _waveTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (mounted && widget.isAISpeaking) {
        setState(() {
          for (int i = 0; i < _waveBars.length; i++) {
            // Create realistic voice pattern
            _waveBars[i] = _random.nextDouble() * 0.7 + 0.3;
          }
        });
      } else {
        setState(() {
          for (int i = 0; i < _waveBars.length; i++) {
            _waveBars[i] = 0.1; // Minimal height when not speaking
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _waveController.dispose();
    _pulseController.dispose();
    _fadeController.dispose();
    _waveTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeController,
      child: Material(
        color: Colors.black.withOpacity(0.95),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.95),
                const Color(0xFF1A237E).withOpacity(0.9),
                Colors.black.withOpacity(0.95),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Close button
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 30),
                    onPressed: widget.onClose,
                  ),
                ),

                const Spacer(),

                // Main voice visualization
                _buildVoiceVisualization(),

                const SizedBox(height: 40),

                // AI Speaking indicator
                _buildAISpeakingIndicator(),

                const SizedBox(height: 30),

                // Message text
                _buildMessageText(),

                const Spacer(),

                // Islamic reminder at bottom
                _buildIslamicReminder(),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVoiceVisualization() {
    return Container(
      height: 200,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated microphone icon with pulse
          ScaleTransition(
            scale: Tween<double>(begin: 1.0, end: 1.3).animate(
              CurvedAnimation(
                parent: _pulseController,
                curve: Curves.easeInOut,
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Colors.blue[400]!,
                    Colors.purple[400]!,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.record_voice_over,
                color: Colors.white,
                size: 50,
              ),
            ),
          ),

          const SizedBox(height: 30),

          // Animated voice wave bars
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(
              _waveBars.length,
              (index) => _buildWaveBar(index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaveBar(int index) {
    final height = _waveBars[index];
    final color = _getBarColor(index);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      margin: const EdgeInsets.symmetric(horizontal: 2),
      width: 4,
      height: 60 * height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            color,
            color.withOpacity(0.5),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 4,
          ),
        ],
      ),
    );
  }

  Color _getBarColor(int index) {
    // Create gradient effect across bars
    final normalizedIndex = index / _waveBars.length;
    return Color.lerp(
      Colors.blue[400]!,
      Colors.purple[400]!,
      normalizedIndex,
    )!;
  }

  Widget _buildAISpeakingIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Animated dots
        ...List.generate(3, (index) {
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            builder: (context, value, child) {
              final delay = index * 0.2;
              final animValue = ((value - delay) % 1.0).clamp(0.0, 1.0);
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.3 + (animValue * 0.7)),
                  ),
                ),
              );
            },
          );
        }),

        const SizedBox(width: 12),

        // "AI Speaking" text
        const Text(
          'AI INTERVENTION',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildMessageText() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Colors.orange,
            size: 40,
          ),
          const SizedBox(height: 16),
          Text(
            widget.message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIslamicReminder() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          // Islamic icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green.withOpacity(0.2),
              border: Border.all(
                color: Colors.green.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: const Text(
              '☪️',
              style: TextStyle(fontSize: 30),
            ),
          ),

          const SizedBox(height: 12),

          // Arabic text
          const Text(
            'إِنَّ اللَّهَ يَرَاكَ',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          // Translation
          Text(
            'Indeed, Allah is watching you',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
