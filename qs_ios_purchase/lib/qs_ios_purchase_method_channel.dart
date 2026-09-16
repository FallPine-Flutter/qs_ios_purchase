import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:qs_ios_purchase/qs_cancel_auto_renew_stream.dart';
import 'package:qs_ios_purchase/qs_cancel_free_trial_every_time_stream.dart';
import 'package:qs_ios_purchase/qs_cancel_free_trial_stream.dart';
import 'package:qs_ios_purchase/qs_product_detail.dart';
import 'package:qs_ios_purchase/qs_purchase_result.dart';
import 'package:qs_ios_purchase/qs_vip_stream.dart';

import 'qs_ios_purchase_platform_interface.dart';

/// An implementation of [QsIosPurchasePlatform] that uses method channels.
class MethodChannelQsIosPurchase extends QsIosPurchasePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('qs_ios_purchase');

  StreamSubscription<bool>? _vipSubscription;
  StreamSubscription<String>? _cancelFreeTrialSubscription;
  StreamSubscription<String>? _cancelAutoRenewSubscription;
  StreamSubscription<void>? _cancelFreeTrialEveryTimeSubscription;

  /// 初始化
  @override
  Future<void> initialize({
    required Function(bool isVip) onVipChange,
    required Function(String transactionId) onCancelFreeTrial,
    required Function(String transactionId) onCancelAutoRenew,
    required Function() onCancelFreeTrialEveryTime,
  }) async {
    await _vipSubscription?.cancel();
    await _cancelFreeTrialSubscription?.cancel();
    await _cancelAutoRenewSubscription?.cancel();
    await _cancelFreeTrialEveryTimeSubscription?.cancel();

    _vipSubscription = QsVipStream.vipStream.listen(onVipChange);

    _cancelFreeTrialSubscription = QsCancelFreeTrialStream.cancelFreeTrialStream
        .listen(onCancelFreeTrial);

    _cancelAutoRenewSubscription = QsCancelAutoRenewStream.cancelAutoRenewStream
        .listen(onCancelAutoRenew);

    _cancelFreeTrialEveryTimeSubscription = QsCancelFreeTrialEveryTimeStream
        .cancelFreeTrialEveryTimeStream
        .listen((event) {
          onCancelFreeTrialEveryTime();
        });

    await _invokeNativeMethod("initialize");
  }

  /// 获取商品
  @override
  Future<List<QsProductDetail>> getProducts({
    required List<String> productIds,
  }) async {
    var result = await _invokeNativeMethod("getProducts", {
      "productIds": productIds,
    });
    if (result is List<dynamic>) {
      return result
          .map(
            (e) => QsProductDetail.fromJson(
              _convertObjectMapToMapStringDynamic(e as Map<Object?, Object?>),
            ),
          )
          .toList();
    } else if (result is String) {
      throw PlatformException(code: 'get_products_failed', message: result);
    }

    throw PlatformException(
      code: 'invalid_get_products_result',
      message: 'Invalid getProducts result.',
    );
  }

  /// 请求购买商品
  @override
  Future<QsPurchaseResult> requestPurchase({required String productId}) async {
    var result = await _invokeNativeMethod("requestPurchase", {
      "productId": productId,
    });
    if (result != null) {
      if (result is Map<Object?, Object?>) {
        final QsPurchaseResult purchaseResult = QsPurchaseResult.fromJson(
          _convertObjectMapToMapStringDynamic(result),
        );
        return purchaseResult;
      }
    }

    return QsPurchaseResult(
      status: QsPurchaseStatus.error,
      errorMessage: "未知错误",
      productID: null,
      transactionID: null,
      originalTransactionID: null,
      subscriptionDate: null,
      originalSubscriptionDate: null,
      price: null,
    );
  }

  /// 恢复购买
  @override
  Future<QsPurchaseResult> restorePurchase() async {
    var result = await _invokeNativeMethod("restorePurchase");
    if (result != null) {
      if (result is Map<Object?, Object?>) {
        final QsPurchaseResult purchaseResult = QsPurchaseResult.fromJson(
          _convertObjectMapToMapStringDynamic(result),
        );
        return purchaseResult;
      }
    }

    return QsPurchaseResult(
      status: QsPurchaseStatus.error,
      errorMessage: "未知错误",
      productID: null,
      transactionID: null,
      originalTransactionID: null,
      subscriptionDate: null,
      originalSubscriptionDate: null,
      price: null,
    );
  }

  /// 校验交易订单
  @override
  Future<QsPurchaseResult> checkTransactions() async {
    var result = await _invokeNativeMethod("checkTransactions");
    if (result != null) {
      if (result is Map<Object?, Object?>) {
        final QsPurchaseResult purchaseResult = QsPurchaseResult.fromJson(
          _convertObjectMapToMapStringDynamic(result),
        );
        return purchaseResult;
      }
    }

    return QsPurchaseResult(
      status: QsPurchaseStatus.error,
      errorMessage: "未知错误",
      productID: null,
      transactionID: null,
      originalTransactionID: null,
      subscriptionDate: null,
      originalSubscriptionDate: null,
      price: null,
    );
  }

  /// 调用原生方法
  Future<dynamic> _invokeNativeMethod(
    String method, [
    dynamic arguments,
  ]) async {
    try {
      var result = await methodChannel.invokeMethod(method, arguments);
      return result;
    } on PlatformException {
      rethrow;
    }
  }

  /// 校验交易订单
  @override
  Future<bool> hasHistoryTransactions() async {
    var result = await _invokeNativeMethod("hasHistoryTransactions");
    if (result != null) {
      if (result is bool) {
        return result;
      }
    }

    return false;
  }

  /// 取消续订处理失败
  @override
  Future<void> handleCancelAutoRenewFailure({required String id}) async {
    await _invokeNativeMethod("handleCancelAutoRenewFailure", {"id": id});
  }

  /// 取消试订处理失败
  @override
  Future<void> handleCancelFreeTrialFailure({required String id}) async {
    await _invokeNativeMethod("handleCancelFreeTrialFailure", {"id": id});
  }

  /// 将 `Map<Object?, Object?>` 转换为 `Map<String, dynamic>`
  static Map<String, dynamic> _convertObjectMapToMapStringDynamic(
    Map<Object?, Object?> map,
  ) {
    final Map<String, dynamic> result = {};
    map.forEach((key, value) {
      if (key is String) {
        result[key] = value;
      }
    });
    return result;
  }
}
