class QsPurchaseResult {
  QsPurchaseResult({
    required this.status,
    required this.errorMessage,
    required this.productID,
    required this.transactionID,
    required this.originalTransactionID,
    required this.subscriptionDate,
    required this.originalSubscriptionDate,
    required this.price,
  });

  factory QsPurchaseResult.fromJson(Map<String, dynamic> json) {
    return QsPurchaseResult(
      status: _purchaseStatusByName(json['status']),
      errorMessage: json['errorMessage'] as String?,
      productID: json['productID'] as String?,
      transactionID: json['transactionID'] as String?,
      originalTransactionID: json['originalTransactionID'] as String?,
      subscriptionDate: json['subscriptionDate'] as String?,
      originalSubscriptionDate: json['originalSubscriptionDate'] as String?,
      price: json['price'] as String?,
    );
  }

  final QsPurchaseStatus? status;
  final String? errorMessage;
  final String? productID;
  final String? transactionID;
  final String? originalTransactionID;
  final String? subscriptionDate;
  final String? originalSubscriptionDate;
  final String? price;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['status'] = status?.name;
    data['errorMessage'] = errorMessage;
    data['productID'] = productID;
    data['transactionID'] = transactionID;
    data['originalTransactionID'] = originalTransactionID;
    data['subscriptionDate'] = subscriptionDate;
    data['originalSubscriptionDate'] = originalSubscriptionDate;
    data['price'] = price;
    return data;
  }
}

enum QsPurchaseStatus { success, error, cancel }

QsPurchaseStatus? _purchaseStatusByName(Object? name) {
  if (name is! String) return null;
  for (final status in QsPurchaseStatus.values) {
    if (status.name == name) return status;
  }
  return null;
}
