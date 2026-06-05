import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _leafController;
  late AnimationController _pulseController;

  late Animation<double> _logoScale;
  late Animation<double> _logoRotation;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;
  late Animation<double> _leafRotation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Logo animation controller
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Text animation controller
    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Leaf rotation controller
    _leafController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Pulse controller
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Logo scale animation with bounce
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.elasticOut,
      ),
    );

    // Logo rotation animation
    _logoRotation = Tween<double>(begin: -0.5, end: 0.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.easeOutBack,
      ),
    );

    // Text opacity animation
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeIn,
      ),
    );

    // Text slide animation
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Leaf rotation
    _leafRotation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(
        parent: _leafController,
        curve: Curves.linear,
      ),
    );

    // Pulse animation
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 800));
    _textController.forward();
    _leafController.repeat();

    await Future.delayed(const Duration(milliseconds: 500));
    _pulseController.repeat(reverse: true);

    // Navigate to login after animations
    await Future.delayed(const Duration(milliseconds: 2000));
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _leafController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF1A3D1A),
                    const Color(0xFF0D2818),
                    const Color(0xFF051A0D),
                  ]
                : [
                    const Color(0xFF4CAF50),
                    const Color(0xFF2E7D32),
                    const Color(0xFF1B5E20),
                  ],
          ),
        ),
        child: Stack(
          children: [
            // Animated background leaves
            ...List.generate(6, (index) => _buildFloatingLeaf(index)),

            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated logo
                  AnimatedBuilder(
                    animation:
                        Listenable.merge([_logoController, _pulseController]),
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _logoScale.value * _pulseAnimation.value,
                        child: Transform.rotate(
                          angle: _logoRotation.value,
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFE8F5E9),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                          BoxShadow(
                            color: primaryColor.withOpacity(0.5),
                            blurRadius: 50,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: Center(
                        child: AnimatedBuilder(
                          animation: _leafController,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: math.sin(_leafRotation.value) * 0.05,
                              child: child,
                            );
                          },
                          child: CustomPaint(
                            size: const Size(100, 100),
                            painter: _PlantIconPainter(),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Animated text
                  SlideTransition(
                    position: _textSlide,
                    child: FadeTransition(
                      opacity: _textOpacity,
                      child: Column(
                        children: [
                          // SICA title with letter animation
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildAnimatedLetter('S', 0),
                              _buildAnimatedLetter('I', 1),
                              _buildAnimatedLetter('C', 2),
                              _buildAnimatedLetter('A', 3),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Sistema Inteligente de \nCultivo Autônomo',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w300,
                              letterSpacing: 1.2,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 60),

                  // Loading indicator
                  FadeTransition(
                    opacity: _textOpacity,
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedLetter(String letter, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 800 + (index * 150)),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Text(
            letter,
            style: TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(2, 2),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingLeaf(int index) {
    final random = math.Random(index);
    final startX = random.nextDouble() * 400 - 50;
    final startY = random.nextDouble() * 800;
    final size = 20.0 + random.nextDouble() * 30;
    final duration = 3000 + random.nextInt(2000);
    final delay = random.nextInt(2000);

    return Positioned(
      left: startX,
      top: startY,
      child: _FloatingLeaf(
        size: size,
        duration: duration,
        delay: delay,
      ),
    );
  }
}

class _FloatingLeaf extends StatefulWidget {
  final double size;
  final int duration;
  final int delay;

  const _FloatingLeaf({
    required this.size,
    required this.duration,
    required this.delay,
  });

  @override
  State<_FloatingLeaf> createState() => _FloatingLeafState();
}

class _FloatingLeafState extends State<_FloatingLeaf>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: widget.duration),
      vsync: this,
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.repeat();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final value = _controller.value;
        return Transform.translate(
          offset: Offset(
            math.sin(value * 2 * math.pi) * 30,
            math.cos(value * 2 * math.pi) * 20,
          ),
          child: Transform.rotate(
            angle: math.sin(value * 2 * math.pi) * 0.5,
            child: Opacity(
              opacity: 0.3 + math.sin(value * math.pi) * 0.2,
              child: child,
            ),
          ),
        );
      },
      child: Icon(
        Icons.eco,
        size: widget.size,
        color: Colors.white.withOpacity(0.4),
      ),
    );
  }
}

// Custom painter para desenhar o ícone da planta (mesmo do app icon)
class _PlantIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double scale = size.width / 512;

    // Folha principal (gota verde)
    final leafPaint = Paint()
      ..color = const Color(0xFF43A047)
      ..style = PaintingStyle.fill;

    final leafPath = Path();
    leafPath.moveTo(256 * scale, 50 * scale);
    leafPath.cubicTo(
      256 * scale,
      50 * scale,
      130 * scale,
      160 * scale,
      130 * scale,
      310 * scale,
    );
    leafPath.cubicTo(
      130 * scale,
      400 * scale,
      190 * scale,
      462 * scale,
      256 * scale,
      462 * scale,
    );
    leafPath.cubicTo(
      322 * scale,
      462 * scale,
      382 * scale,
      400 * scale,
      382 * scale,
      310 * scale,
    );
    leafPath.cubicTo(
      382 * scale,
      160 * scale,
      256 * scale,
      50 * scale,
      256 * scale,
      50 * scale,
    );
    leafPath.close();
    canvas.drawPath(leafPath, leafPaint);

    // Veias da planta
    final veinPaint = Paint()
      ..color = const Color(0xFFB9F6CA)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16 * scale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Caule central
    canvas.drawLine(
      Offset(256 * scale, 462 * scale),
      Offset(256 * scale, 200 * scale),
      veinPaint,
    );

    // Ponto no topo
    final dotPaint = Paint()
      ..color = const Color(0xFFB9F6CA)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(256 * scale, 200 * scale), 12 * scale, dotPaint);

    // Ramo esquerdo inferior
    final leftBranch1 = Path();
    leftBranch1.moveTo(256 * scale, 360 * scale);
    leftBranch1.lineTo(190 * scale, 360 * scale);
    leftBranch1.lineTo(160 * scale, 330 * scale);
    canvas.drawPath(leftBranch1, veinPaint);
    canvas.drawCircle(Offset(160 * scale, 330 * scale), 12 * scale, dotPaint);

    // Ramo esquerdo superior
    canvas.drawLine(
      Offset(256 * scale, 280 * scale),
      Offset(210 * scale, 280 * scale),
      veinPaint,
    );
    canvas.drawCircle(Offset(210 * scale, 280 * scale), 12 * scale, dotPaint);

    // Ramo direito inferior
    final rightBranch1 = Path();
    rightBranch1.moveTo(256 * scale, 360 * scale);
    rightBranch1.lineTo(322 * scale, 360 * scale);
    rightBranch1.lineTo(352 * scale, 330 * scale);
    canvas.drawPath(rightBranch1, veinPaint);
    canvas.drawCircle(Offset(352 * scale, 330 * scale), 12 * scale, dotPaint);

    // Ramo direito superior
    canvas.drawLine(
      Offset(256 * scale, 280 * scale),
      Offset(302 * scale, 280 * scale),
      veinPaint,
    );
    canvas.drawCircle(Offset(302 * scale, 280 * scale), 12 * scale, dotPaint);

    // Contorno da folha
    final outlinePaint = Paint()
      ..color = const Color(0xFF2E7D32)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12 * scale
      ..strokeCap = StrokeCap.round;

    final outlinePath = Path();
    outlinePath.moveTo(130 * scale, 310 * scale);
    outlinePath.cubicTo(
      130 * scale,
      160 * scale,
      256 * scale,
      50 * scale,
      256 * scale,
      50 * scale,
    );
    outlinePath.cubicTo(
      256 * scale,
      50 * scale,
      382 * scale,
      160 * scale,
      382 * scale,
      310 * scale,
    );
    canvas.drawPath(outlinePath, outlinePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
