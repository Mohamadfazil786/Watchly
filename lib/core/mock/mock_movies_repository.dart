import '../models/movie_model.dart';
import '../repositories/movies_repository.dart';

class MockMoviesRepository implements MoviesRepository {
  static final List<MovieModel> _movies = [
    MovieModel(
      id: '27205',
      title: 'Inception',
      posterPath: '/9gk7adHYeDvHkCSEqAvQNLV5Uge.jpg',
      backdropPath: '/s3TBrRGB1iav7gFOCNx3H31MoES.jpg',
      overview:
          'Cobb, a skilled thief who commits corporate espionage by infiltrating the subconscious of his targets is offered a chance to regain his old life as payment for a task considered to be impossible.',
      releaseDate: '2010-07-16',
      rating: 8.4,
      ratingCount: 35000,
      popularity: 98.7,
      runtime: 148,
      genres: ['Action', 'Sci-Fi', 'Thriller'],
      director: 'Christopher Nolan',
      trailerUrl: 'YoHD9XEInc0',
      cast: [
        CastMember(name: 'Leonardo DiCaprio', character: 'Cobb', profilePath: '/wo2hJpn04vbtmh0B9utCFdsQhxM.jpg'),
        CastMember(name: 'Joseph Gordon-Levitt', character: 'Arthur', profilePath: '/z1RNFXg9SBpbBHMRN5K0jY1P4Oc.jpg'),
        CastMember(name: 'Elliot Page', character: 'Ariadne', profilePath: '/meXrFhF0b0sLBUxWtCeWLqYn9tO.jpg'),
        CastMember(name: 'Tom Hardy', character: 'Eames', profilePath: '/d81K0RH8UX7tZj49tZaQhZ9ewH.jpg'),
      ],
    ),
    MovieModel(
      id: '157336',
      title: 'Interstellar',
      posterPath: '/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg',
      backdropPath: '/pbrkL804c8yAv3zBZR4QPEafpAR.jpg',
      overview:
          'The adventures of a group of explorers who make use of a newly discovered wormhole to surpass the limitations on human space travel and conquer the vast distances involved in an interstellar voyage.',
      releaseDate: '2014-11-07',
      rating: 8.6,
      ratingCount: 41200,
      popularity: 120.4,
      runtime: 169,
      genres: ['Adventure', 'Drama', 'Sci-Fi'],
      director: 'Christopher Nolan',
      trailerUrl: 'zSWdZVtXT7E',
      cast: [
        CastMember(name: 'Matthew McConaughey', character: 'Cooper', profilePath: '/wJiGedOCZhwMx9DezY8uwbNxmAY.jpg'),
        CastMember(name: 'Anne Hathaway', character: 'Brand', profilePath: '/tLelKoPNiyJCSEJAnGPMnMTOeBp.jpg'),
        CastMember(name: 'Jessica Chastain', character: 'Murph', profilePath: '/sQa2KMEHl6sBX7HKQXm0EWyXuB8.jpg'),
      ],
    ),
    MovieModel(
      id: '438631',
      title: 'Dune',
      posterPath: '/d5NXSklpcvkCmCWfTMC5NVJIUiF.jpg',
      backdropPath: '/jYEW5xZkZk2WTrdbMGAPFuBqbDc.jpg',
      overview:
          'Paul Atreides, a brilliant and gifted young man born into a great destiny beyond his understanding, must travel to the most dangerous planet in the universe to ensure the future of his family and his people.',
      releaseDate: '2021-09-15',
      rating: 7.8,
      ratingCount: 28500,
      popularity: 87.3,
      runtime: 155,
      genres: ['Adventure', 'Drama', 'Sci-Fi'],
      director: 'Denis Villeneuve',
      trailerUrl: 'n9xhJrPXop4',
      cast: [
        CastMember(name: 'Timothée Chalamet', character: 'Paul Atreides', profilePath: '/BE2sdjpgsa2rNTFa66f7upkaOP.jpg'),
        CastMember(name: 'Zendaya', character: 'Chani', profilePath: '/6eFl1FNBSpDoADq8yzhGorQwOOm.jpg'),
        CastMember(name: 'Oscar Isaac', character: 'Duke Leto', profilePath: '/dW5U5yrIIPmMjRThR9KT2xH6nTz.jpg'),
      ],
    ),
    MovieModel(
      id: '496243',
      title: 'Parasite',
      posterPath: '/7IiTTgloROVKhWhzoXebK9joJeU.jpg',
      backdropPath: '/TU9NIjwzjoKPwQHoHshkFcQUCG.jpg',
      overview:
          'All unemployed, Ki-taek\'s family takes peculiar interest in the wealthy and glamorous Park family and the son starts to see them as a link to his own success.',
      releaseDate: '2019-05-30',
      rating: 8.5,
      ratingCount: 29400,
      popularity: 95.1,
      runtime: 132,
      genres: ['Comedy', 'Drama', 'Thriller'],
      director: 'Bong Joon-ho',
      trailerUrl: '5xH0HfJHsaY',
      cast: [
        CastMember(name: 'Song Kang-ho', character: 'Ki-taek', profilePath: '/1fFb7wWJkHjOJVQrJCiKANfPMOd.jpg'),
        CastMember(name: 'Lee Sun-kyun', character: 'Park Dong-ik', profilePath: '/zxDVJPUEXqAlYnT8FPrWN1KGWKQ.jpg'),
      ],
    ),
    MovieModel(
      id: '539681',
      title: 'Thor: Love and Thunder',
      posterPath: '/pIkRyD18kl4FhoCNQuWxWu5cBLM.jpg',
      backdropPath: '/p1F51Lvj3sMopG948F5HsBbl43C.jpg',
      overview:
          'Thor enlists the help of Valkyrie, Korg and ex-girlfriend Jane Foster to fight Gorr the God Butcher, who intends to make the gods extinct.',
      releaseDate: '2022-07-08',
      rating: 6.3,
      ratingCount: 19200,
      popularity: 71.8,
      runtime: 119,
      genres: ['Action', 'Adventure', 'Comedy'],
      director: 'Taika Waititi',
      trailerUrl: 'Go8nTmfrQd8',
      cast: [
        CastMember(name: 'Chris Hemsworth', character: 'Thor', profilePath: '/jpurJ9jAcLCYjgHHfYF32m3zJYm.jpg'),
        CastMember(name: 'Natalie Portman', character: 'Jane Foster', profilePath: '/s0HdEcb7bMjlyH0XBtXJ6pR1k5m.jpg'),
      ],
    ),
    MovieModel(
      id: '594767',
      title: 'Shang-Chi',
      posterPath: '/1BIoJGKbXjdFDAqUEiA2VHqkMXd.jpg',
      backdropPath: '/cinER0ESG0eJ49kXlExM0MEWGxW.jpg',
      overview:
          'Shang-Chi must confront the past he thought he left behind when he is drawn into the web of the mysterious Ten Rings organization.',
      releaseDate: '2021-09-03',
      rating: 7.4,
      ratingCount: 21600,
      popularity: 82.5,
      runtime: 132,
      genres: ['Action', 'Adventure', 'Fantasy'],
      director: 'Destin Daniel Cretton',
      trailerUrl: '8YjFbMbfXaQ',
      cast: [
        CastMember(name: 'Simu Liu', character: 'Shang-Chi', profilePath: '/iEBnlX6eQnc3E9gKRMBcHCsWoLi.jpg'),
        CastMember(name: 'Tony Leung', character: 'Xu Wenwu', profilePath: '/lYqC8Amj4owX05xQg5Yo7uUHgaJ.jpg'),
      ],
    ),
    MovieModel(
      id: '76600',
      title: 'Avatar: The Way of Water',
      posterPath: '/t6HIqrRAclMCA60NsSmeqe9nus9.jpg',
      backdropPath: '/s16H6tpK2utvwpatzGAsADX+7y65.jpg',
      overview:
          'Jake Sully lives with his newfound family formed on the extrasolar moon Pandora. Once a familiar threat returns to finish what was previously started, Jake must work with Neytiri and the army of the Na\'vi race.',
      releaseDate: '2022-12-16',
      rating: 7.6,
      ratingCount: 32100,
      popularity: 110.2,
      runtime: 192,
      genres: ['Action', 'Adventure', 'Sci-Fi'],
      director: 'James Cameron',
      trailerUrl: 'd9MyW72ELq0',
      cast: [
        CastMember(name: 'Sam Worthington', character: 'Jake Sully', profilePath: '/mflBcox36s9ZPbsZUqsOzIjOZ3m.jpg'),
        CastMember(name: 'Zoe Saldana', character: 'Neytiri', profilePath: '/iQFcwSGbZXMkeyKrxbPnwnRo5fl.jpg'),
      ],
    ),
    MovieModel(
      id: '872585',
      title: 'Oppenheimer',
      posterPath: '/8Gxv8gSFCU0XGDykEGv7zR1n2ua.jpg',
      backdropPath: '/rLb2cwF3Pazuxaj0sRXQ037tGI1.jpg',
      overview:
          'The story of J. Robert Oppenheimer\'s role in the development of the atomic bomb during World War II.',
      releaseDate: '2023-07-19',
      rating: 8.3,
      ratingCount: 45000,
      popularity: 105.8,
      runtime: 180,
      genres: ['Biography', 'Drama', 'History'],
      director: 'Christopher Nolan',
      trailerUrl: 'uYPbbksJxIg',
      cast: [
        CastMember(name: 'Cillian Murphy', character: 'J. Robert Oppenheimer', profilePath: '/dm6V24NjjvjMiCtbMkc8Y2WPm2e.jpg'),
        CastMember(name: 'Emily Blunt', character: 'Katherine Oppenheimer', profilePath: '/cyFa3pADEjCIsT6JDnRSQM7ZHEY.jpg'),
        CastMember(name: 'Robert Downey Jr.', character: 'Lewis Strauss', profilePath: '/5qHNjhtjMD4YWH3UP0rm4tKwxCL.jpg'),
      ],
    ),
  ];

  static final List<MovieModel> _tvShows = [
    MovieModel(
      id: 'tv_1396',
      title: 'Breaking Bad',
      posterPath: '/ggFHVNu6YYI5L9pCfOacjizRGt.jpg',
      backdropPath: '/tsRy63Mu5cu8etL1X7ZLyf7UP1M.jpg',
      overview:
          'A high school chemistry teacher diagnosed with inoperable lung cancer turns to manufacturing and selling methamphetamine in order to secure his family\'s future.',
      releaseDate: '2008-01-20',
      rating: 9.5,
      ratingCount: 55000,
      popularity: 148.3,
      runtime: 47,
      genres: ['Crime', 'Drama', 'Thriller'],
      director: 'Vince Gilligan',
      trailerUrl: 'HhesaQXLuRY',
      isTvShow: true,
      cast: [
        CastMember(name: 'Bryan Cranston', character: 'Walter White', profilePath: '/7Jahy5LZX2Fo8fGJltMreAI49hC.jpg'),
        CastMember(name: 'Aaron Paul', character: 'Jesse Pinkman', profilePath: '/bRqLUjMfFBxqWPrZZAIHMbLBGAg.jpg'),
      ],
    ),
    MovieModel(
      id: 'tv_66732',
      title: 'Stranger Things',
      posterPath: '/49WJfeN0moxb9IPfGn8AIqMGskD.jpg',
      backdropPath: '/rcA17r3hfHtRki0Dwf7qi7Zgber.jpg',
      overview:
          'When a young boy vanishes, a small town uncovers a mystery involving secret experiments, terrifying supernatural forces and one strange little girl.',
      releaseDate: '2016-07-15',
      rating: 8.7,
      ratingCount: 38400,
      popularity: 133.5,
      runtime: 51,
      genres: ['Drama', 'Fantasy', 'Horror'],
      director: 'The Duffer Brothers',
      trailerUrl: 'b9EkMc79ZSU',
      isTvShow: true,
      cast: [
        CastMember(name: 'Millie Bobby Brown', character: 'Eleven', profilePath: '/9UxuMCqcCIXcqfhPEf1hDy3yCIy.jpg'),
        CastMember(name: 'Finn Wolfhard', character: 'Mike Wheeler', profilePath: '/5b4qWSnXoOgEOJHKqj4Y9GKQO0T.jpg'),
      ],
    ),
    MovieModel(
      id: 'tv_60574',
      title: 'Peaky Blinders',
      posterPath: '/vUUqzWa2LnHIVqkaKVlVGkPmKlU.jpg',
      backdropPath: '/mqqsRnSBMWBp7Cz8xNVIxRlRbVe.jpg',
      overview:
          'A gangster family epic set in 1919 Birmingham, England; centered on a gang who sew razor blades in the peaks of their caps, and their fierce boss Tommy Shelby.',
      releaseDate: '2013-09-12',
      rating: 8.8,
      ratingCount: 29700,
      popularity: 91.4,
      runtime: 60,
      genres: ['Crime', 'Drama'],
      director: 'Steven Knight',
      trailerUrl: 'oVzVdvGIC7U',
      isTvShow: true,
      cast: [
        CastMember(name: 'Cillian Murphy', character: 'Thomas Shelby', profilePath: '/dm6V24NjjvjMiCtbMkc8Y2WPm2e.jpg'),
        CastMember(name: 'Paul Anderson', character: 'Arthur Shelby', profilePath: '/ibiSEzKLzibhgC8MIfEIDFWpnqj.jpg'),
      ],
    ),
    MovieModel(
      id: 'tv_94997',
      title: 'House of the Dragon',
      posterPath: '/z2yahl2uefxDCl0nogcRBstwruJ.jpg',
      backdropPath: '/suopoADq0k8YZr4dQXcU6pToj6s.jpg',
      overview:
          'The story of House Targaryen set 200 years before the events of Game of Thrones.',
      releaseDate: '2022-08-21',
      rating: 8.4,
      ratingCount: 33800,
      popularity: 127.9,
      runtime: 60,
      genres: ['Action', 'Adventure', 'Drama'],
      director: 'Ryan Condal',
      trailerUrl: 'DotnJ7tTA34',
      isTvShow: true,
      cast: [
        CastMember(name: 'Paddy Considine', character: 'King Viserys I', profilePath: '/3MIYfDKCq6jm60BgxqBXKqkiMm6.jpg'),
        CastMember(name: 'Matt Smith', character: 'Prince Daemon', profilePath: '/bXsQPFgQWQkZfBwJzEnJOKDiuaF.jpg'),
      ],
    ),
  ];

  @override
  Future<List<MovieModel>> searchMovies(String query) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final q = query.toLowerCase();
    return _movies.where((m) => m.title.toLowerCase().contains(q)).toList();
  }

  @override
  Future<List<MovieModel>> searchTvShows(String query) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final q = query.toLowerCase();
    return _tvShows.where((m) => m.title.toLowerCase().contains(q)).toList();
  }

  @override
  Future<MovieModel> getMovieDetails(String movieId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _movies.firstWhere((m) => m.id == movieId, orElse: () => _movies[0]);
  }

  @override
  Future<MovieModel> getTvShowDetails(String tvId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _tvShows.firstWhere((m) => m.id == tvId, orElse: () => _tvShows[0]);
  }

  @override
  Future<List<MovieModel>> getTrendingMovies() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _movies;
  }

  @override
  Future<List<MovieModel>> getPopularTvShows() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _tvShows;
  }

  @override
  Future<List<MovieModel>> getNewReleases() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _movies.where((m) => (int.tryParse(m.releaseDate.split('-').first) ?? 0) >= 2022).toList();
  }

  @override
  Future<List<MovieModel>> getSimilarMovies(String movieId, {bool isTv = false}) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final list = isTv ? _tvShows : _movies;
    return list.where((m) => m.id != movieId).take(6).toList();
  }

  @override
  Future<List<MovieModel>> getRecommendedMovies(String movieId, {bool isTv = false}) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final list = isTv ? _tvShows : _movies;
    return list.reversed.where((m) => m.id != movieId).take(6).toList();
  }

  @override
  Future<List<CastMember>> getMediaCast(String mediaId, {bool isTv = false}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final list = isTv ? _tvShows : _movies;
    try {
      return list.firstWhere((m) => m.id == mediaId).cast;
    } catch (_) {
      return [];
    }
  }

  @override
  Future<String> getMediaTrailer(String mediaId, {bool isTv = false}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final list = isTv ? _tvShows : _movies;
    try {
      return list.firstWhere((m) => m.id == mediaId).trailerUrl;
    } catch (_) {
      return '';
    }
  }
}
