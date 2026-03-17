import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:restro_hub/screens/permission_screen.dart';
import 'dart:async';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
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
  final List<ImageProvider> _preloadedImages = [];

  // Theme-aware colors (will be initialized in build)
  late Color primaryColor;
  late Color surfaceColor;
  late Color onSurfaceColor;

  // Feature slides data with web image URLs
  final List<Map<String, String>> _slides = [
    {
      'image':
          'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=1200&q=90',
      'title': 'Delicious Food',
      'description':
          'Explore a wide variety of cuisines from local restaurants',
    },
    {
      'image':
          'https://images.unsplash.com/photo-1526367790999-0150786686a2?w=1200&q=90',
      'title': 'Fast Delivery',
      'description':
          'Get your favorite meals delivered hot and fresh to your door',
    },
    {
      'image':
          'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=1200&q=90',
      'title': 'Easy Ordering',
      'description':
          'Browse menus, customize orders, and track deliveries in real-time',
    },
    {
      'image':
          'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=1200&q=90',
      'title': 'Special Offers',
      'description':
          'Enjoy exclusive deals and discounts on your favorite restaurants',
    },
  ];

  @override
  void initState() {
    super.initState();

    _iconController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.elasticOut),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 2 * 3.14159).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _iconController.forward();
    _preloadImages();
  }

  Future<void> _preloadImages() async {
    await Future.delayed(const Duration(milliseconds: 2000));

    try {
      for (var slide in _slides) {
        final imageProvider = NetworkImage(slide['image']!);
        if (!mounted) return;
        await precacheImage(imageProvider, context);
        _preloadedImages.add(imageProvider);
      }

      if (mounted) {
        setState(() {
          _imagesLoaded = true;
          _showLoader = false;
        });
      }
    } catch (e) {
      if (mounted) {
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
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    } else {
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
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                'assets/splashScreen/splashScreenBeginning.avif',
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.7),
                Colors.black.withValues(alpha: 0.5),
                Colors.black.withValues(alpha: 0.8),
              ],
            ),
          ),
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: Listenable.merge([
                  _iconController,
                  _pulseController,
                ]),
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            width: 180,
                            height: 180,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: primaryColor.withValues(alpha: 0.2),
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.1),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Transform.rotate(
                          angle: _rotationAnimation.value,
                          child: Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  primaryColor,
                                  primaryColor.withValues(alpha: 0.7),
                                ],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withValues(alpha: 0.6),
                                  blurRadius: 40,
                                  spreadRadius: 5,
                                ),
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 20,
                                  offset: const Offset(10, 10),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.restaurant_menu,
                              size: 55,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 50),
              Text(
                'Restro Hub',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                  letterSpacing: 4,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      offset: const Offset(2, 2),
                      blurRadius: 10,
                    ),
                    Shadow(
                      color: primaryColor.withValues(alpha: 0.3),
                      blurRadius: 20,
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
              if (!_imagesLoaded)
                Column(
                  children: [
                    SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          primaryColor.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Preparing your experience...',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.4),
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
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
    return Stack(
      fit: StackFit.expand,
      children: [
        _imagesLoaded && index < _preloadedImages.length
            ? Image(image: _preloadedImages[index], fit: BoxFit.cover)
            : Image.network(
                slide['image']!,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: const Color(0xFF1A1A1A),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: primaryColor,
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
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
