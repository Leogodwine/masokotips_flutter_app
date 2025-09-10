import 'package:flutter/material.dart';
import 'package:masoko_tips/screens/home/home_screen.dart';
import 'package:masoko_tips/widgets/sponsor_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _sponsorController;
  late Animation<double> _logoAnimation;
  late Animation<double> _sponsorAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimationSequence();
  }

  void _setupAnimations() {
    // Logo animation controller
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Sponsor animation controller
    _sponsorController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Logo scale and fade animation
    _logoAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    // Sponsor fade in animation
    _sponsorAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _sponsorController,
      curve: Curves.easeInOut,
    ));

    // Overall fade animation for smooth transition
    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.7, 1.0, curve: Curves.easeInOut),
    ));
  }

  void _startAnimationSequence() async {
    // Start logo animation
    _logoController.forward();
    debugPrint('SplashScreen: Started logo animation');
    
    // Wait 2 seconds for first logo to be visible
    await Future.delayed(const Duration(milliseconds: 2000));
    debugPrint('SplashScreen: 2 seconds passed, starting sponsor animation');
    
    // Start sponsor animation after 2 seconds
    _sponsorController.forward();
    debugPrint('SplashScreen: Started sponsor animation');
    
    // Wait additional 3 seconds for sponsor animation (total 5 seconds)
    await Future.delayed(const Duration(milliseconds: 3000));
    debugPrint('SplashScreen: 5 seconds total, navigating to home');
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    if (!mounted) return;

    try {
      debugPrint('SplashScreen: Attempting to navigate to HomeScreen');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
      debugPrint('SplashScreen: Successfully navigated to HomeScreen');
    } catch (e) {
      debugPrint('SplashScreen: Navigation error: $e');
      if (mounted) {
        debugPrint('SplashScreen: Attempting fallback navigation');
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _sponsorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C592B), // Dark green background
      body: AnimatedBuilder(
        animation: Listenable.merge([_logoController, _sponsorController]),
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF1C592B), // Dark green
                    Color(0xFF2D7A3D), // Slightly lighter green
                  ],
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // Top spacer
                    const Spacer(flex: 1),
                    
                    // Main logo section (Instagram-style center) - More space
                    Expanded(
                      flex: 4,
                      child: Center(
                        child: ScaleTransition(
                          scale: _logoAnimation,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Main logo with subtle shadow
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Image.asset(
                                  'assets/images/logo.png',
                                  height: 160, // Increased from 140
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(height: 32), // Increased spacing
                              
                              // App name with elegant typography
                              const Text(
                                'maSOKOtips',
                                style: TextStyle(
                                  fontSize: 36, // Increased from 32
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 12), // Increased spacing
                              
                              // Tagline with better wrapping
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Text(
                                  'Tanzania\'s Premier Agricultural Marketplace',
                                  style: const TextStyle(
                                    fontSize: 16, // Increased from 14
                                    color: Colors.white70,
                                    letterSpacing: 0.5,
                                    height: 1.3, // Better line height
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    // Sponsor section (Instagram-style bottom)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 40,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: FadeTransition(
                        opacity: _sponsorAnimation,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Subtle "Powered by" text
                            const Text(
                              'Powered by',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 24),
                            
                            // Sponsor logos in a row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // COSTECH logo
                                const SponsorLogo(
                                  imagePath: 'assets/images/costech_logo.png',
                                  fallbackText: 'COSTECH',
                                ),
                                
                                // Add more sponsor logos here if you have them
                                // const SizedBox(width: 16),
                                // const SponsorLogo(
                                //   imagePath: 'assets/images/other_sponsor_logo.png',
                                //   fallbackText: 'SPONSOR',
                                // ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
