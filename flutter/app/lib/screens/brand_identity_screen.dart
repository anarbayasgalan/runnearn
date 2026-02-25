import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme.dart';
import '../widgets/glass_container.dart';
import '../widgets/mesh_background.dart';

class BrandIdentityScreen extends StatelessWidget {
  const BrandIdentityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Dynamic Mesh Background
          const Positioned.fill(child: MeshBackground()),
          
          // 2. White gradient overlay to soften the bottom
          Positioned(
            bottom: 0, left: 0, right: 0,
            height: 200,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.white,
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

          // 3. Foreground Content
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildAppBar(context),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildConceptBadge(),
                      const SizedBox(height: 24),
                      _buildLogoCard(),
                      const SizedBox(height: 24),
                      _buildDesignRationaleCard(),
                      const SizedBox(height: 24),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildPaletteCard()),
                          const SizedBox(width: 16),
                          Expanded(child: _buildTypographyCard()),
                        ],
                      ),
                      const SizedBox(height: 32),
                      _buildSectionHeader('APPLICATION PREVIEW'),
                      const SizedBox(height: 16),
                      _buildPreviewCards(),
                      const SizedBox(height: 120), // padding for floating button
                    ]),
                  ),
                ),
              ],
            ),
          ),
          
          // 4. Floating Action / Selection Button
          Positioned(
            bottom: 100, // Moved up to make room for nav bar
            left: 50,
            right: 50,
            child: _buildSelectButton(),
          ),
          
          // 5. Bottom Navigation Bar
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: _buildBottomNav(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.withValues(alpha: 0.2))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(Icons.palette, true),
            _buildNavItem(Icons.layers, false),
            _buildNavItem(Icons.history, false),
            _buildNavItem(Icons.settings, false),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, bool isActive) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Icon(
        icon,
        size: 28,
        color: isActive ? AppTheme.primaryOrange : Colors.grey.shade400,
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildIconButton(Icons.arrow_back, () => Navigator.pop(context)),
            Text(
              'Brand Identity',
              style: GoogleFonts.lexend( // Use lexend if lexendRounded isn't imported, but assuming it is available based on design
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryDark,
              ),
            ),
            _buildIconButton(Icons.share, () {}),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        width: 48,
        height: 48,
        borderRadius: 24,
        padding: const EdgeInsets.all(0),
        child: Center(
          child: Icon(icon, color: AppTheme.primaryDark, size: 24),
        ),
      ),
    );
  }

  Widget _buildConceptBadge() {
    return Center(
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        borderRadius: 20,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8, height: 8,
              decoration: const BoxDecoration(
                color: AppTheme.primaryOrange,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'CONCEPT 10: CONNECTED PULSE (VARIANT 3/3)',
              style: GoogleFonts.lexend(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryOrange,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoCard() {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Run', style: GoogleFonts.lexend(fontSize: 40, fontWeight: FontWeight.w700, color: AppTheme.primaryDark)),
              const Text('\'', style: TextStyle(fontSize: 40, fontWeight: FontWeight.w700, color: AppTheme.primaryDark)),
              // The pulse logo part
              Stack(
                alignment: Alignment.center,
                children: [
                  Text('N', style: GoogleFonts.lexend(fontSize: 44, fontWeight: FontWeight.w900, color: AppTheme.primaryOrange)),
                  Text('N', style: GoogleFonts.lexend(fontSize: 44, fontWeight: FontWeight.w900, color: AppTheme.primaryDark.withValues(alpha: 0.5))),
                ],
              ),
              Text('Earn', style: GoogleFonts.lexend(fontSize: 40, fontWeight: FontWeight.w700, color: AppTheme.primaryDark)),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'MOVE • CONNECT • GAIN',
            style: GoogleFonts.lexend(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesignRationaleCard() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GlassContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Design Rationale', style: GoogleFonts.lexend(fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.primaryDark)),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildRationaleItem(Icons.speed, 'Motion'),
                  _buildRationaleItem(Icons.hub, 'Connect'),
                  _buildRationaleItem(Icons.payments, 'Rewards'),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
        // Overlapping Read More button
        Positioned(
          bottom: -16,
          left: 0,
          right: 0,
          child: Center(
            child: GlassContainer(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              borderRadius: 20,
              color: AppTheme.primaryOrange.withValues(alpha: 0.15),
              borderColor: AppTheme.primaryOrange.withValues(alpha: 0.3),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Read More', style: GoogleFonts.lexend(fontWeight: FontWeight.w600, color: AppTheme.primaryDark)),
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down, size: 20, color: AppTheme.primaryDark),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRationaleItem(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.primaryOrange.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppTheme.primaryOrange, size: 24),
        ),
        const SizedBox(height: 8),
        Text(label, style: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primaryDark)),
      ],
    );
  }

  Widget _buildPaletteCard() {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('PALETTE', style: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.grey.shade600, letterSpacing: 1)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildColorCircle(AppTheme.primaryOrange, '#F48C25'),
              _buildColorCircle(AppTheme.primaryDark, '#1C1C1C'),
              _buildColorCircle(AppTheme.white, '#FFFFFF', border: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColorCircle(Color color, String hex, {bool border = false}) {
    return Column(
      children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: border ? Border.all(color: Colors.grey.shade300) : null,
          ),
        ),
        const SizedBox(height: 8),
        Text(hex, style: GoogleFonts.lexend(fontSize: 8, fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _buildTypographyCard() {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('TYPOGRAPHY', style: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.grey.shade600, letterSpacing: 1)),
          const SizedBox(height: 8),
          Text('Lexend Rounded', style: GoogleFonts.lexend(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.primaryDark)),
          const SizedBox(height: 4),
          Text('Aa Bb Cc Dd Ee Ff', style: GoogleFonts.lexend(fontSize: 14, color: AppTheme.primaryDark)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.lexend(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: Colors.grey.shade600,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildPreviewCards() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 180,
            decoration: BoxDecoration(
              color: AppTheme.primaryDark,
              borderRadius: BorderRadius.circular(24),
              image: const DecorationImage(
                image: NetworkImage('https://picsum.photos/seed/run/500/500'), // Runner placeholder
                fit: BoxFit.cover,
                opacity: 0.5,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            height: 180,
            decoration: BoxDecoration(
              color: AppTheme.primaryDark,
              borderRadius: BorderRadius.circular(24),
              image: const DecorationImage(
                image: NetworkImage('https://picsum.photos/seed/earn/500/500'), // Runner placeholder
                fit: BoxFit.cover,
                opacity: 0.8,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryOrange.withValues(alpha: 0.5),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: GlassContainer(
        height: 60,
        borderRadius: 30,
        color: AppTheme.primaryOrange.withValues(alpha: 0.4),
        borderColor: AppTheme.primaryOrange.withValues(alpha: 0.8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Select Concept', style: GoogleFonts.lexend(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.primaryDark)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: AppTheme.primaryOrange,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, size: 16, color: Colors.white),
            )
          ],
        ),
      ),
    );
  }
}
