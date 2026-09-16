# Preparation timing release

## Behavior

The seller selects an estimated preparation duration. The backend schedules
driver searching five minutes before estimated readiness, or immediately for a
duration of five minutes or less. Preparation and driver matching are separate
states. Neither countdown expiry nor driver assignment marks food ready.

Old clients must retain the existing `driver_dispatch_delay_minutes` meaning.
New clients must only send preparation timing when the server advertises support.
Requesting a driver immediately must preserve the preparation estimate.

## Baseline observations (16 September 2026)

- Latest seller release branch: `09673c8`, version `1.0.18+20`.
- Seller `origin/dev`: `3cfb5c5`; `origin/main`: `90b41ce`.
- Existing release PR #7 targets dev and includes 205 files of previous release
  changes. Its unchanged release tree was merged into dev as `aa17862` before
  opening the separate preparation-timing PR. GitHub's merge API failed, so the
  merge was made in an isolated worktree and pushed normally (no force push).
- `https://sellertaybgo.web.app/version.json` reports `1.0.13+14`.
- `dev-seller.taybgo.com` did not resolve during the baseline check.
- Local development testing uses `lib/main_dev.dart`, `ENV=dev`, and the
  `https://dev.taybgo.com` API. A locally rendered page alone does not establish
  authenticated API behavior or successful scheduled dispatch.

## Release gates

- [x] Confirm deployed backend development/production commit identities.
  Backend task verified Render dev `21ba7a5` and production `1fd4e953`; both web
  services have auto-deploy disabled.
- [x] Agree on seller/customer API fields, compatibility, and allowed actions.
- [ ] Independently review backend, seller, and customer diffs.
- [x] Verify backend boundary, reschedule, cancellation, and stale-task tests.
  Independent in-memory SQLite run: all 42 seller-order API tests passed.
- [x] Verify preparation remains visible while driver search/assignment proceeds
  in seller widget tests; authenticated development proof is still pending.
- [x] Verify countdown does not restart on remount or app resume in widget tests.
- [ ] Merge reviewed changes and deploy development web/worker/scheduler services.
- [ ] Verify actual development order acceptance and scheduled driver search.
- [ ] Verify customer messaging against the same development order.
- [ ] Record commit/PR/deployment evidence and unresolved production gaps.

Production deployment follows development validation; no production deployment
is part of the initial development test gate.

## Seller implementation and validation

New requests use `preparation_time_minutes` only when the order advertises
`supports_preparation_timing`, `preparation_max_minutes`, and
`driver_dispatch_lead_minutes`. Legacy requests retain their old driver-delay
meaning. Zero-minute preparation rescheduling stays a RESCHEDULE; REQUEST_NOW
does not contain either timing field. The app never dispatches at local zero.

Preparation and driver-search countdowns share the response receipt clock
anchor. Null preparation remaining time, terminal orders, and on-the-way orders
suppress stale estimates. The current backend has no separate READY status;
wording does not imply that one exists.

- Full Flutter suite: 55 tests passed.
- Changed order sources and tests: Dart analysis passed.
- Whole-app analysis: 85 existing warnings/informational issues, no errors.
- Development release web build passed; final live build/test remains gated on
  the backend development deployment.
- Menu photo removal is included as a separate commit (`03d181a`): an explicit
  null image is sent when saving removal, matching the backend's nullable field.

## Operational limits for production review

The existing backend permits seller cancellation only while status is ACCEPTED
and no driver is assigned. Starting driver search changes that status, so both
seller cancellation and preparation rescheduling become unavailable when the
search starts, even if no driver has accepted yet. This change preserves that
policy; it does not add a way to extend preparation after searching begins.

Starting a search does not guarantee driver availability or arrival. Live
development validation must check the actual worker transition independently
of the countdown reaching zero.
