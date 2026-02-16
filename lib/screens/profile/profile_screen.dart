import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../utils/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: user?.avatarUrl != null
                            ? ClipOval(
                                child: Image.network(
                                  user!.avatarUrl!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Icon(
                                Icons.person,
                                size: 40,
                                color: AppColors.primary,
                              ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user?.fullName ?? 'Guest User',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        user?.email ?? 'Sign in to access all features',
                        style: GoogleFonts.poppins(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Profile Options
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Account Section
                  Text(
                    'Account',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _ProfileCard(
                    children: [
                      _ProfileListTile(
                        icon: Icons.person_outline,
                        title: 'Edit Profile',
                        onTap: () {},
                      ),
                      const Divider(height: 1),
                      _ProfileListTile(
                        icon: Icons.location_on_outlined,
                        title: 'Shipping Address',
                        onTap: () {},
                      ),
                      const Divider(height: 1),
                      _ProfileListTile(
                        icon: Icons.credit_card_outlined,
                        title: 'Payment Methods',
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Orders Section
                  Text(
                    'Orders',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _ProfileCard(
                    children: [
                      _ProfileListTile(
                        icon: Icons.shopping_bag_outlined,
                        title: 'My Orders',
                        onTap: () {},
                      ),
                      const Divider(height: 1),
                      _ProfileListTile(
                        icon: Icons.favorite_border,
                        title: 'Wishlist',
                        onTap: () {},
                      ),
                      const Divider(height: 1),
                      _ProfileListTile(
                        icon: Icons.rate_review_outlined,
                        title: 'My Reviews',
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Settings Section
                  Text(
                    'Settings',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _ProfileCard(
                    children: [
                      _ProfileListTile(
                        icon: Icons.notifications_outlined,
                        title: 'Notifications',
                        onTap: () {},
                        trailing: Switch(
                          value: true,
                          onChanged: (value) {},
                          activeTrackColor: AppColors.primary,
                        ),
                      ),
                      const Divider(height: 1),
                      _ProfileListTile(
                        icon: Icons.dark_mode_outlined,
                        title: 'Dark Mode',
                        onTap: () {},
                        trailing: Switch(
                          value: false,
                          onChanged: (value) {},
                          activeTrackColor: AppColors.primary,
                        ),
                      ),
                      const Divider(height: 1),
                      _ProfileListTile(
                        icon: Icons.language_outlined,
                        title: 'Language',
                        subtitle: 'English',
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Support Section
                  Text(
                    'Support',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _ProfileCard(
                    children: [
                      _ProfileListTile(
                        icon: Icons.help_outline,
                        title: 'Help Center',
                        onTap: () {},
                      ),
                      const Divider(height: 1),
                      _ProfileListTile(
                        icon: Icons.chat_bubble_outline,
                        title: 'Contact Us',
                        onTap: () {},
                      ),
                      const Divider(height: 1),
                      _ProfileListTile(
                        icon: Icons.info_outline,
                        title: 'About',
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Sign Out / Sign In Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: authProvider.isAuthenticated
                        ? OutlinedButton.icon(
                            onPressed: () => _showSignOutDialog(context, authProvider),
                            icon: const Icon(Icons.logout, color: AppColors.error),
                            label: Text(
                              'Sign Out',
                              style: GoogleFonts.poppins(
                                color: AppColors.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.error),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          )
                        : ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.login),
                            label: Text(
                              'Sign In',
                              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(height: 20),

                  // Version
                  Center(
                    child: Text(
                      'Version 1.0.0',
                      style: GoogleFonts.poppins(
                        color: AppColors.textLight,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Sign Out',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to sign out?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await authProvider.signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
            },
            child: Text(
              'Sign Out',
              style: GoogleFonts.poppins(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final List<Widget> children;

  const _ProfileCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _ProfileListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Widget? trailing;

  const _ProfileListTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: AppColors.primary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textLight,
              ),
            )
          : null,
      trailing: trailing ??
          const Icon(
            Icons.chevron_right,
            color: AppColors.textLight,
          ),
    );
  }
}
