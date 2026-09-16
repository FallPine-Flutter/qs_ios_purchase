import 'qs_purchase_event_channels.dart';

class QsVipStream {
  static Stream<bool> get vipStream => QsPurchaseEventChannels.vipStream;
}
