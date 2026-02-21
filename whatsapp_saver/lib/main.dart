import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';

abstract final class AppColors {
  static const mxBlue = Color(0xFF1686FF);
  static const deepBlue = Color(0xFF0F4CC0);
  static const skyBlue = Color(0xFF59B2FF);
  static const ink = Color(0xFF0D2448);
}

void main() {
  runApp(const StatusSaverApp());
}

class StatusSaverApp extends StatelessWidget {
  const StatusSaverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Status Saver',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.mxBlue,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF1F6FF),
      ),
      home: const StatusHomePage(),
    );
  }
}

enum StatusType { image, video }

enum StatusSource { whatsapp, business }

class StatusItem {
  const StatusItem({
    required this.file,
    required this.type,
    required this.source,
    required this.modified,
  });

  final File file;
  final StatusType type;
  final StatusSource source;
  final DateTime modified;

  String get name => p.basename(file.path);
  String get sourceLabel =>
      source == StatusSource.whatsapp ? 'WhatsApp' : 'WA Business';
}

class StatusHomePage extends StatefulWidget {
  const StatusHomePage({super.key});

  @override
  State<StatusHomePage> createState() => _StatusHomePageState();
}

class _StatusHomePageState extends State<StatusHomePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  List<StatusItem> _allItems = const [];
  bool _loading = true;
  String? _error;
  static const List<(String, StatusSource)> _statusDirs = [
    ('/storage/emulated/0/WhatsApp/Media/.Statuses', StatusSource.whatsapp),
    (
      '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/.Statuses',
      StatusSource.whatsapp,
    ),
    (
      '/storage/emulated/0/WhatsApp Business/Media/.Statuses',
      StatusSource.business,
    ),
    (
      '/storage/emulated/0/Android/media/com.whatsapp.w4b/WhatsApp Business/Media/.Statuses',
      StatusSource.business,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadStatuses();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadStatuses() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final granted = await _ensurePermission();
    if (!granted) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _error =
            'Cannot access status folders.\nAllow "All files access" for this app and retry.';
      });
      return;
    }

    try {
      final items = <StatusItem>[];
      for (final entry in _statusDirs) {
        final dir = Directory(entry.$1);
        if (!await dir.exists()) {
          continue;
        }
        try {
          await for (final entity in dir.list(followLinks: false)) {
            if (entity is! File) {
              continue;
            }
            final ext = p.extension(entity.path).toLowerCase();
            if (_isImage(ext) || _isVideo(ext)) {
              final stat = await entity.stat();
              items.add(
                StatusItem(
                  file: entity,
                  type: _isImage(ext) ? StatusType.image : StatusType.video,
                  source: entry.$2,
                  modified: stat.modified,
                ),
              );
            }
          }
        } on FileSystemException {
          // Some OEM/Android versions block individual folders; continue scanning others.
          continue;
        }
      }

      items.sort((a, b) => b.modified.compareTo(a.modified));

      if (!mounted) {
        return;
      }
      setState(() {
        _allItems = items;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _error = 'Failed to scan statuses. Please try again.';
      });
    }
  }

  bool _isImage(String ext) => ['.jpg', '.jpeg', '.png', '.webp'].contains(ext);

  bool _isVideo(String ext) => ['.mp4', '.3gp', '.mkv', '.webm'].contains(ext);

  Future<bool> _ensurePermission() async {
    if (!Platform.isAndroid) {
      return false;
    }

    final mediaStatuses = await [
      Permission.photos,
      Permission.videos,
      Permission.storage,
    ].request();

    final hasBasicMediaPermission = mediaStatuses.values.any(
      (status) => status.isGranted || status.isLimited,
    );

    var manageStatus = await Permission.manageExternalStorage.status;
    if (!manageStatus.isGranted) {
      manageStatus = await Permission.manageExternalStorage.request();
    }

    final hasAllFilesAccess = manageStatus.isGranted;
    if (hasAllFilesAccess) {
      return true;
    }

    final canReadStatusDirs = await _canReadStatusDirectories();
    if (hasBasicMediaPermission && canReadStatusDirs) {
      return true;
    }

    return false;
  }

  Future<bool> _canReadStatusDirectories() async {
    var foundExisting = false;
    for (final entry in _statusDirs) {
      final dir = Directory(entry.$1);
      if (!await dir.exists()) {
        continue;
      }
      foundExisting = true;
      try {
        await dir.list(followLinks: false).take(1).drain<void>();
      } on FileSystemException {
        continue;
      }
      return true;
    }

    // If folders don't exist yet, treat this as readable so UI can show empty state.
    return !foundExisting;
  }

  @override
  Widget build(BuildContext context) {
    final images = _allItems
        .where((item) => item.type == StatusType.image)
        .toList();
    final videos = _allItems
        .where((item) => item.type == StatusType.video)
        .toList();

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE7F2FF), Color(0xFFF8FBFF)],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.mxBlue.withValues(alpha: 0.08),
              blurRadius: 50,
              spreadRadius: 15,
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -40,
              top: -30,
              child: Container(
                height: 170,
                width: 170,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.mxBlue.withValues(alpha: 0.14),
                ),
              ),
            ),
            Positioned(
              left: -50,
              top: 90,
              child: Container(
                height: 130,
                width: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.deepBlue.withValues(alpha: 0.08),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(11),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [AppColors.skyBlue, AppColors.mxBlue],
                            ),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.mxBlue.withValues(alpha: 0.3),
                                blurRadius: 14,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.play_circle_rounded,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Status Saver',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.ink,
                                ),
                              ),
                              Text(
                                'MX Blue Edition',
                                style: TextStyle(
                                  color: Color(0xFF355B93),
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Refresh',
                          onPressed: _loadStatuses,
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.mxBlue,
                            side: BorderSide(
                              color: AppColors.mxBlue.withValues(alpha: 0.2),
                            ),
                          ),
                          icon: const Icon(Icons.refresh_rounded, size: 20),
                        ),
                      ],
                    ),
                  ),
                  _SummaryBar(items: _allItems),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Material(
                      borderRadius: BorderRadius.circular(18),
                      color: const Color(0xFFDCEBFF),
                      child: TabBar(
                        controller: _tabController,
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.transparent,
                        indicator: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [AppColors.mxBlue, AppColors.deepBlue],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        labelColor: Colors.white,
                        unselectedLabelColor: const Color(0xFF305891),
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                        tabs: [
                          Tab(text: 'Images (${images.length})'),
                          Tab(text: 'Videos (${videos.length})'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: _loading
                        ? const Center(child: CircularProgressIndicator())
                        : _error != null
                        ? _ErrorView(message: _error!, onRetry: _loadStatuses)
                        : TabBarView(
                            controller: _tabController,
                            children: [
                              _StatusGrid(
                                items: images,
                                onRefresh: _loadStatuses,
                              ),
                              _StatusGrid(
                                items: videos,
                                onRefresh: _loadStatuses,
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryBar extends StatelessWidget {
  const _SummaryBar({required this.items});

  final List<StatusItem> items;

  @override
  Widget build(BuildContext context) {
    final waCount = items
        .where((item) => item.source == StatusSource.whatsapp)
        .length;
    final businessCount = items
        .where((item) => item.source == StatusSource.business)
        .length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _TagCard(title: 'WhatsApp', count: waCount, color: AppColors.mxBlue),
          const SizedBox(width: 10),
          _TagCard(
            title: 'WA Business',
            count: businessCount,
            color: const Color(0xFF2A6FE0),
          ),
        ],
      ),
    );
  }
}

class _TagCard extends StatelessWidget {
  const _TagCard({
    required this.title,
    required this.count,
    required this.color,
  });

  final String title;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.22),
              color.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        child: Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: color,
              child: Text(
                '$count',
                style: const TextStyle(fontSize: 11, color: Colors.white),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: color.withValues(alpha: 0.98),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusGrid extends StatelessWidget {
  const _StatusGrid({required this.items, required this.onRefresh});

  final List<StatusItem> items;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          children: const [
            SizedBox(height: 140),
            Icon(Icons.inbox_outlined, size: 64, color: Colors.black38),
            SizedBox(height: 10),
            Center(
              child: Text(
                'No statuses found yet.\nWatch a status first, then refresh.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 18),
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.78,
        ),
        itemBuilder: (context, index) {
          final item = items[index];
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: Duration(milliseconds: 220 + (index % 8) * 45),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, (1 - value) * 18),
                  child: child,
                ),
              );
            },
            child: _StatusCard(item: item),
          );
        },
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.item});

  final StatusItem item;

  @override
  Widget build(BuildContext context) {
    final isVideo = item.type == StatusType.video;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => StatusPreviewPage(item: item),
          ),
        );
      },
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          border: Border.all(color: AppColors.mxBlue.withValues(alpha: 0.12)),
          boxShadow: [
            BoxShadow(
              color: AppColors.mxBlue.withValues(alpha: 0.16),
              blurRadius: 18,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (!isVideo)
                      Image.file(item.file, fit: BoxFit.cover)
                    else
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF114193), Color(0xFF2B7DF7)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.play_circle_fill_rounded,
                            color: Colors.white,
                            size: 58,
                          ),
                        ),
                      ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          item.sourceLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.58),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Row(
                children: [
                  Icon(
                    isVideo ? Icons.videocam_rounded : Icons.image_rounded,
                    size: 18,
                    color: Colors.black54,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StatusPreviewPage extends StatefulWidget {
  const StatusPreviewPage({super.key, required this.item});

  final StatusItem item;

  @override
  State<StatusPreviewPage> createState() => _StatusPreviewPageState();
}

class _StatusPreviewPageState extends State<StatusPreviewPage> {
  VideoPlayerController? _controller;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.item.type == StatusType.video) {
      _controller = VideoPlayerController.file(widget.item.file)
        ..initialize().then((_) {
          if (!mounted) {
            return;
          }
          setState(() {});
          _controller?.setLooping(true);
          _controller?.play();
        });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _saveStatus() async {
    setState(() {
      _saving = true;
    });

    try {
      final saveDir = Directory('/storage/emulated/0/Download/Status Saver');
      if (!await saveDir.exists()) {
        await saveDir.create(recursive: true);
      }

      final ext = p.extension(widget.item.file.path);
      final name = p.basenameWithoutExtension(widget.item.file.path);
      var target = File(p.join(saveDir.path, '$name$ext'));
      if (await target.exists()) {
        final suffix = DateTime.now().millisecondsSinceEpoch;
        target = File(p.join(saveDir.path, '${name}_$suffix$ext'));
      }

      await widget.item.file.copy(target.path);

      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Saved to ${target.path}')));
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to save status.')));
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isVideo = widget.item.type == StatusType.video;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(widget.item.sourceLabel),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saving ? null : _saveStatus,
        backgroundColor: AppColors.mxBlue,
        foregroundColor: Colors.white,
        icon: _saving
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.download_rounded),
        label: Text(_saving ? 'Saving...' : 'Save status'),
      ),
      body: Center(
        child: isVideo
            ? (_controller?.value.isInitialized ?? false)
                  ? AspectRatio(
                      aspectRatio: _controller!.value.aspectRatio,
                      child: VideoPlayer(_controller!),
                    )
                  : const CircularProgressIndicator(color: Colors.white)
            : InteractiveViewer(child: Image.file(widget.item.file)),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.lock_outline_rounded,
              size: 62,
              color: Colors.black45,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 14),
            FilledButton.tonalIcon(
              onPressed: onRetry,
              icon: const Icon(Icons.restart_alt_rounded),
              label: const Text('Grant / Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
