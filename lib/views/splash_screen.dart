import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'dart:math';
import 'package:simple_animations/simple_animations.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.onInitializationComplete});

  final VoidCallback onInitializationComplete;

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _gradientController;
  late AnimationController _particleController;
  late AnimationController _progressController;
  late AnimationController _textController;
  late AnimationController _iconController;
  late Animation<double> _gradientAnimation;
  late Animation<double> _particleAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _textAnimation;
  late Animation<double> _iconAnimation;

  final List<Particle> particles = [];
  final Random random = Random();
  bool _loadingComplete = false;

  @override
  void initState() {
    super.initState();

    // Inicializar partículas
    for (int i = 0; i < 50; i++) {
      particles.add(Particle(
        x: random.nextDouble(),
        y: random.nextDouble(),
        radius: random.nextDouble() * 3 + 1,
        speed: random.nextDouble() * 0.5 + 0.1,
        alpha: random.nextDouble() * 0.5 + 0.1,
      ));
    }

    // Configurar controladores de animación
    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    // Configurar animaciones
    _gradientAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _gradientController,
        curve: Curves.easeInOut,
      ),
    );

    _particleAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _particleController,
        curve: Curves.linear,
      ),
    );

    _progressAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeInOut,
      ),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _loadingComplete = true;
          });
          _textController.forward().then((_) {
            widget.onInitializationComplete();
          });
        }
      });

    _textAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeOut,
      ),
    );

    _iconAnimation = Tween(begin: 0.0, end: 0.2).animate(
      CurvedAnimation(
        parent: _iconController,
        curve: Curves.easeInOut,
      ),
    );

    // Iniciar animación de progreso
    Future.delayed(const Duration(milliseconds: 500), () {
      _progressController.forward();
    });
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _particleController.dispose();
    _progressController.dispose();
    _textController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Fondo animado
          AnimatedBuilder(
            animation: Listenable.merge([_gradientController, _particleController]),
            builder: (context, child) {
              return CustomPaint(
                painter: BackgroundPainter(
                  gradientProgress: _gradientAnimation.value,
                  particleProgress: _particleAnimation.value,
                  particles: particles,
                ),
                size: Size.infinite,
              );
            },
          ),

          // Contenido central
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo animado
                AnimatedBuilder(
                  animation: _iconController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, -20 * _iconAnimation.value),
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.4 * _iconAnimation.value * 5),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            Icons.emoji_events,
                            size: 60,
                            color: Colors.amber.withOpacity(1 - _iconAnimation.value * 2),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 40),

                // Texto animado
                AnimatedBuilder(
                  animation: _textController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _textAnimation.value,
                      child: Transform.translate(
                        offset: Offset(0, 20 - 20 * _textAnimation.value),
                        child: Text(
                          _loadingComplete ? '¡Listo!' : 'Cargando...',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                blurRadius: 10,
                                color: Colors.black,
                                offset: Offset(2, 2),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 40),

                // Barra de progreso
                SizedBox(
                  width: 250,
                  child: AnimatedBuilder(
                    animation: _progressController,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: ProgressBarPainter(
                          progress: _progressAnimation.value,
                          isComplete: _loadingComplete,
                        ),
                        size: const Size(250, 20),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // Porcentaje de carga
                AnimatedBuilder(
                  animation: _progressController,
                  builder: (context, child) {
                    return Text(
                      '${(_progressAnimation.value * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Efecto de confeti al completar
          if (_loadingComplete)
            AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                return CustomPaint(
                  painter: ConfettiPainter(
                    progress: _particleAnimation.value,
                  ),
                  size: Size.infinite,
                );
              },
            ),
        ],
      ),
    );
  }
}

class Particle {
  double x;
  double y;
  double radius;
  double speed;
  double alpha;
  double angle;
  double distance;

  Particle({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.alpha,
  })  : angle = Random().nextDouble() * 2 * pi,
        distance = Random().nextDouble() * 0.2 + 0.1;
}

class BackgroundPainter extends CustomPainter {
  final double gradientProgress;
  final double particleProgress;
  final List<Particle> particles;

  BackgroundPainter({
    required this.gradientProgress,
    required this.particleProgress,
    required this.particles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        HSLColor.fromAHSL(1.0, 260, 0.6, 0.6).withLightness(0.5 + 0.2 * sin(gradientProgress * 2 * pi)).toColor(),
        HSLColor.fromAHSL(1.0, 220, 0.7, 0.6).withLightness(0.5 + 0.2 * cos(gradientProgress * 2 * pi)).toColor(),
        HSLColor.fromAHSL(1.0, 150, 0.7, 0.4).withLightness(0.4 + 0.1 * sin(gradientProgress * pi)).toColor(),
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    final rect = Rect.fromLTRB(0, 0, size.width, size.height);
    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);

    for (final particle in particles) {
      final x = size.width * (particle.x + sin(particleProgress * 2 * pi * particle.speed + particle.angle) * particle.distance);
      final y = size.height * (particle.y + cos(particleProgress * 2 * pi * particle.speed + particle.angle) * particle.distance);

      final particlePaint = Paint()
        ..color = Colors.white.withOpacity(particle.alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

      canvas.drawCircle(Offset(x, y), particle.radius, particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ProgressBarPainter extends CustomPainter {
  final double progress;
  final bool isComplete;

  ProgressBarPainter({
    required this.progress,
    required this.isComplete,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final backgroundRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(10),
    );
    canvas.drawRRect(backgroundRect, backgroundPaint);

    final progressWidth = size.width * progress;
    final progressRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, progressWidth, size.height),
      const Radius.circular(10),
    );

    final gradient = LinearGradient(
      colors: [
        Colors.orangeAccent,
        isComplete ? Colors.greenAccent : Colors.amber,
      ],
    );

    final progressPaint = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, progressWidth, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawRRect(progressRect, progressPaint);

    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawRRect(backgroundRect, borderPaint);

    if (isComplete) {
      final glowPaint = Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

      canvas.drawRRect(progressRect, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ConfettiPainter extends CustomPainter {
  final double progress;

  ConfettiPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(progress.hashCode);
    final confettiCount = 50;

    for (int i = 0; i < confettiCount; i++) {
      final x = size.width * random.nextDouble();
      final y = size.height * (1 - (progress * 1.5 % 1.0)) - 100;
      final angle = progress * 2 * pi + random.nextDouble() * pi;
      final sizeConfetti = random.nextDouble() * 8 + 4;
      final color = Color.lerp(
        Colors.orangeAccent,
        Colors.greenAccent,
        random.nextDouble(),
      )!.withOpacity(0.7);

      final paint = Paint()..color = color;
      
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle);
      
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: sizeConfetti,
          height: sizeConfetti / 2),
        paint,
      );
      
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}