// splash_screen.dart
import 'package:flutter/material.dart';
import 'package:masoko_tips/screens/home/home_screen.dart';
import 'package:masoko_tips/widgets/sponsor_logo.dart';
import '../../l10n/app_localizations.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _sponsorController;
  late Animation<double> _sponsorAnimation;

  // ✅ Optional: Add scale animation for sponsor (uncomment to use)
  // late Animation<double> _sponsorScaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimationSequence();
  }

  void _setupAnimations() {
    // Sponsor animation controller
    _sponsorController = AnimationController(
      duration: const Duration(milliseconds: 400), // fade in duration
      vsync: this,
    );

    // Sponsor fade in animation
    _sponsorAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _sponsorController,
      curve: Curves.easeIn,
    ));
  }

  void _startAnimationSequence() async {
    // Show sponsors after 2 seconds (logo + text display time)
    await Future.delayed(const Duration(milliseconds: 2000));
    _sponsorController.forward();
    debugPrint('SplashScreen: Showing sponsor logos');

    // Display sponsors for 2 more seconds (total 4 seconds)
    await Future.delayed(const Duration(milliseconds: 2000));
    debugPrint('SplashScreen: Sponsor display complete');

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
    _sponsorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Remove background color
      body: AnimatedBuilder(
        animation: _sponsorController,
        builder: (context, child) {
          return Container(
            // Remove gradient decoration to see logo clearly
            color: Colors.transparent,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF1C592B),
                    Color(0xFF2D7A3D),
                  ],
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // Main Logo Section with text
                    Expanded(
                      flex: 3,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Logo
                            Image.asset(
                              'assets/images/logo-moble.webp',
                              height: 120,
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.high,
                            ),

                            const SizedBox(height: 8),
                            // App name
                            Text(
                              AppLocalizations.of(context)!.appName,
                              style: const TextStyle(
                                fontSize: 28,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Subtitle
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                AppLocalizations.of(context)!.appSubtitle,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 0.5,
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

                    const SizedBox(height: 8),
                    // Imedhaminiwa / Sponsored text
                    const Text(
                      'Sponsored',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.0,
                      ),
                    ),

                    // Sponsor Section
                    Expanded(
                      flex: 2,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 20,
                        ),
                        child: FadeTransition(
                          opacity: _sponsorAnimation,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Sponsor section
                              const Text(
                                'By',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(height: 8),
                              // COSTECH full name
                              Text(
                                AppLocalizations.of(context)!.costech,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              // Enlarged sponsor logo
                              Container(
                                height: 90,
                                width: 220,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: SponsorLogo(
                                    imagePath:
                                        'assets/images/costech_logo.webp',
                                    fallbackText:
                                        AppLocalizations.of(context)!.costech,
                                    height: 70,
                                  ),
                                ),
                              ),
                            ],
                          ),
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
