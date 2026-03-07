import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../widgets/mesh_background.dart';
import '../widgets/glass_container.dart';
import '../theme.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<dynamic> _entries = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await ApiService.getLeaderboard();
    if (mounted) setState(() { _entries = data; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          const Positioned.fill(child: MeshBackground()),
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: GlassContainer(
                          width: 44, height: 44, borderRadius: 22,
                          padding: EdgeInsets.zero,
                          child: const Icon(Icons.arrow_back_ios_new,
                              color: AppTheme.primaryDark, size: 18),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text('Leaderboard',
                          style: GoogleFonts.lexend(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryDark)),
                    ],
                  ),
                ),

                // Subtitle
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Text('Top runners by tokens earned',
                      style: GoogleFonts.lexend(
                          fontSize: 13,
                          color: Colors.grey.shade600)),
                ),

                // List
                Expanded(
                  child: _loading
                      ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryOrange))
                      : _entries.isEmpty
                          ? Center(
                              child: Text('No data yet — complete challenges!',
                                  style: GoogleFonts.lexend(color: Colors.grey.shade500)))
                          : RefreshIndicator(
                              onRefresh: _load,
                              color: AppTheme.primaryOrange,
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: _entries.length,
                                itemBuilder: (context, index) {
                                  final e = _entries[index];
                                  final rank = e['rank'] as int;
                                  final name = (e['displayName'] as String).split('@').first;
                                  final count = e['tokenCount'];
                                  final isTop3 = rank <= 3;

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: GlassContainer(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                      borderRadius: 16,
                                      color: isTop3
                                          ? AppTheme.primaryOrange.withValues(alpha: 0.1)
                                          : Colors.white.withValues(alpha: 0.3),
                                      borderColor: isTop3
                                          ? AppTheme.primaryOrange.withValues(alpha: 0.4)
                                          : Colors.white.withValues(alpha: 0.5),
                                      child: Row(
                                        children: [
                                          // Rank badge
                                          Container(
                                            width: 40, height: 40,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: _rankColor(rank).withValues(alpha: 0.15),
                                            ),
                                            child: Center(
                                              child: rank <= 3
                                                  ? Text(_rankEmoji(rank),
                                                      style: const TextStyle(fontSize: 20))
                                                  : Text('#$rank',
                                                      style: GoogleFonts.lexend(
                                                          fontSize: 13,
                                                          fontWeight: FontWeight.bold,
                                                          color: AppTheme.primaryDark)),
                                            ),
                                          ),
                                          const SizedBox(width: 14),

                                          // Name
                                          Expanded(
                                            child: Text(name,
                                                style: GoogleFonts.lexend(
                                                    fontSize: 15,
                                                    fontWeight: isTop3
                                                        ? FontWeight.bold
                                                        : FontWeight.w500,
                                                    color: AppTheme.primaryDark),
                                                overflow: TextOverflow.ellipsis),
                                          ),

                                          // Token count
                                          Row(
                                            children: [
                                              const Icon(Icons.token_rounded,
                                                  color: AppTheme.primaryOrange, size: 18),
                                              const SizedBox(width: 4),
                                              Text('$count',
                                                  style: GoogleFonts.lexend(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                      color: AppTheme.primaryOrange)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
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

  String _rankEmoji(int rank) {
    switch (rank) {
      case 1: return '🥇';
      case 2: return '🥈';
      case 3: return '🥉';
      default: return '#$rank';
    }
  }

  Color _rankColor(int rank) {
    switch (rank) {
      case 1: return const Color(0xFFFFD700);
      case 2: return const Color(0xFFC0C0C0);
      case 3: return const Color(0xFFCD7F32);
      default: return AppTheme.primaryDark;
    }
  }
}
