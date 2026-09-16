import 'package:flutter_test/flutter_test.dart';
import 'package:qs_ios_purchase/qs_ios_purchase.dart';

void main() {
  group('QsProductDetail', () {
    test('parses numeric fields and string eligibility', () {
      final product = QsProductDetail.fromJson(
        _productJson(isEligibleForIntroOffer: 'true'),
      );

      expect(product.id, 'vip_monthly');
      expect(product.productType, QsProductType.autoRenewable);
      expect(product.price, 10.0);
      expect(product.discountPrice, 4.5);
      expect(product.discountRate, 55);
      expect(product.trialPeriodValue, 1);
      expect(product.subscriptionPeriodValue, 1);
      expect(product.trialPeriodUnit, QsPeriodUnit.week);
      expect(product.subscriptionPeriodUnit, QsPeriodUnit.month);
      expect(product.paymentMode, QsPaymentMode.freeTrial);
      expect(product.isEligibleForIntroOffer, true);
    });

    test('accepts boolean eligibility and preserves string JSON output', () {
      final product = QsProductDetail.fromJson(
        _productJson(isEligibleForIntroOffer: true),
      );

      expect(product.isEligibleForIntroOffer, true);
      expect(product.toJson()['isEligibleForIntroOffer'], 'true');
    });

    test('maps unknown enum values to null', () {
      final json = _productJson(isEligibleForIntroOffer: false)
        ..['productType'] = 'unknown'
        ..['trialPeriodUnit'] = 'unknown'
        ..['subscriptionPeriodUnit'] = 'unknown'
        ..['paymentMode'] = 'unknown';

      final product = QsProductDetail.fromJson(json);

      expect(product.productType, isNull);
      expect(product.trialPeriodUnit, isNull);
      expect(product.subscriptionPeriodUnit, isNull);
      expect(product.paymentMode, isNull);
      expect(product.isEligibleForIntroOffer, false);
    });
  });

  group('QsPurchaseResult', () {
    test('round-trips known status and fields', () {
      final result = QsPurchaseResult.fromJson({
        'status': 'success',
        'errorMessage': null,
        'productID': 'vip_monthly',
        'transactionID': 'tx_1',
        'originalTransactionID': 'tx_0',
        'subscriptionDate': '1000',
        'originalSubscriptionDate': '900',
        'price': r'$9.99',
      });

      expect(result.status, QsPurchaseStatus.success);
      expect(result.toJson(), {
        'status': 'success',
        'errorMessage': null,
        'productID': 'vip_monthly',
        'transactionID': 'tx_1',
        'originalTransactionID': 'tx_0',
        'subscriptionDate': '1000',
        'originalSubscriptionDate': '900',
        'price': r'$9.99',
      });
    });

    test('maps unknown status to null', () {
      final result = QsPurchaseResult.fromJson({'status': 'unknown'});

      expect(result.status, isNull);
      expect(result.toJson()['status'], isNull);
    });
  });
}

Map<String, dynamic> _productJson({required Object isEligibleForIntroOffer}) {
  return {
    'id': 'vip_monthly',
    'productType': 'autoRenewable',
    'price': 10,
    'currencyPrice': r'$10.00',
    'discountPrice': 4.5,
    'discountCurrencyPrice': r'$4.50',
    'discountRate': 55.9,
    'trialPeriodValue': 1.0,
    'trialPeriodUnit': 'week',
    'subscriptionPeriodValue': 1,
    'subscriptionPeriodUnit': 'month',
    'languageCode': 'en',
    'regionCode': 'US',
    'weekAveragePrice': r'$2.50',
    'paymentMode': 'freeTrial',
    'isEligibleForIntroOffer': isEligibleForIntroOffer,
  };
}
