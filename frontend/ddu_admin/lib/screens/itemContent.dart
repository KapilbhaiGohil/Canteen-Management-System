import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/canteenProvider.dart';

class ItemContent extends StatefulWidget {
  const ItemContent({super.key});

  @override
  State<ItemContent> createState() => _ItemContentState();
}

class _ItemContentState extends State<ItemContent> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CanteenProvider>(context);

    return RefreshIndicator(
      onRefresh: () async => provider.loadPendingOrders(),
      child: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.hasError
              ? const Center(
                  child: Text('No pending orders found.',
                      style: TextStyle(color: Colors.black87)))
              : provider.pendingOrders.isEmpty
                  ? const Center(
                      child: Text('No pending orders',
                          style: TextStyle(color: Colors.black87)))
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: provider.pendingOrders.length,
                      itemBuilder: (context, index) {
                        final order = provider.pendingOrders[index];
                        return OrderCard(
                          order: order,
                          provider: provider,
                          isCompleted: false,
                        );
                      },
                    ),
    );
  }
}

class OrderCard extends StatefulWidget {
  final Map<String, dynamic> order;
  final CanteenProvider provider;
  final bool isCompleted;
  const OrderCard(
      {super.key,
      required this.order,
      required this.provider,
      required this.isCompleted});

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Order number: ${widget.order['orderNumber']}",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...widget.order['items'].map<Widget>((item) {
              return Dismissible(
                key: Key(item['_id']),
                direction: DismissDirection.startToEnd,
                background: Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 16),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.check, color: Colors.white),
                ),
                onDismissed: (direction) {
                  _handleSwipe(context, widget.provider, item,
                      widget.order['_id'], widget.isCompleted);
                },
                child: ItemCard(item: item),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  void _handleSwipe(BuildContext context, CanteenProvider provider,
      Map<String, dynamic> item, String orderId, bool isCompleted) {
    String d =
        isCompleted ? "Item marked as completed!" : 'Item marked as cooked!';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(d),
        action: SnackBarAction(
          label: "UNDO",
          onPressed: () {
            if (isCompleted) {
              provider.loadCookedOrders();
            } else {
              provider.loadPendingOrders();
            }
          },
        ),
        duration: const Duration(seconds: 3),
      ),
    );

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      if (isCompleted) {
        provider.updateItemStatus(orderId, item['itemId']['_id'], 'completed');
      } else {
        provider.updateItemStatus(orderId, item['itemId']['_id'], 'cooked');
      }
      setState(() {
        widget.order['items'].removeWhere((i) => i['_id'] == item['_id']);
      });
    });
  }
}

class ItemCard extends StatelessWidget {
  final Map<String, dynamic> item;
  const ItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item['itemId']['imageUrl'] ?? '',
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.image_not_supported, color: Colors.grey),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['itemId']['name'],
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Quantity: ${item['quantity']}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${item['itemId']['price'].toString()}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
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
