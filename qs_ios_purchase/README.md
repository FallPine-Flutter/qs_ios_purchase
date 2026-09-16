# qs_ios_purchase

`qs_ios_purchase` 是一个基于 iOS StoreKit 2 的 Flutter 内购插件，封装了商品查询、购买、恢复购买、交易校验、历史交易判断，以及 VIP、取消免费试用、取消自动续订等事件监听能力。

> 当前插件仅支持 iOS，最低系统版本为 iOS 15.0。
>
> 当前文档对应插件版本 `1.0.7`，底层依赖 `QSInAppPurchase 1.3.0`。

## 功能特性

- 获取 App Store Connect 中配置的内购商品信息
- 发起消耗型、非消耗型、非续期订阅、自动续期订阅购买
- 恢复购买
- 校验当前交易状态
- 判断当前账号是否存在历史交易
- 监听 VIP 状态变化
- 监听取消免费试用、取消自动续订事件
- 支持取消事件处理失败后的补偿通知

## 安装

在项目的 `pubspec.yaml` 中添加依赖：

```yaml
dependencies:
  qs_ios_purchase: ^1.0.7
```

如果需要本地调试，可以使用路径依赖：

```yaml
dependencies:
  qs_ios_purchase:
    path: ../qs_ios_purchase
```

然后执行：

```bash
flutter pub get
```

## iOS 配置

1. 在 App Store Connect 中创建内购商品，并记录商品 ID。
2. 确认 iOS 工程的 Deployment Target 不低于 `15.0`。
3. 确认项目已经启用 In-App Purchase 能力。
4. 使用真机、Sandbox 账号或 TestFlight 测试完整内购流程。

## 引入

只需导入插件主入口即可使用 `QsIosPurchase`、`QsProductDetail`、`QsPurchaseResult` 及其相关枚举：

```dart
import 'package:qs_ios_purchase/qs_ios_purchase.dart';
```

## API 总览

| API | 返回值 | 说明 |
| --- | --- | --- |
| `initialize(...)` | `Future<void>` | 注册原生监听并订阅四类事件回调 |
| `getProducts(productIds: ...)` | `Future<List<QsProductDetail>>` | 获取指定商品的详情 |
| `requestPurchase(productId: ...)` | `Future<QsPurchaseResult>` | 发起购买 |
| `restorePurchase()` | `Future<QsPurchaseResult>` | 恢复购买 |
| `checkTransactions()` | `Future<QsPurchaseResult?>` | 校验当前是否存在有效交易 |
| `hasHistoryTransactions()` | `Future<bool>` | 判断当前账号是否存在历史交易 |
| `handleCancelAutoRenewFailure(id: ...)` | `Future<void>` | 上报取消自动续订事件处理失败 |
| `handleCancelFreeTrialFailure(id: ...)` | `Future<void>` | 上报取消免费试用事件处理失败 |

## 基础使用

### 1. 初始化监听

如果业务需要接收 VIP 状态或取消订阅事件，建议在应用启动后调用 `initialize`。重复调用时，插件会先取消旧的 Dart 事件订阅，再注册新的回调。

```dart
Future<void> initPurchase() async {
  await QsIosPurchase.initialize(
    onVipChange: (isVip) {
      // VIP 状态变化
      print('isVip: $isVip');
    },
    onCancelFreeTrial: (transactionId) {
      // 用户取消免费试用
      print('cancel free trial: $transactionId');
    },
    onCancelAutoRenew: (transactionId) {
      // 用户取消自动续订
      print('cancel auto renew: $transactionId');
    },
    onCancelFreeTrialEveryTime: () {
      // 每次检测到取消免费试用时触发
      print('cancel free trial event');
    },
  );
}
```

回调参数说明：

- `onVipChange`：返回最新 VIP 状态，参数类型为 `bool`。
- `onCancelFreeTrial`：返回取消免费试用对应的交易 ID。
- `onCancelAutoRenew`：返回取消自动续订对应的交易 ID。
- `onCancelFreeTrialEveryTime`：每次检测到取消免费试用时触发，不携带参数。
- 原生事件的类型不符合约定时，VIP、取消免费试用和取消自动续订事件会被忽略。

### 2. 获取商品列表

```dart
final products = await QsIosPurchase.getProducts(
  productIds: [
    'your_product_id',
    'your_subscription_id',
  ],
);

for (final product in products) {
  print('${product.id}: ${product.currencyPrice}');
}
```

`getProducts` 成功时返回 `List<QsProductDetail>`；原生侧返回错误信息或平台调用失败时会抛出 `PlatformException`。

### 3. 发起购买

```dart
final result = await QsIosPurchase.requestPurchase(
  productId: 'your_product_id',
);

switch (result.status) {
  case QsPurchaseStatus.success:
    print('购买成功: ${result.transactionID}');
    break;
  case QsPurchaseStatus.cancel:
    print('用户取消购买');
    break;
  case QsPurchaseStatus.error:
  default:
    print('购买失败: ${result.errorMessage}');
    break;
}
```

购买成功后，返回结果中会包含商品 ID、交易 ID、原始交易 ID、订阅时间、原始订阅时间和价格等信息。

`requestPurchase` 会从最近一次 `getProducts` 获取的商品中查找目标商品。找不到商品时返回 `QsPurchaseStatus.error`，不会自动重新查询商品。

### 4. 恢复购买

```dart
final result = await QsIosPurchase.restorePurchase();

if (result.status == QsPurchaseStatus.success) {
  print('恢复购买成功');
} else {
  print('恢复购买失败: ${result.errorMessage}');
}
```

### 5. 校验交易

```dart
final result = await QsIosPurchase.checkTransactions();

if (result?.status == QsPurchaseStatus.success) {
  print('存在有效交易');
} else {
  print('没有有效交易: ${result?.errorMessage}');
}
```

### 6. 判断是否存在历史交易

```dart
final hasHistory = await QsIosPurchase.hasHistoryTransactions();
print('是否存在历史交易: $hasHistory');
```

### 7. 取消事件处理失败后的补偿

如果业务侧处理取消自动续订或取消免费试用事件失败，可以调用对应方法通知原生侧重新处理。

```dart
await QsIosPurchase.handleCancelAutoRenewFailure(id: transactionId);
await QsIosPurchase.handleCancelFreeTrialFailure(id: transactionId);
```

## 数据模型

### QsProductDetail

商品信息包含以下常用字段：

- `id`：商品 ID
- `productType`：商品类型
- `price`：原始价格数值
- `currencyPrice`：带货币符号的本地化价格
- `discountPrice`：优惠价格数值
- `discountCurrencyPrice`：带货币符号的本地化优惠价格
- `discountRate`：折扣比例
- `trialPeriodValue`：试用周期数值
- `trialPeriodUnit`：试用周期单位
- `subscriptionPeriodValue`：订阅周期数值
- `subscriptionPeriodUnit`：订阅周期单位
- `languageCode`：价格区域语言码
- `regionCode`：价格区域地区码
- `weekAveragePrice`：按周折算价格
- `paymentMode`：优惠支付模式
- `isEligibleForIntroOffer`：是否有资格享受订阅优惠
- `isFreeTrial`：是否为可用的免费试用商品
- `isDiscount`：是否为可用的折扣商品

### QsPurchaseResult

购买、恢复购买和交易校验结果包含以下字段：

- `status`：操作状态
- `errorMessage`：错误信息
- `productID`：商品 ID
- `transactionID`：交易 ID
- `originalTransactionID`：原始交易 ID
- `subscriptionDate`：订阅时间
- `originalSubscriptionDate`：原始订阅时间
- `price`：交易价格

## 枚举说明

### QsPurchaseStatus

- `success`：操作成功
- `error`：操作失败
- `cancel`：用户取消

### QsProductType

- `consumable`：消耗型商品
- `nonConsumable`：非消耗型商品
- `nonRenewable`：非续期订阅
- `autoRenewable`：自动续期订阅

### QsPeriodUnit

- `day`：天
- `week`：周
- `month`：月
- `year`：年

### QsPaymentMode

- `payAsYouGo`：按周期支付优惠价
- `payUpFront`：预付优惠价
- `freeTrial`：免费试用

## 注意事项

- `initialize` 用于注册事件监听；需要接收 VIP 或取消订阅事件时，应在相关业务开始前完成初始化。
- 商品 ID 必须与 App Store Connect 中配置的商品 ID 完全一致。
- StoreKit 2 需要 iOS 15.0 及以上系统。
- 内购流程建议在真机、Sandbox 账号和 TestFlight 环境中完整验证。
- 购买接口会从已获取的商品中查找对应商品，购买前必须先调用 `getProducts` 获取目标商品。
- `getProducts` 或方法通道调用失败时可能抛出 `PlatformException`；购买、恢复购买和交易校验的业务结果通过 `QsPurchaseResult.status` 返回。
- `checkTransactions` 的公开返回类型允许为空；当前默认 MethodChannel 实现会在无有效结果时返回 `error` 状态结果。
- 业务侧收到取消免费试用或取消自动续订事件后，如果处理失败，请调用对应的补偿方法，便于后续重新处理。
