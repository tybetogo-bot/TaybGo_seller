# TaybGo Seller App — Manual Testing Checklist

> **How to use this file**: Work through each section top to bottom. Check `[x]` when a scenario passes. Leave `[ ]` unchecked if it fails and add a note below it describing what went wrong. All scenarios must pass before a release is considered stable.

---

## Prerequisites

- Dev build running on a real device or emulator (`flutter run --flavor dev -t lib/main_dev.dart --dart-define=ENV=dev`)
- A valid seller phone number registered in the dev backend
- At least one restaurant associated with the seller account
- Internet connection active
- Firebase project connected (push notifications need a real device)

---

## 1. App Startup & Splash

### 1.1 Cold Start — Unauthenticated
- [ ] App opens and shows splash screen
- [ ] Splash screen does not hang indefinitely
- [ ] Redirects to `/login` within ~2 seconds if no token stored

### 1.2 Cold Start — Authenticated with Valid Token
- [ ] App opens and shows splash screen
- [ ] Automatically loads restaurants for the user
- [ ] If user has one restaurant → redirects to `/home`
- [ ] If user has multiple restaurants → redirects to `/restaurant-selection`

### 1.3 Cold Start — Authenticated but Pending Review
- [ ] App redirects to `/pending-review` screen
- [ ] Pending review screen shows a meaningful message
- [ ] User can navigate to knowledge base from pending review

### 1.4 Cold Start — Expired Token
- [ ] Token refresh is triggered automatically
- [ ] If refresh succeeds → user lands on home/restaurant-selection
- [ ] If refresh fails → user is redirected to `/login` (no crash)

---

## 2. Authentication

### 2.1 Login — Happy Path
- [ ] Login screen loads with country picker and phone input
- [ ] Default country code is shown
- [ ] User can tap country picker and change country
- [ ] Entering a valid phone number and tapping "Send OTP" sends the request
- [ ] Loading indicator appears while request is in flight
- [ ] OTP screen appears after successful request
- [ ] (Dev only) OTP code is shown in the response / console

### 2.2 Login — Phone Validation
- [ ] Empty phone number shows a validation error
- [ ] Phone number shorter than 10 digits shows a validation error
- [ ] Phone number longer than 15 digits shows a validation error
- [ ] Non-numeric characters are rejected or stripped
- [ ] Valid format (+1234567890) passes validation

### 2.3 OTP Verification — Happy Path
- [ ] OTP screen shows the phone number entered
- [ ] 6-digit input field is focused automatically
- [ ] Entering correct OTP and tapping "Verify" authenticates the user
- [ ] Loading indicator appears during verification
- [ ] Redirects to restaurant selection or home on success

### 2.4 OTP Verification — Failure Cases
- [ ] Wrong OTP code shows an error message
- [ ] Error message is dismissible / screen remains usable
- [ ] User can try again with a different code

### 2.5 OTP Resend
- [ ] Resend button is disabled for the first 60 seconds (cooldown timer counts down)
- [ ] After 60 seconds, resend button becomes active
- [ ] Tapping resend sends a new OTP request
- [ ] Cooldown timer resets after resend

### 2.6 Logout
- [ ] Logout is accessible from the Profile tab
- [ ] Tapping logout shows a confirmation dialog
- [ ] Confirming logout calls the blacklist endpoint and clears local tokens
- [ ] User is redirected to `/login`
- [ ] Back button after logout does not return to authenticated screens

---

## 3. Onboarding (New Seller)

### 3.1 Multi-Step Form Flow
- [ ] Step 1 (Seller Profile): Name, email, phone fields are shown
- [ ] Step 2 (Restaurant Details): Restaurant name, type, description shown
- [ ] Step 3 (Address): Map / address search is shown
- [ ] "Next" button validates current step before advancing
- [ ] "Back" button returns to previous step without losing entered data

### 3.2 Field Validation — Seller Profile
- [ ] Name: empty → validation error
- [ ] Name: less than 2 characters → validation error
- [ ] Name: Arabic characters accepted
- [ ] Email: invalid format → validation error
- [ ] Email: valid format accepted

### 3.3 Registration Documents
- [ ] Document upload UI is present
- [ ] Image picker opens on tap
- [ ] Uploaded image preview is shown
- [ ] Submission without document shows an error

### 3.4 Successful Submission
- [ ] Submitting all valid data calls `POST /api/seller/onboarding/`
- [ ] Loading indicator shown during submission
- [ ] On success → redirected to `/pending-review`
- [ ] Pending review screen is shown with appropriate messaging

### 3.5 Failed Submission
- [ ] Network error during submission shows a user-friendly error
- [ ] User can retry without re-entering all data

---

## 4. Restaurant Selection

### 4.1 Single Restaurant
- [ ] If seller has exactly one restaurant, auto-selects and skips the selection screen
- [ ] Home tab loads with the restaurant's data

### 4.2 Multiple Restaurants
- [ ] All restaurants are listed
- [ ] Each entry shows name and status (PENDING/ACTIVE/INACTIVE)
- [ ] Tapping a restaurant selects it and navigates to home
- [ ] Selected restaurant persists across app restarts

### 4.3 Switch Restaurant (from Profile)
- [ ] Profile tab has an option to switch restaurants
- [ ] Switching opens the restaurant selection screen
- [ ] Selecting a different restaurant reloads orders, menu, and stats for that restaurant
- [ ] New selection is persisted in SharedPreferences

---

## 5. Home Dashboard

### 5.1 Stats Display
- [ ] Today's total orders count is shown
- [ ] Total revenue for today is shown
- [ ] Pending orders count is shown
- [ ] Stats update on pull-to-refresh

### 5.2 Quick Navigation
- [ ] Quick action shortcuts are present (e.g., "View Orders", "Add Item")
- [ ] Tapping a shortcut navigates to the correct screen

### 5.3 Loading & Error States
- [ ] Skeleton/loading indicator shown while stats load
- [ ] If stats fail to load, an error message is shown
- [ ] Retry is available on failure

---

## 6. Orders

### 6.1 Orders List — Tabs
- [ ] "All" tab shows all orders
- [ ] "Pending" tab shows only PENDING and SEARCHING_FOR_DRIVER orders
- [ ] "Active" tab shows only ACCEPTED, DRIVER_NOTIFICATION_SENT, ON_THE_WAY orders
- [ ] "Completed" tab shows only DELIVERED, REJECTED, CANCELLED orders
- [ ] Tab counts update after a status change

### 6.2 Orders List — Loading & Pagination
- [ ] Loading indicator shown on first load
- [ ] Scrolling to the bottom loads more orders (pagination)
- [ ] "No orders" empty state is shown when list is empty
- [ ] Pull-to-refresh reloads the list from the top

### 6.3 Orders List — Search
- [ ] Search bar is accessible
- [ ] Searching by order ID filters the list
- [ ] Searching by customer name filters the list
- [ ] Searching by customer phone filters the list
- [ ] Clearing the search restores the full list
- [ ] No results state is shown for a search with no matches

### 6.4 Order Details — Content
- [ ] Order ID is displayed
- [ ] Customer name, phone, and email are shown
- [ ] Delivery address is shown
- [ ] List of ordered items with quantities, customizations, and prices
- [ ] Total price is shown
- [ ] Applied coupon details are shown (if any)
- [ ] Assigned driver info is shown (if assigned)
- [ ] Order status timeline is shown

### 6.5 Order Status Transitions
- [ ] PENDING order shows "Accept" and "Reject" actions
- [ ] Tapping "Accept" transitions to SEARCHING_FOR_DRIVER (or ACCEPTED per backend logic)
- [ ] ACCEPTED order shows "Mark On The Way" action
- [ ] ON_THE_WAY order shows "Mark Delivered" action
- [ ] DELIVERED order shows no further transition actions
- [ ] CANCELLED / REJECTED orders show no transition actions
- [ ] Invalid transitions are not offered in the UI

### 6.6 Order Refund
- [ ] Refund option is accessible on a DELIVERED order
- [ ] Refund form requires amount and reason
- [ ] Submitting a valid refund calls `POST /api/orders/{id}/refund/`
- [ ] Loading indicator shown during refund request
- [ ] Success message shown on refund completion
- [ ] Error shown if refund fails

### 6.7 Create Order (Manual)
- [ ] "Create Order" button is accessible from the orders list
- [ ] Form includes: customer name, phone, address, item selection
- [ ] Address search uses Google Places (autocomplete works)
- [ ] At least one item must be selected before submitting
- [ ] Submitting calls `POST /api/seller/orders/manual/`
- [ ] New order appears in the orders list after creation

### 6.8 Scan Order (QR/Barcode)
- [ ] Camera permission is requested on first use
- [ ] Scanner opens and scans QR/barcode
- [ ] Scanned data is parsed using OCR / Gemini AI
- [ ] Verification screen shows parsed order details
- [ ] User can confirm or discard the scanned data
- [ ] Confirming adds the order to the system

### 6.9 Export Orders
- [ ] "Export to Excel" triggers download of `.xlsx` file
- [ ] "Export to PDF" triggers download of `.pdf` file
- [ ] Exported file contains current order data
- [ ] Error shown if export fails

---

## 7. Menu Management

### 7.1 Menu Items List
- [ ] All menu items for the selected restaurant are shown
- [ ] Each item shows name, price, and availability status
- [ ] Loading indicator on first load
- [ ] Pull-to-refresh works

### 7.2 Filtering & Search
- [ ] Category filter chips are shown
- [ ] Tapping a category filters items to that category only
- [ ] "All" category shows all items
- [ ] Search bar filters items by name in real-time
- [ ] Availability toggle filters to show only available / unavailable items
- [ ] Combined filters (category + search) work together

### 7.3 Add Menu Item — Happy Path
- [ ] "Add Item" button opens the add item screen
- [ ] Form fields: name, price, description, category, preparation time, availability toggle
- [ ] Image picker opens and image uploads to Cloudinary
- [ ] Multilingual fields (en/ar) are available and distinct
- [ ] Submitting valid data calls `POST /api/seller/items/`
- [ ] New item appears in the menu list

### 7.4 Add Menu Item — Validation
- [ ] Name (English): empty → validation error
- [ ] Price: empty → validation error
- [ ] Price: non-numeric → validation error
- [ ] Price: negative value → validation error
- [ ] Price: more than 2 decimal places → validation error or auto-truncation
- [ ] Category not selected → validation error or default

### 7.5 Edit Menu Item
- [ ] Tapping an existing item opens the edit form pre-populated with existing data
- [ ] All fields can be modified
- [ ] Saving calls `PATCH /api/seller/items/{id}/`
- [ ] Updated data appears in the list immediately

### 7.6 Item Availability Toggle
- [ ] Toggling availability from the list or detail calls the PATCH endpoint
- [ ] Toggle state is reflected immediately in the UI
- [ ] The filter respects the updated availability

### 7.7 Customization Options
- [ ] Customization options can be added to a menu item
- [ ] Addition type: adds price modifier (positive)
- [ ] Removal type: has 0 price modifier
- [ ] Each option can be toggled available/unavailable
- [ ] Options are saved with the item

### 7.8 Categories
- [ ] Categories list screen shows all categories with name and sort order
- [ ] "Add Category" form: name (en/ar), image, sort order, active toggle
- [ ] Saving creates category via `POST /api/seller/categories/`
- [ ] Editing a category pre-populates form and calls `PATCH /api/seller/categories/{id}/`
- [ ] Inactive categories are visually distinguished

---

## 8. Coupons

### 8.1 Coupons List
- [ ] All coupons for the selected restaurant are shown
- [ ] Each coupon shows: code, discount %, status (Active/Expired/Not Yet Active)
- [ ] Active coupons are visually distinct from expired ones
- [ ] Loading state shown on first load
- [ ] Empty state shown when no coupons exist

### 8.2 Add Coupon — Happy Path
- [ ] "Add Coupon" button navigates to the full-screen add form
- [ ] All fields present: title, code, discount %, min order price, max total usage, max per user, start date, end date, active toggle
- [ ] Code generator button creates a random UPPERCASE alphanumeric code
- [ ] Submitting valid data calls `POST /api/seller/coupons/`
- [ ] New coupon appears in the coupons list

### 8.3 Add Coupon — Validation
- [ ] Title: empty → validation error
- [ ] Code: empty → validation error
- [ ] Discount %: empty → validation error
- [ ] Discount %: value below 0 → validation error
- [ ] Discount %: value above 100 → validation error
- [ ] End date: before start date → validation error
- [ ] End date: in the past → validation error or warning
- [ ] Min order price: negative value → validation error

### 8.4 Edit Coupon
- [ ] Tapping a coupon opens the edit form pre-populated
- [ ] All fields are editable
- [ ] Saving calls `PATCH /api/seller/coupons/{id}/`
- [ ] Updated coupon is reflected in the list

### 8.5 Delete Coupon
- [ ] Delete action is accessible from coupon detail or list
- [ ] Confirmation dialog appears before deletion
- [ ] Confirming calls `DELETE /api/seller/coupons/{id}/`
- [ ] Coupon is removed from the list after deletion
- [ ] Cancelling the dialog leaves the coupon intact

### 8.6 Coupon Business Logic
- [ ] Coupon shows "Active" only when: isActive=true AND current date is between startDate and endDate
- [ ] Coupon shows "Not Yet Active" when startDate is in the future
- [ ] Coupon shows "Expired" when endDate is in the past
- [ ] Coupon shows "Max Usage Reached" when currentUsage >= maxTotalUsage

---

## 9. Profile & Settings

### 9.1 Profile Screen
- [ ] Seller name and phone number are displayed
- [ ] Restaurant name and status are shown
- [ ] Navigation links to all sub-sections are present

### 9.2 Restaurant Settings
- [ ] Restaurant settings screen shows current restaurant details
- [ ] Name, description, and other fields are editable
- [ ] Saving calls `PATCH /api/seller/restaurants/{id}/`
- [ ] (Note: profile editing is locked — this should be read-only or restricted appropriately)

### 9.3 Statistics Screen
- [ ] Revenue, order count, and customer metrics are displayed
- [ ] Data corresponds to the currently selected restaurant
- [ ] Loading state shown while data fetches

### 9.4 Language Selection
- [ ] Language screen lists supported languages: English, Arabic, German, French
- [ ] Selecting a language updates the app locale immediately
- [ ] App text changes to the selected language
- [ ] Selection persists across app restarts

### 9.5 Currency Selection
- [ ] Currency screen lists available currencies
- [ ] Selecting a currency updates price display throughout the app
- [ ] Selection persists

### 9.6 Notifications Settings
- [ ] Notification preference toggles are shown
- [ ] Toggling a preference saves the setting

### 9.7 Dark Mode / Theme
- [ ] Theme toggle is accessible in settings
- [ ] Toggling dark mode switches the UI theme
- [ ] Theme persists across restarts

### 9.8 Delete Account
- [ ] "Delete Account" is accessible in profile
- [ ] A confirmation dialog or multi-step confirmation appears
- [ ] Confirming triggers account deletion request
- [ ] User is logged out and redirected to login after deletion

---

## 10. Support Tickets

### 10.1 Tickets List
- [ ] All support tickets are listed
- [ ] Each ticket shows: subject, category, priority, status
- [ ] Status badges are colored (OPEN, IN_PROGRESS, RESOLVED, CLOSED)
- [ ] Loading state and empty state are handled

### 10.2 Create Ticket
- [ ] "Create Ticket" button opens the form
- [ ] Form fields: subject, category (ORDER/PAYMENT/DELIVERY/ACCOUNT/OTHER), priority (LOW/MEDIUM/HIGH/URGENT)
- [ ] Subject: empty → validation error
- [ ] Submitting valid data calls `POST /api/support/tickets/`
- [ ] New ticket appears in the list

### 10.3 Ticket Detail & Messaging
- [ ] Ticket subject, category, priority, and status are shown at the top
- [ ] Message thread is displayed chronologically
- [ ] Each message shows: author name, role (CUSTOMER/SELLER/STAFF), body, and timestamp
- [ ] Reply input field is accessible at the bottom
- [ ] Sending a reply calls `POST /api/support/tickets/{id}/messages/`
- [ ] New reply appears in the thread

### 10.4 Ticket Attachments
- [ ] Attaching an image to a reply is supported
- [ ] Image preview shown before sending
- [ ] Attachment is uploaded and visible in the thread

### 10.5 Ticket Filtering
- [ ] Filter by status works (OPEN, IN_PROGRESS, etc.)
- [ ] Filtered results update the list

---

## 11. Notifications

### 11.1 In-App Notifications List
- [ ] Notifications bell/icon is accessible from the home or profile area
- [ ] Notifications list shows all received notifications
- [ ] Unread notifications are visually distinct
- [ ] Tapping a notification marks it as read
- [ ] Loading and empty states are handled

### 11.2 Push Notifications (Real Device Required)
- [ ] App requests notification permission on first launch
- [ ] FCM token is registered with backend after login (`POST /api/notifications/device`)
- [ ] A new order notification arrives while app is in foreground → local notification shown
- [ ] A new order notification arrives while app is in background → system notification shown
- [ ] Tapping the system notification opens the order details screen
- [ ] Notification data (`order_id`, `type`) is correctly parsed for navigation

### 11.3 FCM Token Refresh
- [ ] If FCM token changes, the new token is re-registered with the backend
- [ ] No duplicate device registrations cause issues

---

## 12. Public Menu

### 12.1 Public Access (No Auth)
- [ ] `/public-menu/:restaurantId` loads without requiring login
- [ ] Restaurant name and basic info is shown
- [ ] All menu items are listed
- [ ] Categories are shown for filtering
- [ ] No edit/add/delete actions are exposed

---

## 13. Networking & Error Handling

### 13.1 Auth Token Refresh
- [ ] With an expired access token, any API call triggers an automatic refresh
- [ ] The original request is retried with the new token (user sees no error)
- [ ] If refresh token is also expired, user is redirected to `/login`

### 13.2 Network Unavailable
- [ ] With no internet, API calls fail gracefully
- [ ] User sees a connection error message (not a crash or blank screen)
- [ ] Retry button or pull-to-refresh works once internet is restored

### 13.3 Server Errors (5xx)
- [ ] 500-level errors display a user-friendly error message
- [ ] No raw error text or stack traces exposed to the user
- [ ] Retry is offered where appropriate

### 13.4 Unauthorized Access (401)
- [ ] A 401 triggers token refresh (not immediate logout)
- [ ] If refresh fails, user is sent to login
- [ ] No infinite retry loop occurs

### 13.5 Retry Interceptor
- [ ] Failed requests are retried up to 2 times automatically
- [ ] Retries do not trigger duplicate UI errors on each attempt

---

## 14. Navigation & Deep Links

### 14.1 Bottom Navigation
- [ ] Bottom navigation shows: Home, Orders, Menu, Profile tabs
- [ ] Tapping each tab navigates to the correct screen
- [ ] State is preserved when switching tabs (e.g., scroll position, search query)

### 14.2 Back Navigation
- [ ] Back button in nested screens returns to the parent screen
- [ ] Back button from the main tabs exits the app (or shows exit prompt on Android)
- [ ] No orphaned screens in the navigation stack

### 14.3 Deep Link — Order Notification
- [ ] Tapping a notification with `order_id` navigates to `orders/details/{order_id}`
- [ ] The order details screen loads the correct order

### 14.4 Route Guards
- [ ] Unauthenticated users cannot access `/home`, `/orders`, `/menu`, `/profile`
- [ ] Authenticated users are not sent back to `/login`
- [ ] Pending review users can only access `/pending-review` and `/knowledge-base`

---

## 15. Localization & RTL

### 15.1 Language Switching
- [ ] Switching to Arabic: all UI text updates
- [ ] Switching to German: all UI text updates
- [ ] Switching to French: all UI text updates
- [ ] Switching back to English: all UI text updates
- [ ] Date/number formats adapt to locale if applicable

### 15.2 RTL Layout (Arabic)
- [ ] With Arabic selected, layout direction becomes right-to-left
- [ ] Text aligns right
- [ ] Icons and navigation arrows are mirrored correctly
- [ ] Input fields accept Arabic text

### 15.3 Multilingual Model Fields
- [ ] Menu item names display in the selected language (fallback to English if not available)
- [ ] Category names display in the selected language
- [ ] Coupon titles display in the selected language

---

## 16. Performance & Edge Cases

### 16.1 Large Data Sets
- [ ] Menu with 50+ items: list scrolls smoothly without jank
- [ ] Orders list with 100+ orders: pagination loads more without freezing
- [ ] Notifications list with many items: scrolls smoothly

### 16.2 Image Loading
- [ ] Menu item images load (with placeholder while loading)
- [ ] Broken image URLs show a fallback/error image, not a blank space
- [ ] Image upload in add/edit item works end-to-end (pick → upload → preview → save)

### 16.3 Form State Preservation
- [ ] Navigating away from an in-progress form (e.g., add item) and returning: behaviour is clear (warn user or restore state)
- [ ] Rotating the device does not lose form data (or is explicitly handled)

### 16.4 Concurrent Actions
- [ ] Tapping "Send OTP" twice in quick succession does not send two requests
- [ ] Tapping "Submit" on any form while loading is disabled (button is disabled during request)

### 16.5 Empty Restaurant State
- [ ] If the restaurant has no menu items, an empty state is shown (not a blank list)
- [ ] If the restaurant has no orders, an empty state is shown
- [ ] If the restaurant has no coupons, an empty state is shown

---

## 17. Web Platform

> Run with `flutter run -d chrome -t lib/main_dev.dart --dart-define=ENV=dev`

### 17.1 Core Features on Web
- [ ] Login and OTP flow works in Chrome
- [ ] Home dashboard loads and shows stats
- [ ] Orders list loads and is scrollable
- [ ] Menu list loads and category filtering works
- [ ] Add/edit menu item form works (image upload may differ)

### 17.2 Web-Specific
- [ ] Push notification permission prompt behaves per browser restrictions (deferred to user gesture)
- [ ] No Flutter web-specific rendering issues (overlapping widgets, incorrect layouts)
- [ ] Browser back button integrates with GoRouter correctly

---

## Release Sign-Off

Before tagging a release, all sections above must be fully checked. Fill in this summary:

| Section | Status | Tester | Date |
|---------|--------|--------|------|
| 1. Startup & Splash | | | |
| 2. Authentication | | | |
| 3. Onboarding | | | |
| 4. Restaurant Selection | | | |
| 5. Home Dashboard | | | |
| 6. Orders | | | |
| 7. Menu Management | | | |
| 8. Coupons | | | |
| 9. Profile & Settings | | | |
| 10. Support Tickets | | | |
| 11. Notifications | | | |
| 12. Public Menu | | | |
| 13. Networking & Errors | | | |
| 14. Navigation | | | |
| 15. Localization & RTL | | | |
| 16. Performance & Edge Cases | | | |
| 17. Web Platform | | | |

**Known Issues / Notes:**

<!-- List any known failures, workarounds, or deferred items here -->

---

*Generated for TaybGo Seller — last updated 2026-04-03*
