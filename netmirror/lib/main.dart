import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NetMirror',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFE50914),
          surface: Colors.black,
        ),
      ),
      home: const NetflixHomePage(),
    );
  }
}

class NetflixHomePage extends StatefulWidget {
  const NetflixHomePage({super.key});

  @override
  State<NetflixHomePage> createState() => _NetflixHomePageState();
}

class _NetflixHomePageState extends State<NetflixHomePage> {
  final TmdbClient _tmdbClient = const TmdbClient();
  late Future<HomeFeed> _homeFuture;

  @override
  void initState() {
    super.initState();
    _homeFuture = _loadHomeFeed();
  }

  Future<HomeFeed> _loadHomeFeed() async {
    final discover = await _tmdbClient.fetchMovies('/discover/movie');
    final trending = await _tmdbClient.fetchMovies('/trending/movie/week');
    final popular = await _tmdbClient.fetchMovies('/movie/popular');
    final upcoming = await _tmdbClient.fetchMovies('/movie/upcoming');

    return HomeFeed(discover: discover, trending: trending, popular: popular, upcoming: upcoming);
  }

  void _reload() {
    setState(() {
      _homeFuture = _loadHomeFeed();
    });
  }

  Future<void> _openSearch() async {
    final selectedMovie = await showSearch<Movie?>(
      context: context,
      delegate: MovieSearchDelegate(client: _tmdbClient),
    );
    if (!mounted || selectedMovie == null) {
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TitlePreviewPage(item: selectedMovie, client: _tmdbClient),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<HomeFeed>(
        future: _homeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off, size: 46, color: Colors.white70),
                    const SizedBox(height: 10),
                    const Text(
                      'Failed to load movies from TMDB.',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _reload,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final feed = snapshot.data!;
          final heroMovie = feed.discover.isNotEmpty
              ? feed.discover.first
              : (feed.trending.isNotEmpty ? feed.trending.first : null);

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HeroBanner(movie: heroMovie, onSearchTap: _openSearch),
                    const SizedBox(height: 18),
                    CategoryRow(
                      title: 'For You',
                      items: feed.discover,
                    ),
                    CategoryRow(
                      title: 'Trending Now',
                      items: feed.trending,
                    ),
                    CategoryRow(
                      title: 'Popular on NetMirror',
                      items: feed.popular,
                    ),
                    CategoryRow(
                      title: 'Upcoming',
                      items: feed.upcoming,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class HeroBanner extends StatelessWidget {
  const HeroBanner({
    super.key,
    required this.movie,
    required this.onSearchTap,
  });

  final Movie? movie;
  final VoidCallback onSearchTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 470,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (movie?.backdropUrl != null)
            Image.network(
              movie!.backdropUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, error, stackTrace) => const SizedBox.shrink(),
            )
          else
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF5B0C0C),
                    Color(0xFF1B1B1B),
                    Colors.black,
                  ],
                ),
              ),
            ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.2),
                  Colors.black.withValues(alpha: 0.8),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'NETMIRROR',
                        style: TextStyle(
                          color: Color(0xFFE50914),
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.3,
                          fontSize: 24,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: onSearchTap,
                        icon: const Icon(Icons.search, size: 28),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.account_circle, size: 30),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text('TV Shows', style: TextStyle(fontSize: 15)),
                      Text('Movies', style: TextStyle(fontSize: 15)),
                      Text('My List', style: TextStyle(fontSize: 15)),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    movie?.title.toUpperCase() ?? 'NO MOVIE',
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      height: 0.95,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Release ${movie?.releaseYear ?? '-'} • Rating ${movie?.voteAverageLabel ?? '-'}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white70),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          icon: const Icon(Icons.add),
                          label: const Text('My List'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {},
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Play'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white70),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          icon: const Icon(Icons.info_outline),
                          label: const Text('Info'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryRow extends StatelessWidget {
  const CategoryRow({
    super.key,
    required this.title,
    required this.items,
  });

  final String title;
  final List<Movie> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 170,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: items.length > 12 ? 12 : items.length,
              separatorBuilder: (_, index) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final item = items[index];
                return GestureDetector(
                  key: ValueKey('media-card-${item.id}'),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => TitlePreviewPage(item: item, client: const TmdbClient()),
                      ),
                    );
                  },
                  child: SizedBox(
                    width: 112,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: item.posterUrl != null
                          ? Image.network(
                              item.posterUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, error, stackTrace) => _FallbackCard(item: item),
                            )
                          : _FallbackCard(item: item),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FallbackCard extends StatelessWidget {
  const _FallbackCard({required this.item});

  final Movie item;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2E0E0E), Color(0xFF0B0B0B)],
        ),
      ),
      alignment: Alignment.bottomLeft,
      padding: const EdgeInsets.all(10),
      child: Text(
        item.title,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class TitlePreviewPage extends StatelessWidget {
  const TitlePreviewPage({
    super.key,
    required this.item,
    required this.client,
  });

  final Movie item;
  final TmdbClient client;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 360,
            pinned: true,
            backgroundColor: Colors.black,
            leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (item.backdropUrl != null)
                    Image.network(
                      item.backdropUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, error, stackTrace) => const SizedBox.shrink(),
                    )
                  else
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFF350909), Colors.black],
                        ),
                      ),
                    ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.85),
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white54),
                      ),
                      child: const Icon(Icons.play_arrow, size: 36),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 20,
                    child: Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(item.releaseYear, style: const TextStyle(color: Colors.white70)),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white38),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(item.adult ? '18+' : '13+'),
                      ),
                      const SizedBox(width: 10),
                      Text('TMDB ${item.voteAverageLabel}', style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('Movie • TMDB', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  Text(
                    item.overview.isNotEmpty ? item.overview : 'No description available.',
                    style: const TextStyle(color: Colors.white70, height: 1.4),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: () {},
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      minimumSize: const Size.fromHeight(48),
                    ),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Play'),
                  ),
                  const SizedBox(height: 10),
                  FilledButton.icon(
                    onPressed: () {},
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF2A2A2A),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                    ),
                    icon: const Icon(Icons.download),
                    label: const Text('Download'),
                  ),
                  const SizedBox(height: 18),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ActionIcon(icon: Icons.add, label: 'My List'),
                      ActionIcon(icon: Icons.thumb_up_alt_outlined, label: 'Rate'),
                      ActionIcon(icon: Icons.share_outlined, label: 'Share'),
                    ],
                  ),
                  const SizedBox(height: 26),
                  const Text(
                    'More Like This',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 170,
                    child: FutureBuilder<List<Movie>>(
                      future: client.fetchRecommendations(item.id),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                        }
                        if (snapshot.hasError) {
                          return const Center(
                            child: Text(
                              'Could not load suggestions.',
                              style: TextStyle(color: Colors.white70),
                            ),
                          );
                        }
                        final suggestions = snapshot.data ?? const <Movie>[];
                        if (suggestions.isEmpty) {
                          return const Center(
                            child: Text(
                              'No suggestions available.',
                              style: TextStyle(color: Colors.white70),
                            ),
                          );
                        }
                        return ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: suggestions.length > 12 ? 12 : suggestions.length,
                          separatorBuilder: (_, index) => const SizedBox(width: 10),
                          itemBuilder: (context, index) {
                            final suggestion = suggestions[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute<void>(
                                    builder: (_) => TitlePreviewPage(
                                      item: suggestion,
                                      client: client,
                                    ),
                                  ),
                                );
                              },
                              child: SizedBox(
                                width: 112,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: suggestion.posterUrl != null
                                      ? Image.network(
                                          suggestion.posterUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, error, stackTrace) =>
                                              _FallbackCard(item: suggestion),
                                        )
                                      : _FallbackCard(item: suggestion),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ActionIcon extends StatelessWidget {
  const ActionIcon({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 26),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70)),
      ],
    );
  }
}

class TmdbClient {
  const TmdbClient();

  static const String _baseUrl = 'https://api.themoviedb.org/3';
  //static const String _apiKey = String.fromEnvironment('TMDB_API_KEY');
  static const String _apiKey = "089ff97e142c4b012df105099009a50b";
  static const int _maxAttempts = 3;
  static final HttpClient _httpClient = HttpClient()
    ..connectionTimeout = const Duration(seconds: 10);
  Future<List<Movie>> fetchMovies(String path, {int page = 1}) {
    return _fetchMovies(
      path,
      queryParameters: {
        'page': '$page',
        'include_adult': 'false',
      },
    );
  }

  Future<List<Movie>> searchMovies(String query, {int page = 1}) {
    return _fetchMovies(
      '/search/movie',
      queryParameters: {
        'query': query,
        'page': '$page',
        'include_adult': 'false',
      },
    );
  }

  Future<List<Movie>> fetchRecommendations(int movieId, {int page = 1}) {
    return _fetchMovies(
      '/movie/$movieId/recommendations',
      queryParameters: {
        'page': '$page',
        'include_adult': 'false',
      },
    );
  }

  Future<List<Movie>> _fetchMovies(
    String path, {
    Map<String, String> queryParameters = const {},
  }) async {
    if (_apiKey.isEmpty) {
      throw const FormatException(
        'Missing TMDB_API_KEY. Run with --dart-define=TMDB_API_KEY=<your_key>.',
      );
    }

    final uri = Uri.parse('$_baseUrl$path').replace(
      queryParameters: {
        'api_key': _apiKey,
        ...queryParameters,
      },
    );

    final body = await _requestBodyWithRetry(uri);
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Unexpected TMDB response format.');
    }

    final results = decoded['results'];
    if (results is! List) {
      return [];
    }

    return results
        .whereType<Map<String, dynamic>>()
        .map(Movie.fromJson)
        .where((movie) => movie.title.isNotEmpty)
        .toList();
  }

  Future<String> _requestBodyWithRetry(Uri uri) async {
    Object? lastError;
    for (var attempt = 1; attempt <= _maxAttempts; attempt++) {
      try {
        final request = await _httpClient.getUrl(uri).timeout(const Duration(seconds: 10));
        request.headers.set(HttpHeaders.acceptHeader, 'application/json');

        final response = await request.close().timeout(const Duration(seconds: 15));
        final body = await response.transform(utf8.decoder).join();

        if (response.statusCode < 200 || response.statusCode >= 300) {
          if (response.statusCode >= 500 && attempt < _maxAttempts) {
            await Future.delayed(Duration(milliseconds: 300 * attempt));
            continue;
          }
          throw HttpException('TMDB request failed (${response.statusCode}): $body');
        }

        return body;
      } on SocketException catch (error) {
        lastError = error;
      } on HandshakeException catch (error) {
        lastError = error;
      } on TimeoutException catch (error) {
        lastError = error;
      }

      if (attempt < _maxAttempts) {
        await Future.delayed(Duration(milliseconds: 300 * attempt));
      }
    }

    throw HttpException(
      'TMDB network error after $_maxAttempts attempts: $lastError. '
      'Check internet, VPN, firewall, or DNS on this device.',
    );
  }
}

class MovieSearchDelegate extends SearchDelegate<Movie?> {
  MovieSearchDelegate({required this.client});

  final TmdbClient client;

  @override
  String get searchFieldLabel => 'Search movies';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          onPressed: () => query = '',
          icon: const Icon(Icons.clear),
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => close(context, null),
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildResultsView();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildResultsView();
  }

  Widget _buildResultsView() {
    final value = query.trim();
    if (value.isEmpty) {
      return const Center(
        child: Text(
          'Search for a movie title',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return FutureBuilder<List<Movie>>(
      future: client.searchMovies(value),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                '${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          );
        }
        final results = snapshot.data ?? const <Movie>[];
        if (results.isEmpty) {
          return Center(
            child: Text(
              'No results found for "$value".',
              style: const TextStyle(color: Colors.white70),
            ),
          );
        }
        return ListView.separated(
          itemCount: results.length,
          separatorBuilder: (_, index) => const Divider(height: 0, color: Color(0xFF262626)),
          itemBuilder: (context, index) {
            final movie = results[index];
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: SizedBox(
                width: 48,
                child: movie.posterUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.network(
                          movie.posterUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, error, stackTrace) => const Icon(Icons.movie),
                        ),
                      )
                    : const Icon(Icons.movie),
              ),
              title: Text(
                movie.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                '${movie.releaseYear} • TMDB ${movie.voteAverageLabel}',
                style: const TextStyle(color: Colors.white70),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => close(context, movie),
            );
          },
        );
      },
    );
  }
}

class Movie {
  const Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.releaseDate,
    required this.voteAverage,
    required this.adult,
  });

  final int id;
  final String title;
  final String overview;
  final String posterPath;
  final String backdropPath;
  final String releaseDate;
  final double voteAverage;
  final bool adult;

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: (json['title'] ?? json['name'] ?? '').toString(),
      overview: (json['overview'] ?? '').toString(),
      posterPath: (json['poster_path'] ?? '').toString(),
      backdropPath: (json['backdrop_path'] ?? '').toString(),
      releaseDate: (json['release_date'] ?? json['first_air_date'] ?? '').toString(),
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0,
      adult: json['adult'] == true,
    );
  }

  String? get posterUrl => posterPath.isNotEmpty
      ? 'https://image.tmdb.org/t/p/w500$posterPath'
      : null;

  String? get backdropUrl => backdropPath.isNotEmpty
      ? 'https://image.tmdb.org/t/p/w780$backdropPath'
      : null;

  String get releaseYear => releaseDate.length >= 4 ? releaseDate.substring(0, 4) : '-';

  String get voteAverageLabel => voteAverage.toStringAsFixed(1);
}

class HomeFeed {
  const HomeFeed({
    required this.discover,
    required this.trending,
    required this.popular,
    required this.upcoming,
  });

  final List<Movie> discover;
  final List<Movie> trending;
  final List<Movie> popular;
  final List<Movie> upcoming;
}
