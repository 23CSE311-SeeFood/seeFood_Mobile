import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

class SlideToPayButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onSlide;
  final Color backgroundColor;
  final Color thumbColor;
  final bool isLoading;
  final bool enabled;

  const SlideToPayButton({
    super.key,
    required this.child,
    required this.onSlide,
    this.backgroundColor = Colors.black,
    this.thumbColor = Colors.white,
    this.isLoading = false,
    this.enabled = true,
  });

  @override
  State<SlideToPayButton> createState() => _SlideToPayButtonState();
}

class _SlideToPayButtonState extends State<SlideToPayButton>
    with TickerProviderStateMixin {
  double _position = 0.0;
  double _maxWidth = 0.0;
  final double _thumbSize = 48.0;
  final double _padding = 5.0;
  late AnimationController _controller;
  late AnimationController _shimmerController;
  Animation<double>? _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }


  void _onDragUpdate(DragUpdateDetails details) {
    if (!widget.enabled || widget.isLoading) return;
    setState(() {
      _position = (_position + details.delta.dx)
          .clamp(0.0, _maxWidth - _thumbSize - (_padding * 2));
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (!widget.enabled || widget.isLoading) return;

    final maxDrag = _maxWidth - _thumbSize - (_padding * 2);
    // Threshold: 65% of the way
    if (_position > maxDrag * 0.65) {
      // Snap to end and trigger
      _animateTo(maxDrag);
      HapticFeedback.heavyImpact();
      widget.onSlide();
    } else {
      // Snap back to start
      _animateTo(0.0);
    }
  }

  void _animateTo(double target) {
    _controller.stop();
    _animation = Tween<double>(begin: _position, end: target).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    )..addListener(() {
        setState(() {
          _position = _animation!.value;
        });
      });
    _controller.reset();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(SlideToPayButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isLoading && widget.isLoading) {
      if (mounted) {
        setState(() {
          _position = 0.0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      _maxWidth = constraints.maxWidth;
      final height = _thumbSize + (_padding * 2);

      return Container(
        height: height,
        decoration: BoxDecoration(
          color: widget.enabled ? widget.backgroundColor : Colors.grey.shade400,
          borderRadius: BorderRadius.circular(height / 2),
        ),
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            // Center Content (Text/Loader)
            Center(
              child: Opacity(
                opacity: widget.isLoading ? 1.0 : max(0, 1 - (1.5 * _position / _maxWidth)),
                child: widget.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : AnimatedBuilder(
                        animation: _shimmerController,
                        builder: (context, child) {
                          return ShaderMask(
                            shaderCallback: (bounds) {
                              return LinearGradient(
                                colors: [
                                  Colors.white38,
                                  Colors.white,
                                  Colors.white38,
                                ],
                                stops: const [0.0, 0.5, 1.0],
                                begin: Alignment(-1.0 + (_shimmerController.value * 2.5), 0.0),
                                end: Alignment(-0.2 + (_shimmerController.value * 2.5), 0.0),
                                tileMode: TileMode.clamp,
                              ).createShader(bounds);
                            },
                            blendMode: BlendMode.srcATop,
                            child: widget.child,
                          );
                        },
                      ),
              ),
            ),

            
            // Thumb
            if (!widget.isLoading && widget.enabled)
              Positioned(
                left: _padding + _position,
                child: GestureDetector(
                  onHorizontalDragUpdate: _onDragUpdate,
                  onHorizontalDragEnd: _onDragEnd,
                  child: Container(
                    width: _thumbSize,
                    height: _thumbSize,
                    decoration: BoxDecoration(
                      color: widget.thumbColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 4,
                          offset: const Offset(1, 2),
                        )
                      ],
                    ),
                    child: Icon(
                      Icons.keyboard_double_arrow_right_rounded,
                      color: widget.backgroundColor,
                      size: 28,
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}
