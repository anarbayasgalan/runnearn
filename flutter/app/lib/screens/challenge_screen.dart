import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';

class ChallengeScreen extends StatefulWidget {
  const ChallengeScreen({super.key});

  @override
  State<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen> {
  List<dynamic> _challenges = [];
  bool _loading = true;
  double _totalDistance = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final challenges = await ApiService.getChallenges();
      final myRewards = await ApiService.getMyRewards();
      
      // Create set of accepted challenge keys
      final acceptedKeys = myRewards.map((t) => '${t['companyName']}_${t['challenge']}').toSet();

      double total = 0;
      try {
        final distData = await ApiService.getTotalDistance();
        total = (distData['totalDistance'] ?? 0).toDouble();
      } catch (_) {
        // Not logged in or endpoint error — show 0
      }
      
      if (mounted) {
        setState(() {
          // Filter out challenges that are already accepted
          _challenges = challenges.where((t) {
            final key = '${t['companyName']}_${t['challenge']}';
            return !acceptedKeys.contains(key);
          }).toList();
          
          _totalDistance = total;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _acceptChallenge(int tokenId) async {
    try {
      final result = await ApiService.acceptChallenge(tokenId);
      if (!mounted) return;

      final desc = result['responseDesc'] ?? 'Challenge accepted!';
      final code = result['responseCode'] ?? 0;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(desc),
        backgroundColor: code == 0 ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
      ));

      if (code == 0) _loadData(); // refresh
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
        backgroundColor: const Color(0xFFEF4444),
      ));
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
                    Text('Challenges',
                        style: GoogleFonts.outfit(
                            color: const Color(0xFF1F2937),
                            fontSize: 22,
                            fontWeight: FontWeight.bold)),
                    const Spacer(),
                    // Total distance badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B00).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.directions_run,
                              color: Color(0xFFFF6B00), size: 14),
                          const SizedBox(width: 4),
                          Text('${_totalDistance.toStringAsFixed(1)} km',
                              style: GoogleFonts.outfit(
                                  color: const Color(0xFFFF6B00),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: Color(0xFFFF6B00)))
                    : _challenges.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.emoji_events,
                                    color: Colors.grey[300], size: 64),
                                const SizedBox(height: 12),
                                Text('No challenges available',
                                    style: GoogleFonts.outfit(
                                        color: Colors.grey[400], fontSize: 16)),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadData,
                            color: const Color(0xFFFF6B00),
                            child: ListView.builder(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24),
                              itemCount: _groupedChallenges.length,
                              itemBuilder: (ctx, i) =>
                                  _challengeCard(_groupedChallenges[i]),
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper to get grouped challenges
  List<Map<String, dynamic>> get _groupedChallenges {
    final Map<String, Map<String, dynamic>> groups = {};
    for (var t in _challenges) {
      final key = '${t['companyName']}_${t['challenge']}';
      if (!groups.containsKey(key)) {
        groups[key] = t;
      }
    }
    return groups.values.toList();
  }

  Widget _challengeCard(Map<String, dynamic> token) {
    final challenge = token['challenge'] ?? 'Challenge';
    final price = token['price'] ?? 'Reward';
    final company = token['companyName'] ?? 'Unknown';
    final tokenId = token['id'];
    final requiredDistance = (token['requiredDistance'] ?? 0).toDouble();
    final hasReq = requiredDistance > 0;
    final canAccept = !hasReq || _totalDistance >= requiredDistance;
    final progress = hasReq ? (_totalDistance / requiredDistance).clamp(0.0, 1.0) : 1.0;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF2E86DE).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.emoji_events,
                    color: Color(0xFF2E86DE), size: 22),
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

          // Distance progress bar
          if (hasReq) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Text(
                  '${_totalDistance.toStringAsFixed(1)} / ${requiredDistance.toStringAsFixed(1)} km',
                  style: GoogleFonts.outfit(
                      color: canAccept
                          ? const Color(0xFF10B981)
                          : const Color(0xFFFF6B00),
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Text(
                  canAccept ? '✅ Ready!' : '${(progress * 100).toStringAsFixed(0)}%',
                  style: GoogleFonts.outfit(
                      color: const Color(0xFF9CA3AF), fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: Colors.grey[100],
                valueColor: AlwaysStoppedAnimation(
                  canAccept ? const Color(0xFF10B981) : const Color(0xFFFF6B00),
                ),
              ),
            ),
          ],

          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: canAccept && tokenId != null
                  ? () => _acceptChallenge(tokenId)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: canAccept
                    ? const Color(0xFFFF6B00)
                    : Colors.grey[100],
                foregroundColor: canAccept ? Colors.white : Colors.grey[400],
                elevation: canAccept ? 2 : 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                canAccept ? 'Accept Challenge' : 'Keep Running!',
                style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ),
          ),

        ],
      ),
    );
  }
}
