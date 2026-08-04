import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restro_hub/core/providers/preferences_provider.dart';
import 'package:restro_hub/features/auth/presentation/providers/auth_provider.dart';
import 'package:restro_hub/infrastructure/sync/models/sync_status.dart';
import 'package:restro_hub/infrastructure/sync/supabase_sync_manager.dart';
import 'package:restro_hub/infrastructure/sync/sync_monitor_provider.dart';
import 'package:restro_hub/screens/permission_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _iconController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;

  final PageController _pageController = PageController();
  int _currentPage = 0;

  bool _showLoader = true;
  bool _imagesLoaded = false;
  ImageProvider? _backgroundProvider;
  late final List<ImageProvider?> _preloadedImages;

  // Theme-aware colors (will be initialized in build)
  late Color primaryColor;
  late Color surfaceColor;
  late Color onSurfaceColor;

  // Feature slides data with web image URLs
  final List<Map<String, String>> _slides = [
    {
      'image': 'assets/food1.webp',
      'title': 'Delicious Food',
      'description':
          'Explore a wide variety of cuisines from local restaurants',
    },
    {
      'image': 'assets/food2.webp',
      'title': 'Fast Delivery',
      'description':
          'Get your favorite meals delivered hot and fresh to your door',
    },
    {
      'image': 'assets/food3.webp',
      'title': 'Easy Ordering',
      'description':
          'Browse menus, customize orders, and track deliveries in real-time',
    },
    {
      'image': 'assets/food4.webp',
      'title': 'Special Offers',
      'description':
          'Enjoy exclusive deals and discounts on your favorite restaurants',
    },
  ];

  @override
  void initState() {
    super.initState();

    // Ensure native splash remains until our first frame is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        FlutterNativeSplash.remove();
      }
    });

    _iconController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    unawaited(_pulseController.repeat(reverse: true));

    // Logo starts at full scale (1.0) to ensure immediate visibility
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.elasticOut),
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 2 * 3.14159).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _preloadedImages = List<ImageProvider?>.filled(_slides.length, null);

    // Initial background - set to food1.webp immediately as requested
    _backgroundProvider = const AssetImage('assets/food1.webp');

    unawaited(_iconController.forward());
    unawaited(_preloadImages());
  }

  Future<void> _preloadImages() async {
    // Ensure splash is visible for at least 2 seconds for branding
    final minDelay = Future<void>.delayed(const Duration(milliseconds: 2500));

    try {
      // 1. Preload the first onboarding image (atmospheric) immediately
      if (mounted) {
        precacheImage(const AssetImage('assets/food1.webp'), context)
            .then((_) {
              if (mounted) {
                setState(() {
                  _backgroundProvider = const AssetImage('assets/food1.webp');
                });
              }
            })
            .catchError(
              (e) => debugPrint('Fallback background preload failed: $e'),
            );
      }

      final preloadingTasks = <Future<void>>[];

      for (int i = 0; i < _slides.length; i++) {
        if (!mounted) return;

        final imageProvider = AssetImage(_slides[i]['image']!);
        preloadingTasks.add(
          precacheImage(imageProvider, context)
              .then((_) {
                if (mounted) {
                  _preloadedImages[i] = imageProvider;
                }
              })
              .catchError((Object e) {
                debugPrint(
                  'Failed to preload image: ${_slides[i]['image']} - $e',
                );
              }),
        );
      }

      await Future.wait(preloadingTasks);

      // Start Data Sync in the background to avoid blocking the user
      if (mounted) {
        debugPrint('SPLASH: Starting data sync in background...');
        unawaited(
          ref.read(supabaseSyncManagerProvider.notifier).syncRestaurants(),
        );
      }
    } on Object catch (e) {
      debugPrint('Global initialization error: $e');
    } finally {
      await minDelay;

      if (mounted) {
        final prefs = ref.read(preferencesServiceProvider);
        final authRepo = ref.read(authRepositoryProvider);
        final user = authRepo.currentUser;

        // Directly navigate to dashboard if user is already logged in
        if (user != null) {
          debugPrint('SPLASH: User logged in, verifying session...');
          final isValid = await authRepo.verifySession();

          if (!mounted) return;

          if (isValid) {
            debugPrint('SPLASH: Session valid, navigating to dashboard...');
            context.goNamed('mainDashBoard');
            return;
          } else {
            debugPrint(
              'SPLASH: Session invalid or user removed. Redirecting to login...',
            );
            // Session was cleared in verifySession() if invalid
            context.goNamed('mainLoginScreen');
            return;
          }
        }

        if (prefs.isOnboardingCompleted) {
          context.goNamed('mainLoginScreen');
          return;
        }

        setState(() {
          _imagesLoaded = true;
          _showLoader = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _iconController.dispose();
    _pulseController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _nextSlide() async {
    if (_currentPage < _slides.length - 1) {
      unawaited(
        _pageController.animateToPage(
          _currentPage + 1,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        ),
      );
    } else {
      final user = ref.read(authRepositoryProvider).currentUser;
      if (user != null) {
        context.goNamed('mainDashBoard');
        return;
      }

      final allGranted = await PermissionScreen.areAllPermissionsGranted();
      if (!mounted) return;
      if (allGranted) {
        context.goNamed('mainLoginScreen');
      } else {
        context.goNamed('permissionsScreen');
      }
    }
  }

  Future<void> _skipToLogin() async {
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user != null) {
      context.goNamed('mainDashBoard');
      return;
    }

    final allGranted = await PermissionScreen.areAllPermissionsGranted();
    if (!mounted) return;
    if (allGranted) {
      context.goNamed('mainLoginScreen');
    } else {
      context.goNamed('permissionsScreen');
    }
  }

  @override
  Widget build(BuildContext context) {
    primaryColor = Theme.of(context).colorScheme.primary;
    surfaceColor = Theme.of(context).colorScheme.surface;
    onSurfaceColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      backgroundColor: Colors.black,
      body: _showLoader ? _buildLoader() : _buildSlider(),
    );
  }

  Widget _buildLoader() {
    return Stack(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 1000),
          child: Container(
            key: ValueKey(_backgroundProvider),
            decoration: BoxDecoration(
              image: DecorationImage(
                image:
                    _backgroundProvider ??
                    const AssetImage('assets/food1.webp'),
                fit: BoxFit.cover,
                onError: (exception, stackTrace) {
                  debugPrint('Background image load failed: $exception');
                },
              ),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.6),
                Colors.black.withValues(alpha: 0.3),
                Colors.black.withValues(alpha: 0.8),
              ],
            ),
          ),
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 250,
                child: AnimatedBuilder(
                  animation: Listenable.merge([
                    _iconController,
                    _pulseController,
                  ]),
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation
                          .value, // Removed clamp to allow full elastic effect
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer glow/pulse circle
                          Transform.scale(
                            scale: _pulseAnimation.value,
                            child: Container(
                              width: 230,
                              height: 230,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: primaryColor.withValues(alpha: 0.15),
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                          // Premium outer glow
                          Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withValues(alpha: 0.1),
                                  blurRadius: 50,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                          ),
                          // Middle translucent ring
                          Container(
                            width: 180,
                            height: 180,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.03),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.08),
                                width: 1,
                              ),
                            ),
                          ),
                          // Inner Logo Container - Now fully covers the area
                          Transform.rotate(
                            angle: _rotationAnimation.value,
                            child: Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryColor.withValues(alpha: 0.4),
                                    blurRadius: 25,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/icon/app_icon.png',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(
                                        Icons.restaurant,
                                        color: primaryColor,
                                        size: 80,
                                      ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'Restro Hub',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 54,
                  fontWeight: FontWeight.w900,
                  color: primaryColor,
                  letterSpacing: 6,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      offset: const Offset(2, 4),
                      blurRadius: 12,
                    ),
                    Shadow(
                      color: primaryColor.withValues(alpha: 0.4),
                      blurRadius: 25,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'PREMIUM DINING EXPERIENCE',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.6),
                  letterSpacing: 5,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 80),
              _buildLoadingStatus(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingStatus() {
    final syncStatus = ref.watch(globalSyncStatusProvider);
    final isSyncing = syncStatus.status == SyncStatus.syncing;

    return Column(
      children: [
        SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(
              primaryColor.withValues(alpha: 0.9),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          isSyncing
              ? 'Syncing data, please wait...'
              : 'Preparing your experience...',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.4),
            letterSpacing: 1.5,
          ),
        ),
        if (syncStatus.status == SyncStatus.error) ...[
          const SizedBox(height: 8),
          Text(
            'Sync failed. Using local data.',
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: Colors.red.withValues(alpha: 0.6),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSlider() {
    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: _slides.length,
          onPageChanged: (index) {
            setState(() {
              _currentPage = index;
            });
          },
          itemBuilder: (context, index) {
            return _buildSlideItem(_slides[index], index);
          },
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 20,
          right: 20,
          child: TextButton(
            onPressed: _skipToLogin,
            style: TextButton.styleFrom(
              backgroundColor: Colors.black.withValues(alpha: .5),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: primaryColor.withValues(alpha: .3)),
              ),
            ),
            child: Text(
              'SKIP',
              style: GoogleFonts.poppins(
                color: primaryColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: .8),
                  Colors.black,
                ],
              ),
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom + 30,
              top: 40,
              left: 24,
              right: 24,
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _slides.length,
                    (index) => _buildIndicator(index == _currentPage),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _nextSlide,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.black,
                      elevation: 8,
                      shadowColor: primaryColor.withValues(alpha: .5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _currentPage < _slides.length - 1
                              ? 'NEXT'
                              : 'GET STARTED',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward, size: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSlideItem(Map<String, String> slide, int index) {
    final preloadedImage = index < _preloadedImages.length
        ? _preloadedImages[index]
        : null;

    return Stack(
      fit: StackFit.expand,
      children: [
        if (_imagesLoaded && preloadedImage != null)
          Image(image: preloadedImage, fit: BoxFit.cover)
        else
          Image.asset(
            slide['image']!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return ColoredBox(
                color: const Color(0xFF1A1A1A),
                child: Icon(
                  Icons.restaurant,
                  size: 100,
                  color: primaryColor.withValues(alpha: .3),
                ),
              );
            },
          ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: .3),
                Colors.black.withValues(alpha: .5),
                Colors.black.withValues(alpha: .9),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),
        Positioned(
          bottom: 200,
          left: 24,
          right: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, primaryColor.withValues(alpha: 0.7)],
                  ),
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: .5),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                slide['title']!,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.2,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: .8),
                      blurRadius: 20,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                slide['description']!,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.white.withValues(alpha: .9),
                  height: 1.6,
                  letterSpacing: 0.5,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: .8),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 4,
      width: isActive ? 32 : 16,
      decoration: BoxDecoration(
        gradient: isActive
            ? LinearGradient(
                colors: [primaryColor, primaryColor.withValues(alpha: 0.7)],
              )
            : null,
        color: isActive ? null : primaryColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(2),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.5),
                  blurRadius: 8,
                ),
              ]
            : null,
      ),
    );
  }
}
