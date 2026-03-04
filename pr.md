PR for: Comprehensive updates across queue management, OTP login, UI enhancements, and CI improvements

## Summary

This PR encompasses changes from the last 5 commits, introducing new features, UI updates, and testing improvements:

### Commit 1: `c418d8fc` - Added queue page with websockets
- **Files changed:** `lib/pages/queue_page.dart`
- **Description:** Enhanced the queue page to support real-time updates via WebSocket connections. This allows users to see live queue status, token numbers, and item positions without manual refreshes. The implementation includes WebSocket connection management, message parsing for queue updates and snapshots, and UI components to display live data.

### Commit 2: `ba607623` - Added basic queue page
- **Files changed:** `lib/orders/order_models.dart`, `lib/orders/orders_api.dart`, `lib/pages/orders_page.dart`, `lib/pages/queue_page.dart`
- **Description:** Introduced the foundational queue page and supporting models. Added `OrderModel` and `OrderItem` classes with JSON parsing, created `OrdersApi` for fetching order details, and implemented the basic queue page UI with order display and item status cards.

### Commit 3: `82a612b` - Added code for otp login
- **Files changed:** Multiple files including `lib/main.dart`, `lib/pages/login_page.dart`, `lib/store/auth/auth_profile.dart`, `lib/store/auth/auth_repository.dart`, `pubspec.yaml`, and platform-specific files
- **Description:** Implemented OTP (One-Time Password) login functionality. This includes UI updates to the login page, authentication repository changes for OTP handling, and necessary dependencies in pubspec.yaml. Platform manifests were updated for SMS permissions.

### Commit 4: `e599095` - Added button
- **Files changed:** `lib/pages/login_page.dart`
- **Description:** Added a new button to the login page, likely for triggering OTP requests or other login-related actions. This is a UI enhancement to improve user interaction during the login process.

### Commit 5: `f5d78dbe` - Changed ci and tests
- **Files changed:** `.github/workflows/ci.yml`, `lib/components/homePage/canteen_card.dart`, `lib/pages/checkout_page.dart`, `test/widget_test.dart`
- **Description:** Updated CI workflow configuration, made improvements to the canteen card component and checkout page UI, and modified the basic widget test to ensure app build integrity.

## Testing

Added comprehensive unit tests to validate the new queue and order management features:

- `test/unittest/order_models_test.dart` — Tests `OrderItem.fromJson` and `OrderModel.fromJson` parsing with nested data structures
- `test/unittest/orders_api_test.dart` — Tests `OrdersApi.fetchOrders` and `fetchOrderDetail` methods with mock HTTP clients, covering success and error scenarios

These tests ensure the data models and API client work correctly, providing confidence in the queue page functionality.

## How to run tests

Run the Flutter test runner from the project root:

```bash
flutter test
```

## Notes

- The queue page now supports real-time updates, improving user experience for order tracking.
- OTP login adds a secure authentication method.
- UI enhancements include new buttons and improved components.
- CI pipeline remains robust with the updated workflow.
- Unit tests focus on the core logic of the new features; integration tests for WebSocket and OTP flows could be added in future PRs.
