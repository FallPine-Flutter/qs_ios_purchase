import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qs_ios_purchase/qs_ios_purchase.dart';
import 'package:qs_ios_purchase/qs_ios_purchase_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel methodChannel = MethodChannel('qs_ios_purchase');
  const MethodChannel vipChannel = MethodChannel('qs_ios_purchase/vip');
  const MethodChannel cancelFreeTrialChannel = MethodChannel(
    'qs_ios_purchase/cancel_free_trial',
  );
  const MethodChannel cancelAutoRenewChannel = MethodChannel(
    'qs_ios_purchase/cancel_auto_renew',
  );
  const MethodChannel cancelFreeTrialEveryTimeChannel = MethodChannel(
    'qs_ios_purchase/cancel_free_trial_every_time_stream',
  );

  late MethodChannelQsIosPurchase plugin;
  final calls = <MethodCall>[];

  Future<dynamic> handleEventChannelCall(MethodCall call) async => null;

  setUp(() {
    plugin = MethodChannelQsIosPurchase();
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(vipChannel, handleEventChannelCall);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          cancelFreeTrialChannel,
          handleEventChannelCall,
        );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          cancelAutoRenewChannel,
          handleEventChannelCall,
        );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          cancelFreeTrialEveryTimeChannel,
          handleEventChannelCall,
        );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(methodChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(vipChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(cancelFreeTrialChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(cancelAutoRenewChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(cancelFreeTrialEveryTimeChannel, null);
  });

  void mockNative(Future<dynamic> Function(MethodCall call) handler) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(methodChannel, (call) {
          calls.add(call);
          return handler(call);
        });
  }

  Future<void> emitEvent({
    required MethodChannel channel,
    required Object? event,
  }) async {
    await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .handlePlatformMessage(
          channel.name,
          const StandardMethodCodec().encodeSuccessEnvelope(event),
          (_) {},
        );
    await Future<void>.delayed(Duration.zero);
  }

  test(
    'initialize calls native initialize and can be called repeatedly',
    () async {
      mockNative((call) async => null);

      await plugin.initialize(
        onVipChange: (_) {},
        onCancelFreeTrial: (_) {},
        onCancelAutoRenew: (_) {},
        onCancelFreeTrialEveryTime: () {},
      );
      await plugin.initialize(
        onVipChange: (_) {},
        onCancelFreeTrial: (_) {},
        onCancelAutoRenew: (_) {},
        onCancelFreeTrialEveryTime: () {},
      );

      expect(calls.map((call) => call.method), ['initialize', 'initialize']);
    },
  );

  test('initialize forwards valid typed events to callbacks', () async {
    mockNative((call) async => null);
    final vipEvents = <bool>[];
    final freeTrialEvents = <String>[];
    final autoRenewEvents = <String>[];
    var everyTimeEventCount = 0;

    await plugin.initialize(
      onVipChange: vipEvents.add,
      onCancelFreeTrial: freeTrialEvents.add,
      onCancelAutoRenew: autoRenewEvents.add,
      onCancelFreeTrialEveryTime: () => everyTimeEventCount++,
    );

    await emitEvent(channel: vipChannel, event: true);
    await emitEvent(channel: cancelFreeTrialChannel, event: 'tx_trial');
    await emitEvent(channel: cancelAutoRenewChannel, event: 'tx_auto');
    await emitEvent(channel: cancelFreeTrialEveryTimeChannel, event: null);

    expect(vipEvents, [true]);
    expect(freeTrialEvents, ['tx_trial']);
    expect(autoRenewEvents, ['tx_auto']);
    expect(everyTimeEventCount, 1);
  });

  test('typed event streams ignore invalid payload types', () async {
    mockNative((call) async => null);
    final vipEvents = <bool>[];
    final freeTrialEvents = <String>[];
    final autoRenewEvents = <String>[];

    await plugin.initialize(
      onVipChange: vipEvents.add,
      onCancelFreeTrial: freeTrialEvents.add,
      onCancelAutoRenew: autoRenewEvents.add,
      onCancelFreeTrialEveryTime: () {},
    );

    await emitEvent(channel: vipChannel, event: 'true');
    await emitEvent(channel: cancelFreeTrialChannel, event: false);
    await emitEvent(channel: cancelAutoRenewChannel, event: 1);

    expect(vipEvents, isEmpty);
    expect(freeTrialEvents, isEmpty);
    expect(autoRenewEvents, isEmpty);
  });

  test('getProducts parses product details', () async {
    mockNative((call) async {
      expect(call.method, 'getProducts');
      expect(call.arguments, {
        'productIds': ['vip_monthly'],
      });
      return [
        {
          'id': 'vip_monthly',
          'productType': 'autoRenewable',
          'price': 9.99,
          'currencyPrice': r'$9.99',
          'discountPrice': 0.0,
          'discountCurrencyPrice': r'$0.00',
          'discountRate': 100,
          'trialPeriodValue': 7,
          'trialPeriodUnit': 'day',
          'subscriptionPeriodValue': 1,
          'subscriptionPeriodUnit': 'month',
          'languageCode': 'en',
          'regionCode': 'US',
          'weekAveragePrice': r'$2.50',
          'paymentMode': 'freeTrial',
        },
      ];
    });

    final products = await plugin.getProducts(productIds: ['vip_monthly']);

    expect(products, hasLength(1));
    expect(products.single.id, 'vip_monthly');
    expect(products.single.productType, QsProductType.autoRenewable);
    expect(products.single.paymentMode, QsPaymentMode.freeTrial);
  });

  test(
    'getProducts throws PlatformException when native returns an error string',
    () async {
      mockNative((call) async => 'store unavailable');

      expect(
        plugin.getProducts(productIds: ['vip_monthly']),
        throwsA(
          isA<PlatformException>()
              .having((error) => error.code, 'code', 'get_products_failed')
              .having((error) => error.message, 'message', 'store unavailable'),
        ),
      );
    },
  );

  test(
    'purchase-like methods parse success, error, and cancel statuses',
    () async {
      mockNative((call) async {
        switch (call.method) {
          case 'requestPurchase':
            return {
              'status': 'success',
              'productID': 'vip_monthly',
              'transactionID': 'tx_1',
              'originalTransactionID': 'tx_0',
              'subscriptionDate': '2026-04-27',
              'originalSubscriptionDate': '2026-04-27',
              'price': r'$9.99',
            };
          case 'restorePurchase':
            return {'status': 'cancel'};
          case 'checkTransactions':
            return {'status': 'error', 'errorMessage': '没有有效的商品'};
        }
        return null;
      });

      final purchase = await plugin.requestPurchase(productId: 'vip_monthly');
      final restore = await plugin.restorePurchase();
      final check = await plugin.checkTransactions();

      expect(purchase.status, QsPurchaseStatus.success);
      expect(purchase.transactionID, 'tx_1');
      expect(restore.status, QsPurchaseStatus.cancel);
      expect(check.status, QsPurchaseStatus.error);
      expect(check.errorMessage, '没有有效的商品');
    },
  );

  test(
    'history and cancellation failure methods call native methods',
    () async {
      mockNative((call) async {
        if (call.method == 'hasHistoryTransactions') {
          return true;
        }
        return null;
      });

      final count = await plugin.hasHistoryTransactions();
      await plugin.handleCancelAutoRenewFailure(id: 'tx_auto');
      await plugin.handleCancelFreeTrialFailure(id: 'tx_trial');

      expect(count, true);
      expect(calls.map((call) => call.method), [
        'hasHistoryTransactions',
        'handleCancelAutoRenewFailure',
        'handleCancelFreeTrialFailure',
      ]);
    },
  );
}
