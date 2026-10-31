import 'package:google_generative_ai/google_generative_ai.dart';
import '../config/app_config.dart';
import 'ai_repository.dart';

class GeminiAiRepository implements AiRepository {
  late final GenerativeModel _model;

  GeminiAiRepository() {
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: AppConfig.geminiApiKey,
    );
  }



  Future<String> _generate(String prompt) async {
    final content = [Content.text(prompt)];
    final response = await _model.generateContent(content);
    return response.text ?? 'No response generated.';
  }

  @override
  Future<String> getPersonalizedRecommendations({
    required List<String> favoriteGenres,
    required List<String> watchedMovieTitles,
    required List<String> highlyRatedMovies,
  }) async {
    final genreStr = favoriteGenres.take(5).join(', ');
    final watchedStr = watchedMovieTitles.take(10).join(', ');
    final ratedStr = highlyRatedMovies.take(5).join(', ');

    final prompt = '''
You are a world-class film critic and recommendation engine for a premium app called Watchly.

The user loves these genres: $genreStr.
They have watched: $watchedStr.
Their highest-rated films are: $ratedStr.

Recommend 5 films or TV shows they haven\'t mentioned. For each, give:
- The title and year in **bold**
- A one to two sentence explanation of why it fits their taste
- An emoji to match the tone

Keep the tone intelligent, warm, and cinephile-friendly. Format with clear line breaks between each recommendation.''';

    return _generate(prompt);
  }

  @override
  Future<String> getMoodBasedRecommendations(String moodPrompt) async {
    final prompt = '''
You are a film concierge for Watchly, a premium movie social app.

The user is in the mood for: "$moodPrompt"

Recommend 4 perfect films or TV series that match this mood. For each:
- Title and year in **bold**
- Platform availability if known (Netflix, HBO, etc.)
- A vivid one-sentence pitch that sells why this is the perfect pick right now
- An emoji for the vibe

Make the recommendations feel personal and exciting, not like a Wikipedia list.''';

    return _generate(prompt);
  }

  @override
  Future<String> compareMedia(String titleA, String titleB) async {
    final prompt = '''
You are a film critic for Watchly writing a head-to-head comparison between two works.

Compare **$titleA** vs **$titleB** across these dimensions:
1. **Story & Screenplay** — structure, originality, themes
2. **Acting & Performances** — standout roles, ensemble vs single lead
3. **Visuals & Cinematography** — visual language, color, framing
4. **Pacing & Tone** — rhythm, emotional beats, runtime efficiency
5. **Overall Verdict** — which to watch first and why

For each category, declare a winner (or a draw) with a brief 2-3 sentence justification.
End with an overall recommendation in a blockquote (> ) format.
Keep the tone of a sharp, witty critic who respects both films.''';

    return _generate(prompt);
  }

  @override
  Future<String> generateReviewDraft(String movieTitle, double rating) async {
    final ratingStr = rating.toStringAsFixed(1);
    String tone;
    if (rating >= 9.0) {
      tone = 'an absolute masterpiece — write with deep reverence, passion, and the sense that this film will be remembered forever';
    } else if (rating >= 7.5) {
      tone = 'a very strong film with some standout moments — write with genuine enthusiasm while noting one or two minor flaws';
    } else if (rating >= 6.0) {
      tone = 'a decent but uneven film — balanced, fair, acknowledging what works and what doesn\'t';
    } else if (rating >= 4.0) {
      tone = 'a disappointing film — honest but not cruel, noting what potential was wasted';
    } else {
      tone = 'a genuinely bad film — critically sharp but not mean-spirited, explain what fundamentally doesn\'t work';
    }

    final prompt = '''
You are writing a film review for Watchly, a premium movie-tracking social platform. Think Letterboxd meets The Guardian.

Film: **$movieTitle**
User Rating: $ratingStr / 10
Tone: $tone

Write a 3-5 sentence review in first person. It should:
- Start with a strong, memorable opening line
- Reference specific (realistic) craft elements: direction, score, performance, screenplay, or cinematography
- Match the tone and rating naturally
- End with a recommendation or closing thought
- Sound like a real cinephile wrote it, not an AI

Do NOT use generic phrases like "all in all" or "overall". Be specific and vivid.''';

    return _generate(prompt);
  }
}
