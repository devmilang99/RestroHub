import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';

class splashScreen extends StatefulWidget {
  const splashScreen({super.key});

  @override
  State<splashScreen> createState() => _splashScreenState();
}

class _splashScreenState extends State<splashScreen>
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

  // Black and Gold color scheme
  static const Color goldColor = Colors.orange;
  static const Color darkGoldColor = Colors.deepOrange;
  static const Color blackColor = Colors.black;
  static const Color darkGreyColor = Colors.grey;

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

    // Icon animation controller (2 seconds)
    _iconController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Pulse animation controller
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    // Scale animation (smooth bounce)
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.elasticOut),
    );

    // Rotation animation
    _rotationAnimation = Tween<double>(begin: 0.0, end: 2 * 3.14159).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.easeInOut),
    );

    // Pulse animation for loading ring
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Start icon animation
    _iconController.forward();

    // Preload images and transition after 2 seconds
    _preloadImages();
  }

  Future<void> _preloadImages() async {
    // Wait for 2 seconds (icon animation)
    await Future.delayed(const Duration(milliseconds: 2000));

    // Preload all images
    try {
      for (var slide in _slides) {
        final imageProvider = NetworkImage(slide['image']!);
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
      // If preloading fails, still show the slider
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

  void _nextSlide() {
    if (_currentPage < _slides.length - 1) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    } else {
      // Navigate to login
      context.goNamed('permissionsScreen');
    }
  }

  void _skipToLogin() {
    context.goNamed('mainLoginScreen');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: blackColor,
      body: _showLoader ? _buildLoader() : _buildSlider(),
    );
  }

  Widget _buildLoader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [blackColor, darkGreyColor, blackColor],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Icon with Gold Ring
            AnimatedBuilder(
              animation: Listenable.merge([_iconController, _pulseController]),
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Pulsing outer ring
                      Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: goldColor.withValues(alpha: .3),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      // Main icon container
                      Transform.rotate(
                        angle: _rotationAnimation.value,
                        child: Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [goldColor, darkGoldColor],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: goldColor.withValues(alpha: .5),
                                blurRadius: 30,
                                spreadRadius: 10,
                              ),
                              const BoxShadow(
                                color: Colors.black54,
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.restaurant_menu,
                            size: 65,
                            color: blackColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 40),

            // App Name
            Text(
              'Restro Hub',
              style: GoogleFonts.playfairDisplay(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: goldColor,
                letterSpacing: 3,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              'PREMIUM DINING EXPERIENCE',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: goldColor.withValues(alpha: .7),
                letterSpacing: 4,
                fontWeight: FontWeight.w300,
              ),
            ),

            const SizedBox(height: 60),

            // Loading indicator
            if (!_imagesLoaded)
              Column(
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        goldColor.withValues(alpha: .8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Preparing your experience...',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: goldColor.withValues(alpha: .6),
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider() {
    return Stack(
      children: [
        // Fullscreen PageView
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

        // Skip button (top right)
        Positioned(
          top: MediaQuery.of(context).padding.top + 20,
          right: 20,
          child: TextButton(
            onPressed: _skipToLogin,
            style: TextButton.styleFrom(
              backgroundColor: blackColor.withValues(alpha: .5),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: goldColor.withValues(alpha: .3)),
              ),
            ),
            child: Text(
              'SKIP',
              style: GoogleFonts.poppins(
                color: goldColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
              ),
            ),
          ),
        ),

        // Bottom controls
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
                  blackColor.withValues(alpha: .8),
                  blackColor,
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
                // Page Indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _slides.length,
                    (index) => _buildIndicator(index == _currentPage),
                  ),
                ),

                const SizedBox(height: 30),

                // Next Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _nextSlide,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: goldColor,
                      foregroundColor: blackColor,
                      elevation: 8,
                      shadowColor: goldColor.withValues(alpha: .5),
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
        // Background Image
        _imagesLoaded && index < _preloadedImages.length
            ? Image(image: _preloadedImages[index], fit: BoxFit.cover)
            : Image.network(
                slide['image']!,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: darkGreyColor,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: goldColor,
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
                    color: darkGreyColor,
                    child: Icon(
                      Icons.restaurant,
                      size: 100,
                      color: goldColor.withValues(alpha: .3),
                    ),
                  );
                },
              ),

        // Gradient Overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                blackColor.withValues(alpha: .3),
                blackColor.withValues(alpha: .5),
                blackColor.withValues(alpha: .9),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),

        // Content
        Positioned(
          bottom: 200,
          left: 24,
          right: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gold accent line
              Container(
                width: 60,
                height: 4,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [goldColor, darkGoldColor],
                  ),
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: goldColor.withValues(alpha: .5),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Title
              Text(
                slide['title']!,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.2,
                  shadows: [
                    Shadow(
                      color: blackColor.withValues(alpha: .8),
                      blurRadius: 20,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Description
              Text(
                slide['description']!,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.white.withValues(alpha: .9),
                  height: 1.6,
                  letterSpacing: 0.5,
                  shadows: [
                    Shadow(
                      color: blackColor.withValues(alpha: .8),
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
            ? const LinearGradient(colors: [goldColor, darkGoldColor])
            : null,
        color: isActive ? null : goldColor.withValues(alpha: .3),
        borderRadius: BorderRadius.circular(2),
        boxShadow: isActive
            ? [BoxShadow(color: goldColor.withValues(alpha: .5), blurRadius: 8)]
            : null,
      ),
    );
  }
}
