import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

class CartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Cart')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cart.items.length,
              itemBuilder: (ctx, index) {
                final item = cart.items[index];
                return ListTile(
                  leading: item.product.imagePath != null
                      ? Image.file(File(item.product.imagePath!), width: 50, height: 50, fit: BoxFit.cover)
                      : Image.network(item.product.image!, width: 50, height: 50, fit: BoxFit.cover),
                  title: Text(item.product.title),
                  subtitle: Text('Price: \$${item.product.price} x ${item.quantity}'),
                  trailing: IconButton(
                    icon: Icon(Icons.remove_circle),
                    onPressed: () => cart.removeFromCart(item.product.id),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Total: \$${cart.totalPrice.toStringAsFixed(2)}', style: TextStyle(fontSize: 20)),
          ),
        ],
      ),
    );
  }
}