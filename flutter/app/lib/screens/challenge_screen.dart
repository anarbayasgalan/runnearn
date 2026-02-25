import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../widgets/glass_container.dart';
import '../widgets/mesh_background.dart';
import '../theme.dart';

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
                      Text('Challenges',
                          style: GoogleFonts.lexend(
                              color: AppTheme.primaryDark,
                              fontSize: 22,
                              fontWeight: FontWeight.bold)),
                      const Spacer(),
                      // Total distance badge
                      GlassContainer(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        borderRadius: 20,
                        color: AppTheme.primaryOrange.withValues(alpha: 0.2),
                        borderColor: AppTheme.primaryOrange.withValues(alpha: 0.4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.directions_run,
                                color: AppTheme.primaryOrange, size: 16),
                            const SizedBox(width: 6),
                            Text('${_totalDistance.toStringAsFixed(1)} km',
                                style: GoogleFonts.lexend(
                                    color: AppTheme.primaryOrange,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700)),
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
                              color: AppTheme.primaryOrange))
                      : _challenges.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.emoji_events,
                                      color: Colors.grey.withValues(alpha: 0.3), size: 64),
                                  const SizedBox(height: 12),
                                  Text('No challenges available',
                                      style: GoogleFonts.lexend(
                                          color: Colors.grey.shade600, fontSize: 16)),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _loadData,
                              color: AppTheme.primaryOrange,
                              child: ListView.builder(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                                itemCount: _groupedChallenges.length,
                                itemBuilder: (ctx, i) =>
                                    _challengeCard(_groupedChallenges[i]),
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

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassContainer(
        padding: const EdgeInsets.all(20),
        borderRadius: 24,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryDark.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.emoji_events,
                      color: AppTheme.primaryDark, size: 26),
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

            // Distance progress bar
            if (hasReq) ...[
              const SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    '${_totalDistance.toStringAsFixed(1)} / ${requiredDistance.toStringAsFixed(1)} km',
                    style: GoogleFonts.lexend(
                        color: canAccept
                            ? AppTheme.primaryOrange
                            : Colors.grey.shade600,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  Text(
                    canAccept ? '✅ Ready!' : '${(progress * 100).toStringAsFixed(0)}%',
                    style: GoogleFonts.lexend(
                        color: Colors.grey.shade500, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: AppTheme.primaryDark.withValues(alpha: 0.05),
                  valueColor: AlwaysStoppedAnimation(
                    canAccept ? AppTheme.primaryOrange : AppTheme.primaryDark.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  if (canAccept)
                    BoxShadow(
                      color: AppTheme.primaryOrange.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: canAccept && tokenId != null
                      ? () => _acceptChallenge(tokenId)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canAccept
                        ? AppTheme.primaryOrange
                        : Colors.white.withValues(alpha: 0.5),
                    foregroundColor: canAccept ? Colors.white : Colors.grey.shade500,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    canAccept ? 'Accept Challenge' : 'Keep Running!',
                    style: GoogleFonts.lexend(
                        fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
