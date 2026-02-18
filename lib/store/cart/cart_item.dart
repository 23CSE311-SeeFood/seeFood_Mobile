import 'package:hive/hive.dart';

class CartItem {
  CartItem({
    required this.itemId,
    required this.name,
    this.price,
    this.imageUrl,
    this.quantity = 1,
  });

  final String itemId;
  final String name;
  final num? price;
  final String? imageUrl;
  final int quantity;

  CartItem copyWith({int? quantity}) {
    return CartItem(
      itemId: itemId,
      name: name,
      price: price,
      imageUrl: imageUrl,
      quantity: quantity ?? this.quantity,
    );
  }
}

class CartItemAdapter extends TypeAdapter<CartItem> {
  @override
  final int typeId = 1;

  @override
  CartItem read(BinaryReader reader) {
    final itemId = reader.readString();
    final name = reader.readString();
    final hasPrice = reader.readBool();
    final price = hasPrice ? reader.readDouble() : null;
    final hasImage = reader.readBool();
    final imageUrl = hasImage ? reader.readString() : null;
    final quantity = reader.readInt();

    return CartItem(
      itemId: itemId,
      name: name,
      price: price,
      imageUrl: imageUrl,
      quantity: quantity,
    );
  }

  @override
  void write(BinaryWriter writer, CartItem obj) {
    writer.writeString(obj.itemId);
    writer.writeString(obj.name);
    writer.writeBool(obj.price != null);
    if (obj.price != null) {
      writer.writeDouble(obj.price!.toDouble());
    }
    writer.writeBool(obj.imageUrl != null);
    if (obj.imageUrl != null) {
      writer.writeString(obj.imageUrl!);
    }
    writer.writeInt(obj.quantity);
  }
}
