import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';

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
      body: Container(
        color: const Color(0xFFF8F9FA),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios,
                          color: Color(0xFF6B7280), size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text('My Rewards',
                        style: GoogleFonts.outfit(
                            color: const Color(0xFF1F2937),
                            fontSize: 22,
                            fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('${_tokens.length} rewards',
                          style: GoogleFonts.outfit(
                              color: const Color(0xFF10B981),
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: Color(0xFFFF6B00)))
                    : _tokens.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.card_giftcard,
                                    color: Colors.grey[300], size: 64),
                                const SizedBox(height: 12),
                                Text('No rewards yet',
                                    style: GoogleFonts.outfit(
                                        color: Colors.grey[400], fontSize: 16)),
                                const SizedBox(height: 8),
                                Text('Accept challenges to earn rewards!',
                                    style: GoogleFonts.outfit(
                                        color: Colors.grey[400], fontSize: 13)),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadTokens,
                            color: const Color(0xFFFF6B00),
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              itemCount: _tokens.length,
                              itemBuilder: (ctx, i) =>
                                  _rewardCard(_tokens[i]),
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _rewardCard(Map<String, dynamic> token) {
    final challenge = token['challenge'] ?? 'Challenge';
    final price = token['price'] ?? 'Reward';
    final company = token['companyName'] ?? 'Unknown';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
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
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFFBBC05).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.card_giftcard,
                color: Color(0xFFFBBC05), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(challenge,
                    style: GoogleFonts.outfit(
                        color: const Color(0xFF1F2937),
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(company,
                        style: GoogleFonts.outfit(
                            color: const Color(0xFF6B7280), fontSize: 12)),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(price,
                          style: GoogleFonts.outfit(
                              color: const Color(0xFF10B981),
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
