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
      title: 'Netflix Home',
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

class NetflixHomePage extends StatelessWidget {
  const NetflixHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _HeroBanner(),
                const SizedBox(height: 18),
                _CategoryRow(
                  title: 'Continue Watching for You',
                  items: const [
                    _MediaItem(
                      title: 'Black Sands',
                      subtitle: 'Crime • Dark',
                      year: '2025',
                      maturity: '16+',
                      duration: '1h 42m',
                      description:
                          'A detective returns to her hometown and unearths a buried conspiracy tied to her own family history.',
                      palette: [Color(0xFF2E0E0E), Color(0xFF0B0B0B)],
                    ),
                    _MediaItem(
                      title: 'Signal Zero',
                      subtitle: 'Sci-Fi • Thriller',
                      year: '2026',
                      maturity: '13+',
                      duration: '2h 01m',
                      description:
                          'An orbital crew receives a transmission from Earth that should not exist and races to decode the truth.',
                      palette: [Color(0xFF201A34), Color(0xFF090B14)],
                    ),
                    _MediaItem(
                      title: 'Red Harbor',
                      subtitle: 'Action • Drama',
                      year: '2024',
                      maturity: '18+',
                      duration: '1h 56m',
                      description:
                          'A former smuggler fights to protect his city when rival cartels push a fragile peace to collapse.',
                      palette: [Color(0xFF10233B), Color(0xFF050A13)],
                    ),
                    _MediaItem(
                      title: 'Apex Unit',
                      subtitle: 'Action • Military',
                      year: '2026',
                      maturity: '16+',
                      duration: '1h 48m',
                      description:
                          'An elite rescue team faces a hostage operation that spirals into an international incident.',
                      palette: [Color(0xFF1E2A10), Color(0xFF0A0D06)],
                    ),
                  ],
                ),
                _CategoryRow(
                  title: 'Trending Now',
                  items: const [
                    _MediaItem(
                      title: 'Vortex',
                      subtitle: 'Mystery • Sci-Fi',
                      year: '2026',
                      maturity: '13+',
                      duration: '8 Episodes',
                      description:
                          'A coastal town is trapped in repeating timelines, and only one journalist remembers each reset.',
                      palette: [Color(0xFF4C0D0D), Color(0xFF0F0505)],
                    ),
                    _MediaItem(
                      title: 'Iron Ledger',
                      subtitle: 'Crime • Heist',
                      year: '2025',
                      maturity: '16+',
                      duration: '6 Episodes',
                      description:
                          'A brilliant forger assembles a team to erase debts by rewriting the world\'s most secure records.',
                      palette: [Color(0xFF33210A), Color(0xFF0D0905)],
                    ),
                    _MediaItem(
                      title: 'Neon Circuit',
                      subtitle: 'Cyberpunk • Action',
                      year: '2024',
                      maturity: '16+',
                      duration: '1h 52m',
                      description:
                          'A courier with a stolen biochip must survive one night while every gang in the city hunts him.',
                      palette: [Color(0xFF0B2D3A), Color(0xFF040D11)],
                    ),
                    _MediaItem(
                      title: 'Kingmaker',
                      subtitle: 'Historical • Epic',
                      year: '2025',
                      maturity: '13+',
                      duration: '10 Episodes',
                      description:
                          'In a fractured empire, one strategist manipulates kings, armies, and faith to build a dynasty.',
                      palette: [Color(0xFF3A1240), Color(0xFF0D0510)],
                    ),
                  ],
                ),
                _CategoryRow(
                  title: 'Popular on Netflix',
                  items: const [
                    _MediaItem(
                      title: 'Shadow Crown',
                      subtitle: 'Fantasy • Adventure',
                      year: '2023',
                      maturity: '13+',
                      duration: '12 Episodes',
                      description:
                          'An exiled heir and a reluctant mage begin a journey to reclaim a kingdom from immortal tyrants.',
                      palette: [Color(0xFF27163F), Color(0xFF090510)],
                    ),
                    _MediaItem(
                      title: 'Deadline',
                      subtitle: 'Thriller • Political',
                      year: '2025',
                      maturity: '16+',
                      duration: '2h 07m',
                      description:
                          'A newsroom uncovers an election plot and has 24 hours to publish before a national blackout.',
                      palette: [Color(0xFF3D1A1A), Color(0xFF110909)],
                    ),
                    _MediaItem(
                      title: 'Blue Echo',
                      subtitle: 'Drama • Emotional',
                      year: '2024',
                      maturity: '13+',
                      duration: '1h 44m',
                      description:
                          'After a tragic accident, a musician rebuilds his life through a series of anonymous street performances.',
                      palette: [Color(0xFF183441), Color(0xFF060D10)],
                    ),
                    _MediaItem(
                      title: 'Ground Zero',
                      subtitle: 'War • Survival',
                      year: '2025',
                      maturity: '18+',
                      duration: '9 Episodes',
                      description:
                          'A civilian convoy is stranded behind enemy lines and forced to navigate a collapsing front.',
                      palette: [Color(0xFF383010), Color(0xFF0C0A04)],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 470,
      child: Stack(
        fit: StackFit.expand,
        children: [
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
                  Colors.black.withOpacity(0.15),
                  Colors.black.withOpacity(0.75),
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
                        'NETFLIX',
                        style: TextStyle(
                          color: Color(0xFFE50914),
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.3,
                          fontSize: 24,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {},
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
                  const Text(
                    'THE LAST KINGDOM',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.4,
                      height: 0.95,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Action • Historical • Epic',
                    style: TextStyle(
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

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.title, required this.items});

  final String title;
  final List<_MediaItem> items;

  @override
  Widget build(BuildContext context) {
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
            height: 160,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final item = items[index];
                return GestureDetector(
                  key: ValueKey('media-card-${item.title}'),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => _TitlePreviewPage(item: item),
                      ),
                    );
                  },
                  child: Container(
                    width: 112,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: item.palette,
                      ),
                    ),
                    alignment: Alignment.bottomLeft,
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      item.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
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

class _TitlePreviewPage extends StatelessWidget {
  const _TitlePreviewPage({required this.item});

  final _MediaItem item;

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
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          item.palette.first,
                          item.palette.last,
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
                          Colors.transparent,
                          Colors.black.withOpacity(0.85),
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
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
                      Text(item.year, style: const TextStyle(color: Colors.white70)),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white38),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(item.maturity),
                      ),
                      const SizedBox(width: 10),
                      Text(item.duration, style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(item.subtitle, style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  Text(item.description, style: const TextStyle(color: Colors.white70, height: 1.4)),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: const [
                      _ActionIcon(icon: Icons.add, label: 'My List'),
                      _ActionIcon(icon: Icons.thumb_up_alt_outlined, label: 'Rate'),
                      _ActionIcon(icon: Icons.share_outlined, label: 'Share'),
                    ],
                  ),
                  const SizedBox(height: 26),
                  const Text(
                    'Episodes & More Like This',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 140,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: 6,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, index) => Container(
                        width: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [item.palette.first, Colors.black],
                          ),
                        ),
                        alignment: Alignment.bottomLeft,
                        padding: const EdgeInsets.all(10),
                        child: Text('Preview ${index + 1}'),
                      ),
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

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({required this.icon, required this.label});

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

class _MediaItem {
  const _MediaItem({
    required this.title,
    required this.subtitle,
    required this.year,
    required this.maturity,
    required this.duration,
    required this.description,
    required this.palette,
  });

  final String title;
  final String subtitle;
  final String year;
  final String maturity;
  final String duration;
  final String description;
  final List<Color> palette;
}
