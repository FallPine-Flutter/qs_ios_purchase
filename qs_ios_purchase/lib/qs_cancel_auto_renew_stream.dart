import 'qs_purchase_event_channels.dart';

class QsCancelAutoRenewStream {
  static Stream<String> get cancelAutoRenewStream =>
      QsPurchaseEventChannels.cancelAutoRenewStream;
}
