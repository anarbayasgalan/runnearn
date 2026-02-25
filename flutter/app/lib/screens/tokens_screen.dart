import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../widgets/glass_container.dart';
import '../widgets/mesh_background.dart';
import '../theme.dart';

class TokensScreen extends StatefulWidget {
  const TokensScreen({super.key});

  @override
  State<TokensScreen> createState() => _TokensScreenState();
}

class _TokensScreenState extends State<TokensScreen> {
  List<dynamic> _tokens = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTokens();
  }

  Future<void> _loadTokens() async {
    try {
      final data = await ApiService.getMyRewards();
      if (mounted) setState(() { _tokens = data; _loading = false; });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Mesh Background
          const Positioned.fill(child: MeshBackground()),
          
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      GlassContainer(
                        width: 44,
                        height: 44,
                        borderRadius: 22,
                        padding: EdgeInsets.zero,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new,
                              color: AppTheme.primaryDark, size: 18),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text('My Rewards',
                          style: GoogleFonts.lexend(
                              color: AppTheme.primaryDark,
                              fontSize: 22,
                              fontWeight: FontWeight.bold)),
                      const Spacer(),
                      GlassContainer(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        borderRadius: 20,
                        color: AppTheme.primaryOrange.withValues(alpha: 0.2),
                        borderColor: AppTheme.primaryOrange.withValues(alpha: 0.4),
                        child: Text('${_tokens.length} rewards',
                            style: GoogleFonts.lexend(
                                color: AppTheme.primaryOrange,
                                fontSize: 13,
                                fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: _loading
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: AppTheme.primaryOrange))
                      : _tokens.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.card_giftcard,
                                      color: Colors.grey.withValues(alpha: 0.3), size: 64),
                                  const SizedBox(height: 12),
                                  Text('No rewards yet',
                                      style: GoogleFonts.lexend(
                                          color: Colors.grey.shade600, fontSize: 16)),
                                  const SizedBox(height: 8),
                                  Text('Accept challenges to earn rewards!',
                                      style: GoogleFonts.lexend(
                                          color: Colors.grey.shade500, fontSize: 13)),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _loadTokens,
                              color: AppTheme.primaryOrange,
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                                itemCount: _tokens.length,
                                itemBuilder: (ctx, i) =>
                                    _rewardCard(_tokens[i]),
                              ),
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _rewardCard(Map<String, dynamic> token) {
    final challenge = token['challenge'] ?? 'Challenge';
    final price = token['price'] ?? 'Reward';
    final company = token['companyName'] ?? 'Unknown';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassContainer(
        padding: const EdgeInsets.all(20),
        borderRadius: 24,
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppTheme.primaryOrange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.card_giftcard,
                  color: AppTheme.primaryOrange, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(challenge,
                      style: GoogleFonts.lexend(
                          color: AppTheme.primaryDark,
                          fontSize: 16,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(company,
                          style: GoogleFonts.lexend(
                              color: Colors.grey.shade600, fontSize: 13)),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryOrange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(price,
                            style: GoogleFonts.lexend(
                                color: AppTheme.primaryOrange,
                                fontSize: 12,
                                fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
