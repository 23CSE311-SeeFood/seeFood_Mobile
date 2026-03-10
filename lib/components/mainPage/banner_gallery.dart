import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class BannerGallery extends StatefulWidget {
  const BannerGallery({
    super.key,
    this.images = const [],
    this.aspectRatio = 16 / 9,
    this.viewportFraction = 0.9,
    this.autoScrollDuration = const Duration(seconds: 4),
  });

  /// Accepts asset paths or network URLs.
  final List<String> images;
  final double aspectRatio;
  final double viewportFraction;
  final Duration autoScrollDuration;

  @override
  State<BannerGallery> createState() => _BannerGalleryState();
}

class _BannerGalleryState extends State<BannerGallery>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _progressController;
  int _currentIndex = 0;

  List<String> get _images => widget.images.isEmpty
      ? const [
          'assets/banners/bone.png',
          'assets/banners/btwo.png',
          'assets/banners/bthree.png',
        ]
      : widget.images;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: widget.viewportFraction);
    _progressController = AnimationController(
      vsync: this,
      duration: widget.autoScrollDuration,
    )..addStatusListener(_handleProgressStatus);
    _progressController.forward();
  }

  @override
  void didUpdateWidget(covariant BannerGallery oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.autoScrollDuration != widget.autoScrollDuration) {
      _progressController.duration = widget.autoScrollDuration;
      _progressController.forward(from: 0);
    }
    if (_currentIndex >= _images.length) {
      _currentIndex = 0;
      _pageController.jumpToPage(0);
      _progressController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _progressController.removeStatusListener(_handleProgressStatus);
    _progressController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _handleProgressStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _advancePage();
    }
  }

  void _advancePage() {
    if (_images.length <= 1) return;
    final next = (_currentIndex + 1) % _images.length;
    _pageController.animateToPage(
      next,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
    setState(() => _currentIndex = next);
    _progressController.forward(from: 0);
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
    _progressController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth * widget.viewportFraction;
        final cardHeight = cardWidth / widget.aspectRatio;

        return SizedBox(
          height: cardHeight,
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: _images.length,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, index) {
                  final path = _images[index];
                  final isAsset = path.startsWith('assets/');

                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: isAsset
                            ? Image.asset(path, fit: BoxFit.cover)
                            : CachedNetworkImage(
                                imageUrl: path,
                                fit: BoxFit.cover,
                                placeholder: (_, __) =>
                                    const _BannerFallback(),
                                errorWidget: (_, __, ___) =>
                                    const _BannerFallback(),
                              ),
                      ),
                    ),
                  );
                },
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 10,
                child: _ProgressBarRow(
                  count: _images.length,
                  currentIndex: _currentIndex,
                  progress: _progressController,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProgressBarRow extends StatelessWidget {
  const _ProgressBarRow({
    required this.count,
    required this.currentIndex,
    required this.progress,
  });

  final int count;
  final int currentIndex;
  final Animation<double> progress;

  @override
  Widget build(BuildContext context) {
    if (count <= 1) return const SizedBox.shrink();
    return AnimatedBuilder(
      animation: progress,
      builder: (context, _) {
        return Row(
          children: List.generate(count, (index) {
            final value = index < currentIndex
                ? 1.0
                : index == currentIndex
                    ? progress.value
                    : 0.0;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: _ProgressBar(value: value),
              ),
            );
          }),
        );
      },
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: SizedBox(
        height: 3,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(color: Colors.white.withValues(alpha: 0.35)),
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: value.clamp(0, 1),
              child: Container(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class _BannerFallback extends StatelessWidget {
  const _BannerFallback();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFE7F5E9),
            Color(0xFFBFE6C8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.local_offer,
          size: 48,
          color: Color(0xFF2E9A4A),
        ),
      ),
    );
  }
}
