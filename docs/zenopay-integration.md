# ZenoPay — Flutter Client

Mobile app integration for maSOKOtips subscription payments. Backend contract: [ZenoPay payments](../../improvements/04-zenopay-payments-integration.md) (Laravel repo).

## Endpoints used

| Flow | Method | Path |
|------|--------|------|
| Create subscription | POST | `/api/subscriptions` |
| Mobile checkout | POST | `/api/zenopay/checkout` |
| Poll payment (triggers gateway check) | GET | `/api/zenopay/subscription/{id}/payment-status` |
| Order status fallback | GET | `/api/zenopay/status/{orderId}` |
| Cancel pending | POST | `/api/zenopay/subscription/{id}/cancel` |
| Card checkout | POST | `/api/zenopay/card/checkout` |
| Card status | GET | `/api/zenopay/card/status/{subscriptionId}` |

All authenticated routes require `Authorization: Bearer {sanctum_token}`.

## Key files

| File | Role |
|------|------|
| `lib/services/subscription_service.dart` | API calls for subscriptions + ZenoPay |
| `lib/services/card_payment_service.dart` | Card checkout + status |
| `lib/services/zenopay_service.dart` | Phone normalization helper |
| `lib/providers/subscription_provider.dart` | State + checkout orchestration |
| `lib/screens/subscription/zenopay_phone_input_screen.dart` | Phone entry |
| `lib/screens/subscription/zenopay_payment_screen.dart` | Mobile money polling UI |
| `lib/screens/subscription/card_payment_screen.dart` | Hosted card webview |
| `lib/config/api_config.dart` | Base URL (`isProduction` toggle) |

## Phone numbers

Use `ZenoPayService.formatPhoneNumber()` before checkout. Accepts `07…`, `06…`, `255…`, or `+255…`. Server normalizes to Tanzania local `0XXXXXXXXX` for ZenoPay.

## Payment polling

During mobile money checkout, poll **`/zenopay/subscription/{id}/payment-status`** (not `/subscriptions/status/{id}`). The payment-status route polls ZenoPay when the subscription is still pending.

## Card payments

Webview loads `payment_link` from checkout response. Callback URL: `/api/zenopay/card/callback?subscription_id=…&status=…`

## Local development

Set `ApiConfig.isProduction = false` and point `_localUrl` at your machine (Android emulator: `10.0.2.2`, iOS simulator: machine LAN IP).

## Subscription expired (403)

API returns `{ "code": "SUBSCRIPTION_EXPIRED", ... }`. Dashboard screens redirect to subscription flow when this code appears in errors.
