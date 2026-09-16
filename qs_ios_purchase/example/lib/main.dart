import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qs_ios_purchase/qs_ios_purchase.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final TextEditingController _productIdsController = TextEditingController();
  String _message = 'Ready';
  bool _isVip = false;

  @override
  void dispose() {
    _productIdsController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    try {
      await QsIosPurchase.initialize(
        onVipChange: (isVip) {
          if (!mounted) return;
          setState(() {
            _isVip = isVip;
            _message = 'VIP status changed: $isVip';
          });
        },
        onCancelFreeTrial: (transactionId) {
          if (!mounted) return;
          setState(() => _message = 'Free trial cancelled: $transactionId');
        },
        onCancelAutoRenew: (transactionId) {
          if (!mounted) return;
          setState(() => _message = 'Auto renew cancelled: $transactionId');
        },
        onCancelFreeTrialEveryTime: () {
          if (!mounted) return;
          setState(() => _message = 'Free trial cancellation detected');
        },
      );
      if (!mounted) return;
      setState(() => _message = 'Initialized');
    } on PlatformException catch (error) {
      if (!mounted) return;
      setState(() => _message = error.message ?? error.code);
    }
  }

  Future<void> _loadProducts() async {
    final productIds = _productIdsController.text
        .split(',')
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toList();

    if (productIds.isEmpty) {
      setState(() => _message = 'Enter at least one product id');
      return;
    }

    try {
      final products = await QsIosPurchase.getProducts(productIds: productIds);
      if (!mounted) return;
      setState(() => _message = 'Loaded ${products.length} product(s)');
    } on PlatformException catch (error) {
      if (!mounted) return;
      setState(() => _message = error.message ?? error.code);
    }
  }

  Future<void> _loadHistoryCount() async {
    try {
      final count = await QsIosPurchase.hasHistoryTransactions();
      if (!mounted) return;
      setState(() => _message = 'History transactions: $count');
    } on PlatformException catch (error) {
      if (!mounted) return;
      setState(() => _message = error.message ?? error.code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('qs_ios_purchase example')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('VIP: $_isVip'),
            const SizedBox(height: 12),
            TextField(
              controller: _productIdsController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Product IDs',
                hintText: 'product_a, product_b',
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _initialize,
              child: const Text('Initialize'),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _loadProducts,
              child: const Text('Load products'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _loadHistoryCount,
              child: const Text('Load history count'),
            ),
            const SizedBox(height: 16),
            Text(_message),
          ],
        ),
      ),
    );
  }
}
