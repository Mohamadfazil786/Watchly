import '../repositories/ai_repository.dart';

class MockAiRepository implements AiRepository {
  @override
  Future<String> getPersonalizedRecommendations({
    required List<String> favoriteGenres,
    required List<String> watchedMovieTitles,
    required List<String> highlyRatedMovies,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1200));
    final genreStr = favoriteGenres.take(3).join(', ');
    return '''Based on your love of **$genreStr** and your highly rated films, here are my top picks for you:

🎬 **Arrival (2016)** — Denis Villeneuve's cerebral sci-fi masterpiece about language and time. If you loved Interstellar, this is essential.

🎬 **Blade Runner 2049 (2017)** — Visually stunning neo-noir that rewards patience. Villeneuve again proving he's the modern master of thoughtful blockbuster cinema.

🎬 **Annihilation (2018)** — Alex Garland's unsettling sci-fi horror that burrowed deep into my brain. Not for everyone, perfect for you.

🎬 **Ex Machina (2014)** — Intimate, claustrophobic AI thriller that asks profound questions about consciousness and manipulation.

🎬 **Prisoners (2013)** — Hugh Jackman and Jake Gyllenhaal in a harrowing thriller about a father's desperate search. One of the best of the decade.

These films share the thematic complexity and visual ambition of your favourites. Enjoy! 🍿''';
  }

  @override
  Future<String> getMoodBasedRecommendations(String moodPrompt) async {
    await Future.delayed(const Duration(milliseconds: 1500));
    final prompt = moodPrompt.toLowerCase();

    if (prompt.contains('funny') || prompt.contains('comedy') || prompt.contains('laugh')) {
      return '''Here are some films to make you laugh out loud 😂

🎬 **The Grand Budapest Hotel (2014)** — Wes Anderson's absurdly delightful caper. Visually gorgeous and genuinely funny.

🎬 **What We Do in the Shadows (2014)** — Taika Waititi's hilarious mockumentary about vampire flatmates. A cult classic.

🎬 **Game Night (2018)** — Surprisingly clever comedy thriller. Great cast, lots of fun twists.

🎬 **Palm Springs (2020)** — A fresh, charming time-loop rom-com with Andy Samberg at his best.''';
    }

    if (prompt.contains('sci-fi') || prompt.contains('mind') || prompt.contains('mind-blowing')) {
      return '''Mind-bending sci-fi to blow your mind 🚀🧠

🎬 **Arrival (2016)** — Redefines the alien contact genre with language, time, and grief as its core.

🎬 **Everything Everywhere All at Once (2022)** — A multiverse film that's also the most human film you'll ever see.

🎬 **Coherence (2013)** — A low-budget gem that keeps escalating in brilliance. Watch it blind.

🎬 **Possessor (2020)** — Brandon Cronenberg's twisted corporate horror/sci-fi. Deeply unsettling.''';
    }

    if (prompt.contains('short') || prompt.contains('series') || prompt.contains('tv')) {
      return '''Short, bingeable TV series you can finish quickly 📺

📺 **Miniseries: Chernobyl (2019)** — 5 episodes. HBO's devastating, gripping account of the nuclear disaster.

📺 **The Haunting of Hill House (2018)** — 10 episodes of the best horror TV ever made.

📺 **Fleabag (2016-2019)** — 12 episodes total. Phoebe Waller-Bridge is a genius. Life-changing comedy.

📺 **Band of Brothers (2001)** — 10 episodes. The definitive WW2 TV experience. Still unmatched.''';
    }

    return '''Here are my recommendations for: "$moodPrompt" 🎬

🎬 **Hereditary (2018)** — Deeply disturbing family horror that lingers for weeks.

🎬 **Midsommar (2019)** — Ari Aster's folk horror masterpiece set in perpetual daylight.

🎬 **The Father (2020)** — Anthony Hopkins delivers perhaps the greatest performance ever filmed.

🎬 **Aftersun (2022)** — Quiet, devastating debut film that rewards attention and breaks your heart.''';
  }

  @override
  Future<String> compareMedia(String titleA, String titleB) async {
    await Future.delayed(const Duration(milliseconds: 2000));
    return '''## $titleA vs $titleB

**⚡ Story & Screenplay**
Both films operate as cerebral blockbusters but take very different approaches. *$titleA* favors intricate, layered plotting that demands active engagement, while *$titleB* leans into emotional resonance over structural complexity. Edge: *$titleA* for ambition, *$titleB* for emotional payoff.

**🎭 Acting & Performances**  
Both feature career-best turns from their leads. *$titleA*'s ensemble is exceptional — every actor elevates the material. *$titleB* relies more on a singular central performance that is genuinely extraordinary. Edge: **Draw** — both are superlative.

**🎨 Visuals & Cinematography**
*$titleA* and *$titleB* both boast stunning cinematography. *$titleA* features more kinetic, technically complex set-pieces, while *$titleB* opts for grander, more majestic scale. Edge: *$titleB* for sheer visual grandeur.

**⏱️ Pacing**
*$titleA* is relentlessly propulsive — it rarely pauses for breath. *$titleB* is more meditative, with quieter sections that divide audiences. If you want momentum, choose *$titleA*. If you want contemplation, choose *$titleB*.

**🏆 Overall Recommendation**
> Both are **essential cinema**. If forced to choose: watch *$titleA* on a Friday night for maximum excitement, and *$titleB* on a Sunday afternoon when you want to feel something profound.

**Verdict: It's a tie. You need both.** 🎬''';
  }

  @override
  Future<String> generateReviewDraft(String movieTitle, double rating) async {
    await Future.delayed(const Duration(milliseconds: 1800));
    if (rating >= 9.0) {
      return '$movieTitle is a genuine masterpiece — the kind of film that reminds you why cinema exists. From the first frame to the last, it operates at a level of craft and emotional intelligence that is genuinely rare. The performances are extraordinary, the direction is assured and visionary, and the script manages to be both deeply personal and universally resonant. I left the cinema changed. Films like this don\'t come along often — treasure it.';
    } else if (rating >= 7.5) {
      return '$movieTitle is a very solid film that delivers on most of its promises. The standout elements — particularly the central performances and visual storytelling — elevate it above standard genre fare. There are moments of genuine brilliance scattered throughout, even if the pacing occasionally stumbles in the second act. Definitely worth your time, and likely worth revisiting.';
    } else if (rating >= 6.0) {
      return '$movieTitle is a competent, serviceable film that falls just short of greatness. There is clear ambition here, and several sequences genuinely impress, but the overall execution is uneven. The stronger elements are undercut by a script that doesn\'t fully trust its audience, and a final act that doesn\'t quite land. Worth watching once, but unlikely to stick with you long term.';
    } else if (rating >= 4.0) {
      return '$movieTitle is a disappointment. Despite some interesting ideas in the premise and a few flashes of potential, the film squanders its opportunities at nearly every turn. The characters feel underwritten, the pacing drags, and the payoffs rarely justify the build-up. It\'s not a disaster, but it\'s hard to recommend when so many better options exist.';
    } else {
      return '$movieTitle is a frustrating failure. There\'s something deeply broken in the DNA of this film — whether it\'s the incoherent script, the lifeless direction, or the wasted performances, nothing comes together. The result is a joyless experience that tests your patience from start to finish. A rare case where I actively regret the runtime.';
    }
  }
}
