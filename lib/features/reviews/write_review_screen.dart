import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/providers.dart';
import '../../core/models/review_model.dart';
import '../../core/constants/app_constants.dart';

class WriteReviewScreen extends ConsumerStatefulWidget {
  final String mediaId;
  final String mediaTitle;
  final String mediaPoster;
  final String mediaType;

  const WriteReviewScreen({
    super.key,
    required this.mediaId,
    required this.mediaTitle,
    required this.mediaPoster,
    required this.mediaType,
  });

  @override
  ConsumerState<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends ConsumerState<WriteReviewScreen> {
  final _textController = TextEditingController();
  double _rating = 7.0; // Default rating (out of 10)
  bool _isGeneratingDraft = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  String _getRatingText(double rating) {
    if (rating >= 9.0) return '⭐ $rating/10 — Masterpiece 🏆';
    if (rating >= 7.5) return '⭐ $rating/10 — Very Good 👍';
    if (rating >= 6.0) return '⭐ $rating/10 — Good / Okay 🙂';
    if (rating >= 4.0) return '⭐ $rating/10 — Mediocre 😑';
    return '⭐ $rating/10 — Terrible 👎';
  }

  Future<void> _generateAiDraft() async {
    setState(() {
      _isGeneratingDraft = true;
    });

    try {
      final aiRepo = ref.read(aiRepositoryProvider);
      final draft = await aiRepo.generateReviewDraft(widget.mediaTitle, _rating);

      setState(() {
        _textController.text = draft;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate AI draft: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingDraft = false;
        });
      }
    }
  }

  Future<void> _submitReview() async {
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write some thoughts first!')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final user = ref.read(currentUserProvider);
      final review = ReviewModel(
        id: 'rev_${DateTime.now().millisecondsSinceEpoch}',
        userId: user?.uid ?? 'user_1',
        username: user?.username ?? 'alex_cinephile',
        userPhotoUrl: user?.photoUrl ?? '',
        mediaId: widget.mediaId,
        mediaTitle: widget.mediaTitle,
        mediaPoster: widget.mediaPoster,
        mediaType: widget.mediaType,
        rating: _rating,
        reviewText: _textController.text.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await ref.read(reviewsRepositoryProvider).writeReview(review);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Review published successfully!'),
            backgroundColor: Color(0xFF00C853),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to publish review: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final posterUrl = AppConstants.posterUrl(widget.mediaPoster);
    final bg = context.bg;
    final textColor = context.textPrimary;
    final subColor = context.textSecondary;
    final bodyTextColor = context.textPrimary;
    final cardBg = context.surface;
    final borderCol = context.border;
    final placeholderBg = context.surface2;
    final iconColor = context.textPrimary;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text('Log & Review', style: GoogleFonts.outfit(color: textColor, fontWeight: FontWeight.bold)),
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: iconColor),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_isSubmitting)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(color: Color(0xFFE50914), strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _submitReview,
              child: Text(
                'Publish',
                style: GoogleFonts.outfit(
                  color: const Color(0xFFE50914),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Movie Header Info
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: posterUrl.isNotEmpty
                      ? Image.network(
                          posterUrl,
                          width: 70,
                          height: 105,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 70,
                            height: 105,
                            color: placeholderBg,
                            child: Icon(Icons.movie_outlined, color: subColor),
                          ),
                        )
                      : Container(
                          width: 70,
                          height: 105,
                          color: placeholderBg,
                          child: Icon(Icons.movie_outlined, color: subColor),
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.mediaTitle,
                        style: GoogleFonts.outfit(
                          color: textColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.mediaType.toUpperCase(),
                        style: GoogleFonts.inter(
                          color: subColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Rating Selector
            Center(
              child: Column(
                children: [
                  Text(
                    'Your Rating',
                    style: GoogleFonts.outfit(
                      color: bodyTextColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getRatingText(_rating),
                    style: GoogleFonts.inter(
                      color: const Color(0xFFFF9233),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: const Color(0xFFE50914),
                      inactiveTrackColor: context.border,
                      thumbColor: const Color(0xFFE50914),
                      overlayColor: const Color(0xFFE50914).withValues(alpha: 0.2),
                      valueIndicatorColor: const Color(0xFFE50914),
                      valueIndicatorTextStyle: const TextStyle(color: Colors.white),
                    ),
                    child: Slider(
                      value: _rating,
                      min: 1.0,
                      max: 10.0,
                      divisions: 18, // Steps of 0.5
                      label: _rating.toString(),
                      onChanged: (val) {
                        setState(() {
                          _rating = val;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Review Input Field
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Write your review...',
                  style: GoogleFonts.outfit(
                    color: bodyTextColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // AI Draft Generator Button
                _isGeneratingDraft
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Color(0xFFE50914), strokeWidth: 1.5),
                      )
                    : TextButton.icon(
                        onPressed: _generateAiDraft,
                        icon: const Icon(Icons.auto_awesome_rounded, color: Color(0xFFFF9233), size: 16),
                        label: Text(
                          'AI Draft',
                          style: GoogleFonts.inter(
                            color: const Color(0xFFFF9233),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _textController,
              maxLines: 8,
              keyboardType: TextInputType.multiline,
              style: GoogleFonts.inter(color: textColor, fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Share your thoughts, review specific scenes, performances, direction, or cinematography...',
                hintStyle: GoogleFonts.inter(color: subColor, fontSize: 14),
                filled: true,
                fillColor: cardBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: borderCol),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFE50914), width: 1.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



