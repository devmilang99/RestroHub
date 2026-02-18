import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:permission_handler/permission_handler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restro_hub/core/theme/theme_provider.dart';
import 'dart:async';
import 'dart:io' show Platform;
import 'dart:ui';

class PermissionScreen extends ConsumerStatefulWidget {
  const PermissionScreen({super.key});

  @override
  ConsumerState<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends ConsumerState<PermissionScreen>
    with TickerProviderStateMixin {
  late List<PermissionItem> _permissions;
  int _currentIndex = 0;
  bool _isProcessing = false;
  bool _showThemeSelection = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late AnimationController _bgAnimationController;

  List<PermissionItem> _getPlatformSpecificPermissions() {
    final permissions = <PermissionItem>[];

    if (kIsWeb) {
      // Web: Location only
      permissions.add(
        PermissionItem(
          permission: Permission.location,
          title: 'Smart Location',
          description: 'Helps us find the nearest culinary gems around you.',
          icon: Icons.location_on_rounded,
          imageUrl:
              'https://images.unsplash.com/photo-1526778548025-fa2f459cd5c1?q=80&w=2068&auto=format&fit=crop',
        ),
      );
    } else if (Platform.isAndroid) {
      // Android: Storage, Location, Contacts, Camera
      permissions.addAll([
        PermissionItem(
          permission: Permission.storage,
          title: 'Storage Access',
          description:
              'Needed to save your receipts and download digital menus.',
          icon: Icons.folder_open_rounded,
          imageUrl:
              'https://images.unsplash.com/photo-1450101499163-c8848c66ca85?q=80&w=2070&auto=format&fit=crop',
        ),
        PermissionItem(
          permission: Permission.location,
          title: 'Smart Location',
          description: 'Helps us find the nearest culinary gems around you.',
          icon: Icons.location_on_rounded,
          imageUrl:
              'https://images.unsplash.com/photo-1526778548025-fa2f459cd5c1?q=80&w=2068&auto=format&fit=crop',
        ),
        PermissionItem(
          permission: Permission.contacts,
          title: 'Social Connect',
          description:
              'Invite and share your favorite meals with friends effortlessly.',
          icon: Icons.people_alt_rounded,
          imageUrl:
              'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?q=80&w=2070&auto=format&fit=crop',
        ),
        PermissionItem(
          permission: Permission.camera,
          title: 'Camera Access',
          description: 'Capture photos of dishes and create food memories.',
          icon: Icons.camera_alt_rounded,
          imageUrl:
              'https://images.unsplash.com/photo-1502920917128-1aa500764cbd?q=80&w=2070&auto=format&fit=crop',
        ),
      ]);
    } else if (Platform.isIOS) {
      // iOS: Storage, Location, Contacts, Camera
      permissions.addAll([
        PermissionItem(
          permission: Permission.storage,
          title: 'Storage Access',
          description:
              'Needed to save your receipts and download digital menus.',
          icon: Icons.folder_open_rounded,
          imageUrl:
              'https://images.unsplash.com/photo-1450101499163-c8848c66ca85?q=80&w=2070&auto=format&fit=crop',
        ),
        PermissionItem(
          permission: Permission.location,
          title: 'Smart Location',
          description: 'Helps us find the nearest culinary gems around you.',
          icon: Icons.location_on_rounded,
          imageUrl:
              'https://images.unsplash.com/photo-1526778548025-fa2f459cd5c1?q=80&w=2068&auto=format&fit=crop',
        ),
        PermissionItem(
          permission: Permission.contacts,
          title: 'Social Connect',
          description:
              'Invite and share your favorite meals with friends effortlessly.',
          icon: Icons.people_alt_rounded,
          imageUrl:
              'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?q=80&w=2070&auto=format&fit=crop',
        ),
        PermissionItem(
          permission: Permission.camera,
          title: 'Camera Access',
          description: 'Capture photos of dishes and create food memories.',
          icon: Icons.camera_alt_rounded,
          imageUrl:
              'https://images.unsplash.com/photo-1502920917128-1aa500764cbd?q=80&w=2070&auto=format&fit=crop',
        ),
      ]);
    }

    return permissions;
  }

  @override
  void initState() {
    super.initState();
    _permissions = _getPlatformSpecificPermissions();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _bgAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _animationController.forward();
    _checkInitialPermissions();
  }

  Future<void> _checkInitialPermissions() async {
    List<PermissionItem> grantedOnes = [];
    for (var item in _permissions) {
      if (await item.permission.isGranted) {
        grantedOnes.add(item);
      }
    }

    if (mounted) {
      setState(() {
        _permissions.removeWhere((p) => grantedOnes.contains(p));
        if (_permissions.isEmpty) {
          _showThemeSelection = true;
        }
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _bgAnimationController.dispose();
    super.dispose();
  }

  Future<void> _requestPermission() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    final item = _permissions[_currentIndex];
    final status = await item.permission.request();

    if (status.isPermanentlyDenied) {
      if (mounted) {
        await showDialog(
          context: context,
          builder: (context) => BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: AlertDialog(
              backgroundColor: Colors.white.withValues(alpha: 0.9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: Text(
                'Permission Required',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
              content: Text(
                'The ${item.title} permission is permanently denied. Please enable it in the app settings to continue.',
                style: GoogleFonts.poppins(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'CANCEL',
                    style: GoogleFonts.poppins(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    openAppSettings();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'OPEN SETTINGS',
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } else if (status.isDenied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Permission for ${item.title} is required to proceed.',
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } else if (status.isGranted) {
      if (_currentIndex < _permissions.length - 1) {
        await _animationController.reverse();
        setState(() {
          _currentIndex++;
          _isProcessing = false;
        });
        await _animationController.forward();
      } else {
        // Transition to Theme Selection
        await _animationController.reverse();
        setState(() {
          _showThemeSelection = true;
          _isProcessing = false;
        });
        await _animationController.forward();
      }
    }

    if (mounted) {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Animated Background
          _buildAestheticBackground(),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 32.0,
                vertical: 24,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Progress Bar
                  _buildProgressBar(),

                  const Spacer(),

                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: _showThemeSelection
                          ? _buildThemeSelectionView(isDark)
                          : _buildPermissionView(isDark),
                    ),
                  ),

                  const Spacer(),

                  // Primary Button
                  _buildPrimaryButton(isDark),

                  const SizedBox(height: 20),

                  if (!_showThemeSelection)
                    TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'These permissions ensure a personalized culinary journey.',
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: Text(
                        'I\'LL DO IT LATER',
                        style: GoogleFonts.poppins(
                          color: isDark ? Colors.white38 : Colors.black38,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  if (_showThemeSelection) const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAestheticBackground() {
    String? currentImageUrl;
    if (!_showThemeSelection && _permissions.isNotEmpty) {
      currentImageUrl = _permissions[_currentIndex].imageUrl;
    }

    return Stack(
      children: [
        // Base Dynamic Gradient
        AnimatedBuilder(
          animation: _bgAnimationController,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    HSLColor.fromAHSL(
                      1,
                      (_bgAnimationController.value * 360),
                      0.4,
                      0.1,
                    ).toColor(),
                    HSLColor.fromAHSL(
                      1,
                      ((_bgAnimationController.value * 360) + 180) % 360,
                      0.4,
                      0.05,
                    ).toColor(),
                  ],
                ),
              ),
            );
          },
        ),
        // Aesthetic Image Background with Cross-fade logic (simplified with AnimatedSwitcher if needed, but here basic)
        if (currentImageUrl != null)
          AnimatedSwitcher(
            duration: const Duration(seconds: 1),
            child: Container(
              key: ValueKey(currentImageUrl),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(currentImageUrl),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withValues(alpha: 0.6),
                    BlendMode.darken,
                  ),
                ),
              ),
            ),
          ),
        // Blur Effect
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(color: Colors.black.withValues(alpha: 0.3)),
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _permissions.length + 1, // +1 for Theme selection
        (index) => Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 4,
            decoration: BoxDecoration(
              color:
                  index <=
                      (_showThemeSelection
                          ? _permissions.length
                          : _currentIndex)
                  ? Colors.orange
                  : Colors.grey.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
              boxShadow:
                  index <=
                      (_showThemeSelection
                          ? _permissions.length
                          : _currentIndex)
                  ? [
                      BoxShadow(
                        color: Colors.orange.withValues(alpha: 0.5),
                        blurRadius: 4,
                      ),
                    ]
                  : [],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionView(bool isDark) {
    final item = _permissions[_currentIndex];
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(35),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.orange.withValues(alpha: 0.2),
                Colors.deepOrange.withValues(alpha: 0.1),
              ],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withValues(alpha: 0.2),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Icon(item.icon, size: 80, color: Colors.orange),
        ),
        const SizedBox(height: 50),
        Text(
          item.title,
          textAlign: TextAlign.center,
          style: GoogleFonts.playfairDisplay(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          item.description,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.white.withValues(alpha: 0.7),
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildThemeSelectionView(bool isDark) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(35),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                isDark
                    ? Colors.indigo.withValues(alpha: 0.2)
                    : Colors.amber.withValues(alpha: 0.2),
                isDark
                    ? Colors.blueAccent.withValues(alpha: 0.1)
                    : Colors.orangeAccent.withValues(alpha: 0.1),
              ],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.indigo : Colors.amber).withValues(
                  alpha: 0.2,
                ),
                blurRadius: 30,
              ),
            ],
          ),
          child: Icon(
            isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            size: 80,
            color: isDark ? Colors.indigo.shade200 : Colors.amber.shade400,
          ),
        ),
        const SizedBox(height: 50),
        Text(
          'Choose Your Vibe',
          textAlign: TextAlign.center,
          style: GoogleFonts.playfairDisplay(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Personalize your Restro Hub experience with a theme that suits your mood.',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.white.withValues(alpha: 0.7),
            height: 1.6,
          ),
        ),
        const SizedBox(height: 40),
        // Custom Styled Slider/Toggle
        Container(
          width: 280,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white12),
          ),
          child: Stack(
            children: [
              AnimatedAlign(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOutBack,
                alignment: isDark
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  width: 135,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withValues(alpha: 0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () =>
                          ref.read(themeProvider.notifier).toggleTheme(false),
                      child: Container(
                        height: 44,
                        color: Colors.transparent,
                        child: Center(
                          child: Text(
                            'LIGHT',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: !isDark ? Colors.black87 : Colors.white60,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () =>
                          ref.read(themeProvider.notifier).toggleTheme(true),
                      child: Container(
                        height: 44,
                        color: Colors.transparent,
                        child: Center(
                          child: Text(
                            'DARK',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: isDark ? Colors.black87 : Colors.white60,
                            ),
                          ),
                        ),
                      ),
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

  Widget _buildPrimaryButton(bool isDark) {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton(
        onPressed: _isProcessing
            ? null
            : () {
                if (_showThemeSelection) {
                  context.goNamed('mainLoginScreen');
                } else {
                  _requestPermission();
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 10,
          shadowColor: Colors.orange.withValues(alpha: 0.4),
        ),
        child: _isProcessing
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                _showThemeSelection
                    ? 'CONTINUE TO DINING'
                    : (_currentIndex == _permissions.length - 1
                          ? 'REVEAL EXPERIENCE'
                          : 'ALLOW ACCESS'),
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
      ),
    );
  }
}

class PermissionItem {
  final Permission permission;
  final String title;
  final String description;
  final IconData icon;
  final String imageUrl;

  PermissionItem({
    required this.permission,
    required this.title,
    required this.description,
    required this.icon,
    required this.imageUrl,
  });
}
