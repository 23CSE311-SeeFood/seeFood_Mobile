import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seefood/pages/checkoutPage.dart';
import 'package:seefood/store/cart/cart_controller.dart';
import 'package:seefood/store/cart/cart_item.dart';

class PlateBar extends StatefulWidget {
  const PlateBar({
    super.key,
  });

  @override
  State<PlateBar> createState() => _PlateBarState();
}

class _PlateBarState extends State<PlateBar> with TickerProviderStateMixin {
  static const double _collapsedHeight = 64;
  static const double _cornerRadius = 28;

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
      reverseDuration: const Duration(milliseconds: 260),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _expand() => _controller.forward();
  void _collapse() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final expandedHeight = min(360.0, screenHeight * 0.45);
    final maxBodyHeight = expandedHeight - _collapsedHeight;

    return Consumer<CartController>(
      builder: (context, cart, _) {
        final hasItems = cart.totalQuantity > 0;
        final total = cart.totalPrice;
        final items = cart.items;

        if (!hasItems && _controller.value > 0) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _collapse());
        }

        return Stack(
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 22),
                child: AnimatedSlide(
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeOutCubic,
                  offset: hasItems ? Offset.zero : const Offset(0, 1),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    opacity: hasItems ? 1 : 0,
                    child: IgnorePointer(
                      ignoring: !hasItems,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) {
                            final t = _controller.value;
                            final containerHeight =
                                _collapsedHeight + maxBodyHeight * t;

                            return Container(
                              height: containerHeight,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 54, 125, 3),
                                borderRadius:
                                    BorderRadius.circular(_cornerRadius),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.18),
                                    blurRadius: 18,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(_cornerRadius),
                                child: Column(
                                  children: [
                                    GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () {
                                        if (_controller.value == 0) {
                                          _expand();
                                        }
                                      },
                                      child: _PlateHeader(
                                        total: total,
                                        expanded: t > 0.99,
                                        onPrimaryAction: () {
                                          if (t > 0.99) {
                                            _collapse();
                                          } else {
                                            _expand();
                                          }
                                        },
                                      ),
                                    ),
                                    ClipRect(
                                      child: Align(
                                        alignment: Alignment.topCenter,
                                        heightFactor: t,
                                        child: SizedBox(
                                          height: maxBodyHeight,
                                          child: Opacity(
                                            opacity: t,
                                            child: _PlateBody(
                                              items: items,
                                              total: total,
                                              onCheckout: () {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        const CheckoutPage(),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PlateHeader extends StatelessWidget {
  const _PlateHeader({
    required this.total,
    required this.expanded,
    required this.onPrimaryAction,
  });

  final num total;
  final bool expanded;
  final VoidCallback onPrimaryAction;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _PlateBarState._collapsedHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  /// the bar
                  // Positioned(
                  //   top: 8,
                  //   child: Container(
                  //     width: 50,
                  //     height: 8,
                  //     decoration: BoxDecoration(
                  //       color: const Color(0xFF1F4704),
                  //       borderRadius: BorderRadius.circular(8),
                  //     ),
                  //   ),
                  // ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'total',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₹${total.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            TextButton(
              onPressed: onPrimaryAction,
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFE0E0E0),
                foregroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: Text(expanded ? 'close plate' : 'view plate'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlateBody extends StatelessWidget {
  const _PlateBody({
    required this.items,
    required this.total,
    required this.onCheckout,
  });

  final List<CartItem> items;
  final num total;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 6),
          Expanded(
            child: ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = items[index];
                return Row(
                  children: [
                    SizedBox(
                      width: 44,
                      child: Text(
                        'x${item.quantity}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const Divider(
            color: Colors.white24,
            height: 12,
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '₹${total.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: onCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE0E0E0),
                foregroundColor: Colors.black,
                shape: const StadiumBorder(),
                elevation: 0,
              ),
              child: const Text(
                'Continue',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
