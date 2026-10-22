import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final Widget nextScreen;

  const SplashScreen({
    super.key,
    required this.nextScreen,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  Timer? _timer;

  static const Color background = Color(0xFF070B18);
  static const Color cyan = Color(0xFF36E4FF);
  static const Color purple = Color(0xFF8B5CF6);

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.65,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _controller.forward();

    _timer = Timer(const Duration(seconds: 7), () {
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => widget.nextScreen,
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 350),
        ),
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SizedBox.expand(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background glow kiri atas
            Positioned(
              top: -100,
              left: -100,
              child: IgnorePointer(
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: cyan.withValues(alpha: 0.08),
                  ),
                ),
              ),
            ),

            // Background glow kanan bawah
            Positioned(
              bottom: -100,
              right: -100,
              child: IgnorePointer(
                child: Container(
                  width: 320,
                  height: 320,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: purple.withValues(alpha: 0.10),
                  ),
                ),
              ),
            ),

            // Konten utama
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: constraints.maxWidth,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Logo animasi
                            FadeTransition(
                              opacity: _fadeAnimation,
                              child: ScaleTransition(
                                scale: _scaleAnimation,
                                child: Container(
                                  width: 124,
                                  height: 124,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(32),
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFF17334A),
                                        Color(0xFF11172B),
                                      ],
                                    ),
                                    border: Border.all(
                                      color: cyan.withValues(alpha: 0.8),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: cyan.withValues(alpha: 0.20),
                                        blurRadius: 35,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.terminal_rounded,
                                    size: 70,
                                    color: cyan,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 28),

                            FadeTransition(
                              opacity: _fadeAnimation,
                              child: const Text(
                                'CODEMON',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 34,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 5,
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            const Text(
                              'LEVEL UP YOUR CODE',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: cyan,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 3,
                              ),
                            ),

                            const SizedBox(height: 24),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.04),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.10),
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.bolt_rounded,
                                    color: Color(0xFFFFD166),
                                    size: 17,
                                  ),
                                  SizedBox(width: 7),
                                  Flexible(
                                    child: Text(
                                      'YOUR CODING ADVENTURE STARTS HERE',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Color(0xFFB8C5D9),
                                        fontSize: 9,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 55),

                            // Loading bar
                            SizedBox(
                              width: 170,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: const LinearProgressIndicator(
                                  minHeight: 4,
                                  backgroundColor: Color(0xFF1C2639),
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(cyan),
                                ),
                              ),
                            ),

                            const SizedBox(height: 14),

                            const Text(
                              'INITIALIZING GAME...',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF718096),
                                fontSize: 10,
                                letterSpacing: 2,
                              ),
                            ),

                            const SizedBox(height: 28),

                            const Text(
                              'HTML  •  CSS  •  JAVASCRIPT',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF4F6078),
                                fontSize: 10,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
