import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/providers.dart';

class AiScreen extends ConsumerStatefulWidget {
  const AiScreen({super.key});

  @override
  ConsumerState<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends ConsumerState<AiScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mood Search state
  final _moodController = TextEditingController();
  String _moodResponse = '';
  bool _isLoadingMood = false;

  // Comparison state
  final _compareAController = TextEditingController(text: 'Dune');
  final _compareBController = TextEditingController(text: 'Interstellar');
  String _compareResponse = '';
  bool _isLoadingCompare = false;

  // Personalized Recommendation state
  String _recommendationsResponse = '';
  bool _isLoadingRecs = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _moodController.dispose();
    _compareAController.dispose();
    _compareBController.dispose();
    super.dispose();
  }

  Future<void> _fetchPersonalizedRecommendations() async {
    setState(() {
      _isLoadingRecs = true;
      _recommendationsResponse = '';
    });

    try {
      final user = ref.read(currentUserProvider);
      final aiRepo = ref.read(aiRepositoryProvider);

      final favoriteGenres = user?.favoriteGenres ?? ['Sci-Fi', 'Thriller', 'Drama'];
      // Fetch mock topMovies or watched list
      final watchedTitles = ['Inception', 'Interstellar', 'The Dark Knight'];
      final highlyRated = ['Inception (10/10)', 'Interstellar (9.5/10)'];

      final response = await aiRepo.getPersonalizedRecommendations(
        favoriteGenres: favoriteGenres,
        watchedMovieTitles: watchedTitles,
        highlyRatedMovies: highlyRated,
      );

      setState(() {
        _recommendationsResponse = response;
      });
    } catch (e) {
      setState(() {
        _recommendationsResponse = 'Failed to load recommendations: $e';
      });
    } finally {
      setState(() {
        _isLoadingRecs = false;
      });
    }
  }

  Future<void> _fetchMoodRecommendations() async {
    final query = _moodController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoadingMood = true;
      _moodResponse = '';
    });

    try {
      final aiRepo = ref.read(aiRepositoryProvider);
      final response = await aiRepo.getMoodBasedRecommendations(query);
      setState(() {
        _moodResponse = response;
      });
    } catch (e) {
      setState(() {
        _moodResponse = 'Failed to load mood search results: $e';
      });
    } finally {
      setState(() {
        _isLoadingMood = false;
      });
    }
  }

  Future<void> _fetchComparison() async {
    final titleA = _compareAController.text.trim();
    final titleB = _compareBController.text.trim();
    if (titleA.isEmpty || titleB.isEmpty) return;

    setState(() {
      _isLoadingCompare = true;
      _compareResponse = '';
    });

    try {
      final aiRepo = ref.read(aiRepositoryProvider);
      final response = await aiRepo.compareMedia(titleA, titleB);
      setState(() {
        _compareResponse = response;
      });
    } catch (e) {
      setState(() {
        _compareResponse = 'Failed to compare films: $e';
      });
    } finally {
      setState(() {
        _isLoadingCompare = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = context.bg;
    final headerBg = context.surface;
    final headerBorder = context.border;
    final textColor = context.textPrimary;
    final subColor = context.textSecondary;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gorgeous gradient AI header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              decoration: BoxDecoration(
                color: headerBg,
                border: Border(bottom: BorderSide(color: headerBorder)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE50914), Color(0xFFFF9233)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CineSphere AI',
                        style: GoogleFonts.outfit(
                          color: textColor,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'AI-powered recommendations & insights',
                        style: GoogleFonts.inter(
                          color: subColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Tab bar
            TabBar(
              controller: _tabController,
              labelColor: const Color(0xFFE50914),
              unselectedLabelColor: subColor,
              indicatorColor: const Color(0xFFE50914),
              indicatorWeight: 2,
              labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13),
              tabs: const [
                Tab(text: 'Personalized'),
                Tab(text: 'Mood Search'),
                Tab(text: 'Compare'),
              ],
            ),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPersonalizedTab(isDark, textColor, subColor),
                  _buildMoodTab(isDark, textColor, subColor),
                  _buildCompareTab(isDark, textColor, subColor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Personalized Tab ──────────────────────────────────────────────────────
  Widget _buildPersonalizedTab(bool isDark, Color textColor, Color subColor) {
    final cardBg = context.surface;
    final borderCol = context.border;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderCol),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tailored for You',
                  style: GoogleFonts.outfit(color: textColor, fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  'Let CineSphere AI scan your rating history, favorite genres, and watchlist items to generate tailored recommendations.',
                  style: GoogleFonts.inter(color: context.textSecondary, fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoadingRecs ? null : _fetchPersonalizedRecommendations,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE50914),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoadingRecs
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text('Generate My Recommendations', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (_isLoadingRecs)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40.0),
                child: CircularProgressIndicator(color: Color(0xFFE50914)),
              ),
            )
          else if (_recommendationsResponse.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderCol),
              ),
              child: _renderRichText(_recommendationsResponse, isDark, textColor),
            ),
        ],
      ),
    );
  }

  // ─── Mood Tab ──────────────────────────────────────────────────────────────
  Widget _buildMoodTab(bool isDark, Color textColor, Color subColor) {
    final cardBg = context.surface;
    final borderCol = context.border;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What are you in the mood for?',
            style: GoogleFonts.outfit(color: textColor, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 4),
          Text(
            'Describe your perfect film in your own words (e.g., "mind-bending thriller" or "cozy funny comedy")',
            style: GoogleFonts.inter(color: subColor, fontSize: 12),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _moodController,
            style: GoogleFonts.inter(color: textColor, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Describe your vibe, mood, or context...',
              hintStyle: GoogleFonts.inter(color: subColor),
              suffixIcon: IconButton(
                icon: const Icon(Icons.send_rounded, color: Color(0xFFE50914)),
                onPressed: _isLoadingMood ? null : _fetchMoodRecommendations,
              ),
            ),
            onSubmitted: (_) => _isLoadingMood ? null : _fetchMoodRecommendations(),
          ),
          const SizedBox(height: 20),
          if (_isLoadingMood)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40.0),
                child: CircularProgressIndicator(color: Color(0xFFE50914)),
              ),
            )
          else if (_moodResponse.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderCol),
              ),
              child: _renderRichText(_moodResponse, isDark, textColor),
            ),
        ],
      ),
    );
  }

  // ─── Compare Tab ───────────────────────────────────────────────────────────
  Widget _buildCompareTab(bool isDark, Color textColor, Color subColor) {
    final cardBg = context.surface;
    final borderCol = context.border;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Compare Two Films',
            style: GoogleFonts.outfit(color: textColor, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 4),
          Text(
            'Let CineSphere AI break down script writing, acting, visual cinematography, and pacing.',
            style: GoogleFonts.inter(color: subColor, fontSize: 12),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _compareAController,
                  decoration: InputDecoration(
                    labelText: 'First Film',
                    labelStyle: TextStyle(color: subColor),
                  ),
                  style: GoogleFonts.inter(color: textColor, fontSize: 14),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('VS', style: TextStyle(color: Color(0xFFE50914), fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: TextField(
                  controller: _compareBController,
                  decoration: InputDecoration(
                    labelText: 'Second Film',
                    labelStyle: TextStyle(color: subColor),
                  ),
                  style: GoogleFonts.inter(color: textColor, fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoadingCompare ? null : _fetchComparison,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE50914),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoadingCompare
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text('Run AI Head-to-Head', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
          const SizedBox(height: 20),
          if (_isLoadingCompare)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40.0),
                child: CircularProgressIndicator(color: Color(0xFFE50914)),
              ),
            )
          else if (_compareResponse.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderCol),
              ),
              child: _renderRichText(_compareResponse, isDark, textColor),
            ),
        ],
      ),
    );
  }

  // ─── Markdown Rich Text Renderer ──────────────────────────────────────────
  Widget _renderRichText(String text, bool isDark, Color textColor) {
    final List<TextSpan> spans = [];
    final lines = text.split('\n');

    for (var line in lines) {
      if (line.startsWith('## ')) {
        spans.add(
          TextSpan(
            text: '\n${line.substring(3)}\n',
            style: GoogleFonts.outfit(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              height: 1.8,
            ),
          ),
        );
      } else if (line.startsWith('### ')) {
        spans.add(
          TextSpan(
            text: '\n${line.substring(4)}\n',
            style: GoogleFonts.outfit(
              color: context.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              height: 1.6,
            ),
          ),
        );
      } else if (line.startsWith('> ')) {
        spans.add(
          TextSpan(
            text: '\n"${line.substring(2)}"\n',
            style: GoogleFonts.inter(
              color: const Color(0xFFFF9233),
              fontSize: 14,
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
        );
      } else {
        // Parse bold **text** within line
        final parts = line.split('**');
        for (var i = 0; i < parts.length; i++) {
          final isBold = i % 2 == 1;
          spans.add(
            TextSpan(
              text: parts[i],
              style: GoogleFonts.inter(
                color: isBold
                    ? textColor
                    : (context.textPrimary),
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          );
        }
        spans.add(const TextSpan(text: '\n'));
      }
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }
}



