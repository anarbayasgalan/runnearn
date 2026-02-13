import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';

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
      body: Container(
        color: const Color(0xFFF8F9FA), // Off-white bg
        child: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF6B00)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Hello, Runner!',
                                  style: GoogleFonts.outfit(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF1F2937))),
                              const SizedBox(height: 4),
                              Text(
                                _user?['userName'] ?? 'Runner',
                                style: GoogleFonts.outfit(
                                    fontSize: 14, color: const Color(0xFF6B7280)),
                              ),
                            ],
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.logout, color: Color(0xFF6B7280)),
                            onPressed: _logout,
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Quick actions
                      _actionCard(
                        icon: Icons.directions_run,
                        title: 'Start a Run',
                        desc: 'Track your run with GPS',
                        color: const Color(0xFFFF6B00), // Orange
                        route: '/run',
                      ),
                      const SizedBox(height: 16),
                      _actionCard(
                        icon: Icons.emoji_events,
                        title: 'Challenges',
                        desc: 'Browse and accept challenges',
                        color: const Color(0xFF2E86DE), // Blue
                        route: '/challenge',
                      ),
                      const SizedBox(height: 16),
                      _actionCard(
                        icon: Icons.card_giftcard,
                        title: 'My Rewards',
                        desc: 'View your earned rewards',
                        color: const Color(0xFF10B981), // Green
                        route: '/tokens',
                      ),
                    ],
                  ),
                ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            )
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          elevation: 0,
          currentIndex: _navIndex,
          onTap: (i) {
            setState(() => _navIndex = i);
            switch (i) {
              case 1: Navigator.pushNamed(context, '/run'); break;
              case 2: Navigator.pushNamed(context, '/challenge'); break;
              case 3: Navigator.pushNamed(context, '/tokens'); break;
            }
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFFFF6B00),
          unselectedItemColor: const Color(0xFF9CA3AF),
          selectedLabelStyle: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.outfit(fontSize: 11),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.directions_run), label: 'Run'),
            BottomNavigationBarItem(icon: Icon(Icons.emoji_events), label: 'Challenges'),
            BottomNavigationBarItem(icon: Icon(Icons.card_giftcard), label: 'Rewards'),
          ],
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
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.outfit(
                          color: const Color(0xFF1F2937),
                          fontSize: 17,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(desc,
                      style: GoogleFonts.outfit(
                          color: const Color(0xFF6B7280), fontSize: 13)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: const Color(0xFFD1D5DB), size: 24),
          ],
        ),
      ),
    );
  }
}
