import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:restro_hub/core/extensions/context_extension.dart';
import 'package:restro_hub/core/theme/theme_provider.dart';
import 'package:restro_hub/features/auth/data/models/user_model.dart';
import 'package:restro_hub/features/dashboard/logic/membership_rules.dart';
import 'package:restro_hub/features/dashboard/presentation/providers/loyalty_provider.dart';
import 'package:restro_hub/features/restaurants/presentation/providers/restaurant_provider.dart';
import 'package:restro_hub/infrastructure/sync/sync_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final UserModel? user;
  const ProfileScreen({super.key, this.user});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late TextEditingController _nameController;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.user?.email.split('@').first ?? 'Guest User',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      if (mounted) {
        _showImageOverlay(File(pickedFile.path));
      }
    }
  }

  void _showImageOverlay(File file) {
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog.fullscreen(
          backgroundColor: Colors.black,
          child: Stack(
            children: [
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    InteractiveViewer(
                      minScale: 1,
                      maxScale: 4,
                      child: Image.file(file),
                    ),
                    IgnorePointer(
                      child: Container(
                        width: 280,
                        height: 280,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              spreadRadius: 1000,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 40,
                left: 40,
                right: 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'CANCEL',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _imageFile = file;
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                      ),
                      child: const Text('SAVE'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showImageSourceActionSheet(BuildContext context) {
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        builder: (context) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('Gallery'),
                    onTap: () {
                      Navigator.pop(context);
                      unawaited(_pickImage(ImageSource.gallery));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.camera_alt),
                    title: const Text('Camera'),
                    onTap: () {
                      Navigator.pop(context);
                      unawaited(_pickImage(ImageSource.camera));
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final points = (ref.watch(loyaltyProvider) as num).toInt();
    final tierName = MembershipRules.getTierName(
      MembershipRules.getTier(points),
    );
    final progress = MembershipRules.getNextTierProgress(points);
    final pointsToNext = MembershipRules.getPointsToNextTier(points);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colorScheme.primary, colorScheme.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -50,
                      top: -50,
                      child: CircleAvatar(
                        radius: 100,
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.white,
                                backgroundImage: _imageFile != null
                                    ? FileImage(_imageFile!)
                                    : const NetworkImage(
                                            'https://i.pravatar.cc/150?u=restrohub_user',
                                          )
                                          as ImageProvider,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () =>
                                      _showImageSourceActionSheet(context),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                      size: 16,
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
                ),
              ),
              title: Text(
                'Profile',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              centerTitle: true,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildInfoCard(
                    colorScheme,
                    _nameController.text,
                    widget.user?.email ?? 'guest@restrohub.com',
                  ),
                  const SizedBox(height: 20),
                  _buildMembershipSection(
                    context,
                    colorScheme,
                    points,
                    tierName,
                    progress,
                    pointsToNext,
                  ),
                  const SizedBox(height: 24),
                  _buildSettingsSection(context, colorScheme),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(ColorScheme colorScheme, String name, String email) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.person_outline, 'Name', name),
          const Divider(height: 30),
          _buildInfoRow(Icons.email_outlined, 'Email', email),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMembershipSection(
    BuildContext context,
    ColorScheme colorScheme,
    int points,
    String tierName,
    double progress,
    int pointsToNext,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withValues(alpha: 0.8),
            colorScheme.primary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tierName,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'Loyalty Points: $points',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
              const Icon(Icons.stars, color: Colors.amber, size: 48),
            ],
          ),
          const SizedBox(height: 24),
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 12,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            pointsToNext > 0
                ? '$pointsToNext more points to next tier'
                : 'You are at maximum tier!',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 12),
          child: Text(
            'Settings',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        _buildSettingTile(
          context,
          icon: Icons.favorite_border_rounded,
          title: 'My Favorites',
          subtitle: 'View your saved food items',
          onTap: () => GoRouter.of(context).pushNamed('showFavourites'),
        ),
        const SizedBox(height: 12),
        _buildSettingTile(
          context,
          icon: Icons.sync,
          title: 'Data Synchronization',
          subtitle: 'Sync your data with the cloud',
          trailing: TextButton(
            onPressed: () => ref.invalidate(initialSyncProvider),
            child: const Text('Sync Now'),
          ),
        ),
        const SizedBox(height: 12),
        _buildThemeTile(context, colorScheme),
        const SizedBox(height: 12),
        _buildKdsTile(context, colorScheme),
        const SizedBox(height: 24),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 12),
          child: Text(
            'Support & About',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        _buildSettingTile(
          context,
          icon: Icons.help_outline,
          title: 'Helpline Support',
          subtitle: 'Get 24/7 assistance',
          onTap: () => GoRouter.of(context).pushNamed('helplineScreen'),
        ),
        const SizedBox(height: 12),
        _buildSettingTile(
          context,
          icon: Icons.contact_support_outlined,
          title: 'Contact Details',
          subtitle: 'Reach out to us directly',
          onTap: () => GoRouter.of(context).pushNamed('contactUsScreen'),
        ),
        const SizedBox(height: 12),
        _buildSettingTile(
          context,
          icon: Icons.policy_outlined,
          title: 'Privacy Policy',
          subtitle: 'Read our terms and policies',
          onTap: () => GoRouter.of(context).pushNamed('policyScreen'),
        ),
        const SizedBox(height: 24),
        _buildSettingTile(
          context,
          icon: Icons.logout,
          title: 'Logout',
          subtitle: 'Sign out from your account',
          iconColor: Colors.red,
          onTap: () {
            // Implement logout
          },
        ),
      ],
    );
  }

  Widget _buildThemeTile(BuildContext context, ColorScheme colorScheme) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isDark ? Icons.dark_mode : Icons.light_mode,
              color: colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Dark Theme',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  'Switch between light and dark mode',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: isDark,
            onChanged: (val) {
              ref.read(themeProvider.notifier).toggleTheme(isDark: val);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    Color? iconColor,
    VoidCallback? onTap,
  }) {
    final cs = context.colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (iconColor ?? cs.primary).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor ?? cs.primary, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildKdsTile(BuildContext context, ColorScheme colorScheme) {
    final syncState = ref.watch(kdsSyncProvider);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.restaurant_menu,
                  color: colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Restaurant Mode (KDS)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      'Kitchen Display System mode',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: syncState.isServerRunning,
                onChanged: (_) =>
                    ref.read(kdsSyncProvider.notifier).toggleKdsServer(),
              ),
            ],
          ),
          if (syncState.isServerRunning) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.wifi, size: 14, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(
                    'Active: ${syncState.serverAddress}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
