import 'package:flutter/services.dart';

class QsPurchaseEventChannels {
  static const EventChannel _vipChannel = EventChannel('qs_ios_purchase/vip');
  static const EventChannel _cancelFreeTrialChannel = EventChannel(
    'qs_ios_purchase/cancel_free_trial',
  );
  static const EventChannel _cancelAutoRenewChannel = EventChannel(
    'qs_ios_purchase/cancel_auto_renew',
  );
  static const EventChannel _cancelFreeTrialEveryTimeChannel = EventChannel(
    'qs_ios_purchase/cancel_free_trial_every_time_stream',
  );

  static Stream<bool> get vipStream => _vipChannel
      .receiveBroadcastStream()
      .where((event) => event is bool)
      .cast<bool>();

  static Stream<String> get cancelFreeTrialStream => _cancelFreeTrialChannel
      .receiveBroadcastStream()
      .where((event) => event is String)
      .cast<String>();

  static Stream<String> get cancelAutoRenewStream => _cancelAutoRenewChannel
      .receiveBroadcastStream()
      .where((event) => event is String)
      .cast<String>();

  static Stream<void> get cancelFreeTrialEveryTimeStream =>
      _cancelFreeTrialEveryTimeChannel.receiveBroadcastStream().map<void>(
        (_) {},
      );
}
