class QsProductDetail {
  QsProductDetail({
    required this.id,
    required this.productType,
    required this.price,
    required this.currencyPrice,
    required this.discountPrice,
    required this.discountCurrencyPrice,
    required this.discountRate,
    required this.trialPeriodValue,
    required this.trialPeriodUnit,
    required this.subscriptionPeriodValue,
    required this.subscriptionPeriodUnit,
    required this.languageCode,
    required this.regionCode,
    required this.weekAveragePrice,
    required this.paymentMode,
    required this.isEligibleForIntroOffer, // 是否能享受优惠
  });

  factory QsProductDetail.fromJson(Map<String, dynamic> json) {
    final eligibility = json['isEligibleForIntroOffer'];
    return QsProductDetail(
      id: json['id'] as String,
      productType: _enumByName(QsProductType.values, json['productType']),
      price: (json['price'] as num?)?.toDouble(),
      currencyPrice: json['currencyPrice'] as String?,
      discountPrice: (json['discountPrice'] as num?)?.toDouble(),
      discountCurrencyPrice: json['discountCurrencyPrice'] as String?,
      discountRate: (json['discountRate'] as num?)?.toInt(),
      trialPeriodValue: (json['trialPeriodValue'] as num?)?.toInt(),
      trialPeriodUnit: _enumByName(
        QsPeriodUnit.values,
        json['trialPeriodUnit'],
      ),
      subscriptionPeriodValue: (json['subscriptionPeriodValue'] as num?)
          ?.toInt(),
      subscriptionPeriodUnit: _enumByName(
        QsPeriodUnit.values,
        json['subscriptionPeriodUnit'],
      ),
      languageCode: json['languageCode'] as String?,
      regionCode: json['regionCode'] as String?,
      weekAveragePrice: json['weekAveragePrice'] as String?,
      paymentMode: _enumByName(QsPaymentMode.values, json['paymentMode']),
      isEligibleForIntroOffer: eligibility == true || eligibility == 'true',
    );
  }

  final String id;
  final QsProductType? productType;
  final double? price;
  final String? currencyPrice;
  final double? discountPrice;
  final String? discountCurrencyPrice;
  final int? discountRate;
  final int? trialPeriodValue;
  final QsPeriodUnit? trialPeriodUnit;
  final int? subscriptionPeriodValue;
  final QsPeriodUnit? subscriptionPeriodUnit;
  final String? languageCode;
  final String? regionCode;
  final String? weekAveragePrice;
  final QsPaymentMode? paymentMode;
  final bool isEligibleForIntroOffer; // 是否能享受优惠

  // 是否免费试用
  bool get isFreeTrial {
    return paymentMode == QsPaymentMode.freeTrial && isEligibleForIntroOffer;
  }

  // 是否折扣
  bool get isDiscount {
    return discountPrice != null && isEligibleForIntroOffer;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['productType'] = productType?.name;
    data['price'] = price;
    data['currencyPrice'] = currencyPrice;
    data['discountPrice'] = discountPrice;
    data['discountCurrencyPrice'] = discountCurrencyPrice;
    data['discountRate'] = discountRate;
    data['trialPeriodValue'] = trialPeriodValue;
    data['trialPeriodUnit'] = trialPeriodUnit?.name;
    data['subscriptionPeriodValue'] = subscriptionPeriodValue;
    data['subscriptionPeriodUnit'] = subscriptionPeriodUnit?.name;
    data['languageCode'] = languageCode;
    data['regionCode'] = regionCode;
    data['weekAveragePrice'] = weekAveragePrice;
    data['paymentMode'] = paymentMode?.name;
    data['isEligibleForIntroOffer'] = isEligibleForIntroOffer
        ? 'true'
        : 'false'; // 是否能享受优惠
    return data;
  }
}

enum QsProductType { consumable, nonConsumable, nonRenewable, autoRenewable }

enum QsPeriodUnit { day, week, month, year }

enum QsPaymentMode { payAsYouGo, payUpFront, freeTrial }

T? _enumByName<T extends Enum>(List<T> values, Object? name) {
  if (name is! String) return null;
  for (final value in values) {
    if (value.name == name) return value;
  }
  return null;
}
