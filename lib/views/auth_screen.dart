import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../controllers/challenge_controller.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  // Animaciones
  late AnimationController _gradientController;
  late AnimationController _particleController;
  late Animation<double> _gradientAnimation;
  late Animation<double> _particleAnimation;
  final List<Particle> particles = [];
  final Random random = Random();

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
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _particleController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await context.read<ChallengeController>().signIn(
        _emailController.text,
        _passwordController.text,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al iniciar sesión: ${e.toString()}'),
            backgroundColor: Colors.red.withOpacity(0.8),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await context.read<ChallengeController>().signUp(
        _emailController.text,
        _passwordController.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Registro exitoso!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error en el registro: ${e.toString()}'),
            backgroundColor: Colors.red.withOpacity(0.8),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      await context.read<ChallengeController>().signInWithGoogle();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error con Google: ${e.toString()}'),
            backgroundColor: Colors.red.withOpacity(0.8),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Fondo animado (igual que en SplashScreen)
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

          // Contenido del formulario
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Título con estilo similar al SplashScreen
                      Text(
                        'Bienvenido a Retos Diarios',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 10,
                              color: Colors.black,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Inicia Sesión o Regístrate',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Campo de email
                      TextFormField(
                        controller: _emailController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.amber),
                          ),
                          prefixIcon: Icon(Icons.email, color: Colors.white.withOpacity(0.7)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || !value.contains('@')) {
                            return 'Email no válido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Campo de contraseña
                      TextFormField(
                        controller: _passwordController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.amber),
                          ),
                          prefixIcon: Icon(Icons.lock, color: Colors.white.withOpacity(0.7)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                          ),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.length < 6) {
                            return 'La contraseña debe tener al menos 6 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),

                      if (_isLoading)
                        const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                        )
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Botón de Iniciar Sesión
                            ElevatedButton(
                              onPressed: _signIn,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                backgroundColor: Colors.amber,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 5,
                                shadowColor: Colors.amber.withOpacity(0.5),
                              ),
                              child: Text(
                                'Iniciar Sesión',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Botón de Registrarse
                            OutlinedButton(
                              onPressed: _signUp,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                side: BorderSide(color: Colors.amber),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                'Registrarse',
                                style: TextStyle(
                                  color: Colors.amber,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                              ),
                            ),

                            // Separador
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: Colors.white.withOpacity(0.3),
                                    thickness: 1,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text(
                                    'O',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7)),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: Colors.white.withOpacity(0.3),
                                    thickness: 1,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Botón de Google
                            ElevatedButton.icon(
                              onPressed: _signInWithGoogle,
                              icon: Image.asset(
                                'assets/google_logo.png',
                                height: 24.0,
                                color: Colors.black,
                              ),
                              label: Text(
                                'Iniciar Sesión con Google',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 3,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Clase de Particle (la misma que en tu SplashScreen)
class Particle {
  final double x;
  final double y;
  final double radius;
  final double speed;
  final double alpha;
  final double angle;
  final double distance;

  Particle({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.alpha,
  })  : angle = Random().nextDouble() * 2 * pi,
        distance = Random().nextDouble() * 0.2 + 0.1;
}

// Clase de BackgroundPainter (la misma que en tu SplashScreen)
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
        HSLColor.fromAHSL(1.0, 260, 0.6, 0.6)
            .withLightness(0.5 + 0.2 * sin(gradientProgress * 2 * pi))
            .toColor(),
        HSLColor.fromAHSL(1.0, 220, 0.7, 0.6)
            .withLightness(0.5 + 0.2 * cos(gradientProgress * 2 * pi))
            .toColor(),
        HSLColor.fromAHSL(1.0, 150, 0.7, 0.4)
            .withLightness(0.4 + 0.1 * sin(gradientProgress * pi))
            .toColor(),
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    final rect = Rect.fromLTRB(0, 0, size.width, size.height);
    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);

    for (final particle in particles) {
      final x = size.width *
          (particle.x +
              sin(particleProgress * 2 * pi * particle.speed + particle.angle) *
                  particle.distance);
      final y = size.height *
          (particle.y +
              cos(particleProgress * 2 * pi * particle.speed + particle.angle) *
                  particle.distance);

      final particlePaint = Paint()
        ..color = Colors.white.withOpacity(particle.alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

      canvas.drawCircle(Offset(x, y), particle.radius, particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}