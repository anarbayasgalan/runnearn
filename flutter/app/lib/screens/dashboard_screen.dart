import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/glass_container.dart';
import '../widgets/mesh_background.dart';
import '../theme.dart';
import '../services/api_service.dart';
import '../widgets/logo_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? _user;
  bool _loading = true;
  int _navIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final data = await ApiService.getMe();
      if (data == null) {
        // Session invalid or server error
        _logout();
        return;
      }
      if (mounted) setState(() { _user = data; _loading = false; });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _logout() async {
    await ApiService.clearSession();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Background
          const Positioned.fill(child: MeshBackground()),

          // 2. Main Content
          SafeArea(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryOrange))
                : Stack(
                    children: [
                      SingleChildScrollView(
                        padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 120),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const LogoWidget(logoWidth: 160),
                                const Spacer(),
                                GlassContainer(
                                  width: 48,
                                  height: 48,
                                  borderRadius: 24,
                                  padding: EdgeInsets.zero,
                                  child: IconButton(
                                    icon: const Icon(Icons.logout, color: AppTheme.primaryDark),
                                    onPressed: _logout,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),

                            // Quick actions using GlassContainer
                            _actionCard(
                              icon: Icons.directions_run,
                              title: 'Start a Run',
                              desc: 'Track your run with GPS',
                              color: AppTheme.primaryOrange,
                              route: '/run',
                            ),
                            const SizedBox(height: 16),
                            _actionCard(
                              icon: Icons.emoji_events,
                              title: 'Challenges',
                              desc: 'Browse and accept challenges',
                              color: AppTheme.primaryDark,
                              route: '/challenge',
                            ),
                            const SizedBox(height: 16),
                            _actionCard(
                              icon: Icons.card_giftcard,
                              title: 'My Rewards',
                              desc: 'View your earned rewards',
                              color: AppTheme.primaryDark,
                              route: '/tokens',
                            ),
                            const SizedBox(height: 16),
                            _actionCard(
                              icon: Icons.settings,
                              title: 'Setup Profile',
                              desc: 'Update your company settings',
                              color: AppTheme.primaryDark,
                              route: '/setup',
                            ),
                            const SizedBox(height: 16),
                            _actionCard(
                              icon: Icons.leaderboard,
                              title: 'Leaderboard',
                              desc: 'Top runners by tokens earned',
                              color: Color(0xFFFFD700),
                              route: '/leaderboard',
                            ),
                          ],
                        ),
                      ),
                      
                      // 3. Floating Bottom Navigation Bar
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: _buildBottomNav(),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        border: Border(top: BorderSide(color: Colors.grey.withValues(alpha: 0.2))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(Icons.dashboard, 0),
            _buildNavItem(Icons.directions_run, 1),
            _buildNavItem(Icons.emoji_events, 2),
            _buildNavItem(Icons.card_giftcard, 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    final isActive = _navIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _navIndex = index);
        switch (index) {
          case 1: Navigator.pushNamed(context, '/run'); break;
          case 2: Navigator.pushNamed(context, '/challenge'); break;
          case 3: Navigator.pushNamed(context, '/tokens'); break;
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Icon(
          icon,
          size: 28,
          color: isActive ? AppTheme.primaryOrange : Colors.grey.shade400,
        ),
      ),
    );
  }

  Widget _actionCard({
    required IconData icon,
    required String title,
    required String desc,
    required Color color,
    required String route,
  }) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: GlassContainer(
        padding: const EdgeInsets.all(20),
        borderRadius: 24,
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.lexend(
                          color: AppTheme.primaryDark,
                          fontSize: 17,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(desc,
                      style: GoogleFonts.lexend(
                          color: Colors.grey.shade600, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppTheme.primaryDark, size: 24),
          ],
        ),
      ),
    );
  }
}
