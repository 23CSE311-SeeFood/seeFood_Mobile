import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seefood/data/canteen_api/canteen_item.dart';
import 'package:seefood/store/cart/cart_controller.dart';
import 'package:seefood/store/cart/cart_item.dart';

class ItemCard extends StatelessWidget {
  const ItemCard({super.key, required this.item, required this.canteenId});

  final CanteenItem item;
  final int canteenId;

  @override
  Widget build(BuildContext context) {
    final itemId = item.id.toString();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ItemImage(
            imageUrl: item.imageUrl,
            rating: item.rating,
          ),
          const SizedBox(height: 14),
          Text(
            item.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (item.description != null &&
              item.description!.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              item.description!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.price != null ? '₹${item.price}' : '₹—',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2E9A4A),
                ),
              ),
              const _SizeChips(),
            ],
          ),
          const SizedBox(height: 16),
          Consumer<CartController>(
            builder: (context, cart, _) {
              final quantity = cart.getQuantity(itemId);
              return quantity == 0
                  ? _AddToDishButton(
                      onPressed: () {
                        cart.addItem(
                          item: CartItem(
                            itemId: itemId,
                            name: item.name,
                            price: item.price,
                            imageUrl: item.imageUrl,
                          ),
                          canteenId: canteenId,
                        );
                      },
                    )
                  : _QuantityControl(
                      quantity: quantity,
                      onDecrement: () {
                        cart.updateQuantity(itemId, quantity - 1);
                      },
                      onIncrement: () {
                        cart.updateQuantity(itemId, quantity + 1);
                      },
                    );
            },
          ),
        ],
      ),
    );
  }
}

class _ItemImage extends StatelessWidget {
  const _ItemImage({required this.imageUrl, required this.rating});

  final String? imageUrl;
  final num? rating;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: 200,
            child: imageUrl == null
                ? DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.orange.shade200,
                          Colors.orange.shade400,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.fastfood,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                  )
                : Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                  ),
          ),
          Positioned(
            left: 12,
            bottom: 12,
            child: _RatingPill(rating: rating),
          ),
          Positioned(
            right: 12,
            bottom: 12,
            child: Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_border,
                color: Color(0xFFE15B5B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingPill extends StatelessWidget {
  const _RatingPill({required this.rating});

  final num? rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 16, color: Color(0xFFF4B400)),
          const SizedBox(width: 6),
          Text(
            rating?.toStringAsFixed(1) ?? '4.8',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _SizeChips extends StatelessWidget {
  const _SizeChips();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        _SizeChip(label: 'S', selected: true),
        SizedBox(width: 6),
        _SizeChip(label: 'M', selected: false),
        SizedBox(width: 6),
        _SizeChip(label: 'L', selected: false),
      ],
    );
  }
}

class _SizeChip extends StatelessWidget {
  const _SizeChip({required this.label, required this.selected});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final borderColor = selected ? const Color(0xFF2E9A4A) : Colors.grey.shade400;
    final textColor = selected ? const Color(0xFF2E9A4A) : Colors.black87;

    return Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

class _AddToDishButton extends StatelessWidget {
  const _AddToDishButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFDFF7E8),
          foregroundColor: Colors.black87,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: const Text(
          'Add to Dish',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _QuantityControl extends StatelessWidget {
  const _QuantityControl({
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
  });

  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFDFF7E8),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _RoundIconButton(
              icon: Icons.remove,
              onPressed: onDecrement,
            ),
            Text(
              quantity.toString(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            _RoundIconButton(
              icon: Icons.add,
              onPressed: onIncrement,
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(icon, size: 18),
        ),
      ),
    );
  }
}
