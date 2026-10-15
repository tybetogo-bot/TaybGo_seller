# Seller rescue deals

Open **Profile → Settings → Rescue deals**. The feature includes a complete deal list, create form, timing/limit editor, deal details, stock adjustments, pause/resume and archive confirmation.

## Design

Neutral surfaces, soft borders, the seller's chosen accent hue in a quieter tone, and compact status badges keep the focus on food, price and portions. Phone layouts use one column; wider layouts put deal cards in two columns and the creation preview alongside the form. The primary action stays visible below the create/edit form. Arabic uses the bundled Cairo font and right-to-left layout; English uses Poppins. Other app languages use the existing English translation fallback for this feature.

These previews are rendered from the actual Flutter screens with isolated test fixtures, not live restaurant records. Actual menu photos appear automatically; the fixtures use image placeholders.

- [Phone list](previews/rescue-deals-mobile.png)
- [Desktop creation](previews/rescue-deals-desktop.png)
- [Arabic creation](previews/rescue-deals-arabic.png)

## API and lifecycle

The API contract is defined by backend [PR #91](https://github.com/tybetogo-bot/backend/pull/91). Confirm deployment of its code and migrations before releasing this frontend. This change does not deploy either application.

- All requests use the shared authenticated Dio client and centralized API endpoints.
- List and catalog pagination load all pages, so status filters and menu search cover the complete selected restaurant. Deal rows from another restaurant are discarded.
- Creation sends restaurant/item IDs, a decimal price string, a deliberate portion count, UTC start/end instants and an optional account limit. The backend captures the original price and initial stock. The form previews menu data, preserves failed drafts and displays backend field errors.
- Money input is parsed as integer cents, including decimal comma and Arabic/Persian digits. Counts also normalize Arabic/Persian digits. New deals start immediately unless scheduled. Dates show the device timezone and offset; restaurants do not yet have their own timezone setting.
- Editing changes timing and customer limits. Prices stay fixed in this UI; stock adjustments belong to the details screen, never a remaining-quantity PATCH.
- Stock requests persist an idempotency key and signed quantity before sending. Pending operations are scoped by seller, restaurant and deal, survive screen/app reconstruction, and reuse the same key across uncertain outcomes. A different adjustment cannot replace a pending one. A confirmed response or definite validation rejection clears it. A timeout, rate limit or server error retains it for confirmation.
- Account/restaurant generation checks discard late data and prevent stale form submissions. Item and stock sheets hide old restaurant content when context changes. Visible lists/details refresh periodically; lists also refresh after app resume. Returned mutation data updates local state without inventing inventory values.
- DELETE is presented as irreversible archiving with preserved history. It stays disabled when the backend response lacks the new archival contract, avoiding hard deletion against an older backend. Pending stock updates must be confirmed before archiving.
- Order item parsing prioritizes server unit-price snapshots and retains rescue identity/original price. Details label rescue lines. Manual/incoming order edits preserve rescue IDs and expected prices, keeping discounted and regular lines for the same menu item distinct. Reordering retains its existing regular catalog flow.

## Verification

```sh
flutter test --no-pub
flutter analyze --no-pub lib/features/rescue_deals lib/core/network/rescue_deals_api.dart test/features/rescue_deals
flutter build web --release --no-wasm-dry-run --no-pub -t lib/main_dev.dart --dart-define=ENV=dev
```

The feature tests cover validation and failed drafts, UTC payloads, pagination/ownership, restaurant switching, persistent stock retries, inventory updates, archive compatibility, snapshot pricing, mixed regular/rescue order edits, light/dark mode, desktop, Arabic and larger text. Optional `--dart-define=RESCUE_PREVIEWS=true` on the rescue UI tests writes preview PNGs to the system temporary directory for local visual inspection.

Provider-backed HTTP tests use test doubles. Authenticated end-to-end interaction against a deployed backend and physical-device QA remain release checks. Customer discovery/basket work belongs to the customer app and is not included here.
