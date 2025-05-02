import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:visionapp/presentation/auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();

    // Scale animation for the logo
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    // Fade animation for the text
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    // Pulse animation for the vision icon
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    // Trigger animation sequence
    _startAnimations();
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 500)).then((_) {
      _scaleController.forward();
      _fadeController.forward();

      // Navigate to HomePage after 3 seconds
      Future.delayed(const Duration(seconds: 3)).then((_) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      });
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated logo with scale effect
            ScaleTransition(
              scale: _scaleAnimation,
              child: FadeIn(
                duration: const Duration(milliseconds: 1000),
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + (_pulseController.value * 0.05),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.blue.shade100,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.visibility,
                          size: 80,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 40),

            // App name with fade animation
            FadeTransition(
              opacity: _fadeAnimation,
              child: Text(
                "Vision App",
                style: GoogleFonts.poppins(
                  color: Colors.blue.shade900,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Tagline with delayed fade animation
            FadeIn(
              delay: const Duration(milliseconds: 1000),
              child: Text(
                "Streamline Your Business Operations",
                style: GoogleFonts.poppins(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(height: 80),

            // Loading indicator
            FadeIn(
              delay: const Duration(milliseconds: 1500),
              child: SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  color: Colors.blue.shade800,
                  strokeWidth: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
