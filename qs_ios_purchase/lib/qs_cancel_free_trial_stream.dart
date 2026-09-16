import 'qs_purchase_event_channels.dart';

class QsCancelFreeTrialStream {
  static Stream<String> get cancelFreeTrialStream =>
      QsPurchaseEventChannels.cancelFreeTrialStream;
}
