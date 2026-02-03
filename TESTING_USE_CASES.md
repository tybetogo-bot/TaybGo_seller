# TybeToGo Seller App - Comprehensive Testing Use Cases

## Table of Contents
1. [Authentication & User Management](#1-authentication--user-management)
2. [Restaurant Management](#2-restaurant-management)
3. [Order Management](#3-order-management)
4. [Menu Management](#4-menu-management)
5. [Coupon Management](#5-coupon-management)
6. [Push Notifications](#6-push-notifications)
7. [Tour System](#7-tour-system)
8. [Profile & Settings](#8-profile--settings)
9. [Public Menu](#9-public-menu)
10. [OCR Order Scanning](#10-ocr-order-scanning)
11. [Multi-Language Support](#11-multi-language-support)
12. [Network & Connectivity](#12-network--connectivity)
13. [Edge Cases & Error Handling](#13-edge-cases--error-handling)
14. [Performance & UI/UX](#14-performance--uiux)
15. [Integration Testing](#15-integration-testing)

---

## 1. Authentication & User Management

### 1.1 OTP Login Flow
- [ ] **TC-AUTH-001**: Launch app and verify splash screen appears
- [ ] **TC-AUTH-002**: Enter valid phone number and request OTP
- [ ] **TC-AUTH-003**: Verify OTP is received (check phone/logs in dev mode)
- [ ] **TC-AUTH-004**: Enter correct OTP and verify successful login
- [ ] **TC-AUTH-005**: Enter incorrect OTP and verify error message
- [ ] **TC-AUTH-006**: Try to login with invalid phone number format
- [ ] **TC-AUTH-007**: Request OTP multiple times rapidly (rate limiting test)
- [ ] **TC-AUTH-008**: Let OTP expire and try to use it
- [ ] **TC-AUTH-009**: Test OTP resend functionality

### 1.2 Token Management
- [ ] **TC-AUTH-010**: Verify JWT tokens are stored after successful login
- [ ] **TC-AUTH-011**: Close app and reopen - verify auto-login with stored tokens
- [ ] **TC-AUTH-012**: Test token refresh when near expiration (5-min threshold)
- [ ] **TC-AUTH-013**: Test behavior when access token expires during API call
- [ ] **TC-AUTH-014**: Test behavior when refresh token is invalid/expired

### 1.3 Logout
- [ ] **TC-AUTH-015**: Logout from profile screen
- [ ] **TC-AUTH-016**: Verify tokens are cleared from storage
- [ ] **TC-AUTH-017**: Verify refresh token is blacklisted on backend
- [ ] **TC-AUTH-018**: Try to use app after logout (should redirect to login)
- [ ] **TC-AUTH-019**: Login again after logout

### 1.4 Session Management
- [ ] **TC-AUTH-020**: Test unauthorized (401) error handling
- [ ] **TC-AUTH-021**: Login on multiple devices with same account
- [ ] **TC-AUTH-022**: Logout from one device and verify other device behavior

---

## 2. Restaurant Management

### 2.1 Restaurant Selection
- [ ] **TC-REST-001**: First-time user with no restaurant assigned
- [ ] **TC-REST-002**: Verify "No Restaurant" page appears with contact info
- [ ] **TC-REST-003**: User with single restaurant - auto-select
- [ ] **TC-REST-004**: User with multiple restaurants - show selection screen
- [ ] **TC-REST-005**: Switch between multiple restaurants
- [ ] **TC-REST-006**: Verify selected restaurant persists after app restart
- [ ] **TC-REST-007**: Test logout button from "No Restaurant" page

### 2.2 Restaurant Data Display
- [ ] **TC-REST-008**: Verify restaurant name, address, contact info display correctly
- [ ] **TC-REST-009**: Verify operating hours are shown
- [ ] **TC-REST-010**: Verify delivery fees and minimum order amounts
- [ ] **TC-REST-011**: Verify restaurant ratings display
- [ ] **TC-REST-012**: Check "Today's Statistics" on home screen (orders, revenue)

---

## 3. Order Management

### 3.1 Order Listing & Filtering
- [ ] **TC-ORD-001**: Navigate to Orders tab and view all orders
- [ ] **TC-ORD-002**: Filter orders by "Pending" status
- [ ] **TC-ORD-003**: Filter orders by "Active" status
- [ ] **TC-ORD-004**: Filter orders by "Completed" status
- [ ] **TC-ORD-005**: Search orders by Order ID
- [ ] **TC-ORD-006**: Search orders by customer name
- [ ] **TC-ORD-007**: Search orders by customer phone number
- [ ] **TC-ORD-008**: Search orders by menu item name
- [ ] **TC-ORD-009**: Test pagination - scroll to load more orders
- [ ] **TC-ORD-010**: Pull to refresh orders list

### 3.2 Real-Time Order Polling
- [ ] **TC-ORD-011**: Place new order from customer app - verify appears in seller app within 5 seconds
- [ ] **TC-ORD-012**: Verify polling interval (should check every 5 seconds)
- [ ] **TC-ORD-013**: Update order status on another device - verify auto-updates
- [ ] **TC-ORD-014**: Verify "silent refresh" - only UI updates when data changes
- [ ] **TC-ORD-015**: Test toggle polling on/off from settings
- [ ] **TC-ORD-016**: Verify polling pauses during tour
- [ ] **TC-ORD-017**: Navigate away from orders and back - verify polling resumes

### 3.3 Order Details View
- [ ] **TC-ORD-018**: Tap an order and view full details
- [ ] **TC-ORD-019**: Verify customer information displays (name, phone, address)
- [ ] **TC-ORD-020**: Verify order items with quantities and prices
- [ ] **TC-ORD-021**: Verify customizations (additions/removals) display correctly
- [ ] **TC-ORD-022**: Verify subtotal, delivery fee, discount, tax, and total calculations
- [ ] **TC-ORD-023**: Verify coupon information if applied
- [ ] **TC-ORD-024**: Verify order timestamp and ID
- [ ] **TC-ORD-025**: Verify current order status badge
- [ ] **TC-ORD-026**: View driver information when assigned
- [ ] **TC-ORD-027**: View delivery location on map (if available)

### 3.4 Order Status Updates
**Complete Status Flow:**
```
PENDING → SEARCHING_FOR_DRIVER → DRIVER_NOTIFICATION_SENT → ACCEPTED → ON_THE_WAY → DELIVERED → COMPLETED
```

- [ ] **TC-ORD-028**: Accept a PENDING order
- [ ] **TC-ORD-029**: Verify status changes to SEARCHING_FOR_DRIVER
- [ ] **TC-ORD-030**: Verify status changes to DRIVER_NOTIFICATION_SENT
- [ ] **TC-ORD-031**: Verify status changes to ACCEPTED when driver accepts
- [ ] **TC-ORD-032**: Update order to ON_THE_WAY status
- [ ] **TC-ORD-033**: Update order to DELIVERED status
- [ ] **TC-ORD-034**: Update order to COMPLETED status
- [ ] **TC-ORD-035**: Reject a PENDING order
- [ ] **TC-ORD-036**: Cancel an order with reason
- [ ] **TC-ORD-037**: Test canceling order without reason
- [ ] **TC-ORD-038**: Try to update status of already completed order
- [ ] **TC-ORD-039**: Verify status update notifications/feedback to user
- [ ] **TC-ORD-040**: Test rapid status updates (prevent double-tap issues)

### 3.5 Order Operations
- [ ] **TC-ORD-041**: Generate PDF receipt for an order
- [ ] **TC-ORD-042**: Print order receipt
- [ ] **TC-ORD-043**: Share order details
- [ ] **TC-ORD-044**: Copy order ID to clipboard
- [ ] **TC-ORD-045**: Call customer from order details
- [ ] **TC-ORD-046**: View customer delivery address on map

### 3.6 Order Edge Cases
- [ ] **TC-ORD-047**: Order with no items (should not exist, but test handling)
- [ ] **TC-ORD-048**: Order with very large quantity (e.g., 100 items)
- [ ] **TC-ORD-049**: Order with special characters in customer name/notes
- [ ] **TC-ORD-050**: Order with missing customer information
- [ ] **TC-ORD-051**: Order with invalid delivery address
- [ ] **TC-ORD-052**: Multiple orders arriving simultaneously
- [ ] **TC-ORD-053**: Order amount of ₹0 or negative (should be blocked)

---

## 4. Menu Management

### 4.1 Menu Item Listing
- [ ] **TC-MENU-001**: Navigate to Menu tab and view all menu items
- [ ] **TC-MENU-002**: Verify items are organized by categories
- [ ] **TC-MENU-003**: Verify item images load correctly
- [ ] **TC-MENU-004**: Verify item names, prices, and descriptions display
- [ ] **TC-MENU-005**: Test search functionality for menu items
- [ ] **TC-MENU-006**: Filter menu items by category
- [ ] **TC-MENU-007**: Test item availability toggle (available/unavailable)

### 4.2 Create Menu Item
- [ ] **TC-MENU-008**: Tap "Add Item" button
- [ ] **TC-MENU-009**: Upload image from gallery
- [ ] **TC-MENU-010**: Upload image from camera
- [ ] **TC-MENU-011**: Test without uploading image (should show placeholder)
- [ ] **TC-MENU-012**: Enter item name in English
- [ ] **TC-MENU-013**: Enter item name in multiple languages (AR, DE, FR)
- [ ] **TC-MENU-014**: Enter description
- [ ] **TC-MENU-015**: Set price (valid positive number)
- [ ] **TC-MENU-016**: Test invalid price inputs (negative, letters, special chars)
- [ ] **TC-MENU-017**: Add ingredients list
- [ ] **TC-MENU-018**: Set preparation time
- [ ] **TC-MENU-019**: Select category
- [ ] **TC-MENU-020**: Test creating item without required fields
- [ ] **TC-MENU-021**: Submit and verify item appears in list

### 4.3 Edit Menu Item
- [ ] **TC-MENU-022**: Edit existing item name
- [ ] **TC-MENU-023**: Change item image
- [ ] **TC-MENU-024**: Update price
- [ ] **TC-MENU-025**: Modify description and ingredients
- [ ] **TC-MENU-026**: Change category
- [ ] **TC-MENU-027**: Update translations for all languages
- [ ] **TC-MENU-028**: Save changes and verify updates reflect
- [ ] **TC-MENU-029**: Cancel editing without saving

### 4.4 Delete Menu Item
- [ ] **TC-MENU-030**: Delete a menu item
- [ ] **TC-MENU-031**: Verify confirmation dialog appears
- [ ] **TC-MENU-032**: Cancel deletion
- [ ] **TC-MENU-033**: Confirm deletion and verify item removed
- [ ] **TC-MENU-034**: Try to delete item that's in active orders

### 4.5 Customizations
- [ ] **TC-MENU-035**: Add customization to menu item (e.g., "Extra Cheese")
- [ ] **TC-MENU-036**: Set customization type: ADDITION
- [ ] **TC-MENU-037**: Set customization type: REMOVAL
- [ ] **TC-MENU-038**: Set price modifier for customization
- [ ] **TC-MENU-039**: Add multiple customizations to single item
- [ ] **TC-MENU-040**: Edit existing customization
- [ ] **TC-MENU-041**: Delete customization
- [ ] **TC-MENU-042**: Test customization with translations
- [ ] **TC-MENU-043**: Verify customizations appear in order details

### 4.6 Categories
- [ ] **TC-MENU-044**: View all categories
- [ ] **TC-MENU-045**: Create new category
- [ ] **TC-MENU-046**: Add category name in multiple languages
- [ ] **TC-MENU-047**: Edit category name
- [ ] **TC-MENU-048**: Reorder categories (change sort order)
- [ ] **TC-MENU-049**: Delete empty category
- [ ] **TC-MENU-050**: Try to delete category with items (should warn/prevent)
- [ ] **TC-MENU-051**: Verify category changes reflect in menu display

### 4.7 Menu Image Upload
- [ ] **TC-MENU-052**: Upload image under 5MB
- [ ] **TC-MENU-053**: Try to upload image over 5MB (should compress or reject)
- [ ] **TC-MENU-054**: Upload various formats (JPG, PNG, WebP)
- [ ] **TC-MENU-055**: Verify image uploads to Cloudinary
- [ ] **TC-MENU-056**: Verify image CDN URL is stored
- [ ] **TC-MENU-057**: Test image caching and loading speed
- [ ] **TC-MENU-058**: Test uploading corrupted/invalid image file

---

## 5. Coupon Management

### 5.1 Coupon Listing
- [ ] **TC-COUP-001**: Navigate to Profile → Coupons
- [ ] **TC-COUP-002**: View all coupons (active, expired, used)
- [ ] **TC-COUP-003**: Verify coupon details display (code, discount, dates)
- [ ] **TC-COUP-004**: Check coupon usage statistics
- [ ] **TC-COUP-005**: Filter coupons by status (active/expired)

### 5.2 Create Coupon
- [ ] **TC-COUP-006**: Tap "Create Coupon" button
- [ ] **TC-COUP-007**: Enter coupon code (alphanumeric)
- [ ] **TC-COUP-008**: Test invalid coupon codes (spaces, special chars)
- [ ] **TC-COUP-009**: Set discount percentage (0-100%)
- [ ] **TC-COUP-010**: Test invalid discount values (negative, >100%, letters)
- [ ] **TC-COUP-011**: Set start date (today or future)
- [ ] **TC-COUP-012**: Set end date (after start date)
- [ ] **TC-COUP-013**: Test invalid date ranges (end before start)
- [ ] **TC-COUP-014**: Set maximum total usage limit
- [ ] **TC-COUP-015**: Set per-user usage limit
- [ ] **TC-COUP-016**: Set minimum order price requirement
- [ ] **TC-COUP-017**: Add description in multiple languages
- [ ] **TC-COUP-018**: Submit and verify coupon is created

### 5.3 Edit Coupon
- [ ] **TC-COUP-019**: Edit coupon code
- [ ] **TC-COUP-020**: Change discount percentage
- [ ] **TC-COUP-021**: Update date range
- [ ] **TC-COUP-022**: Modify usage limits
- [ ] **TC-COUP-023**: Change minimum order price
- [ ] **TC-COUP-024**: Update translations
- [ ] **TC-COUP-025**: Save changes and verify updates

### 5.4 Delete Coupon
- [ ] **TC-COUP-026**: Delete unused coupon
- [ ] **TC-COUP-027**: Try to delete coupon that's been used (verify behavior)
- [ ] **TC-COUP-028**: Verify confirmation dialog

### 5.5 Coupon Validation (Backend Integration)
- [ ] **TC-COUP-029**: Apply valid coupon to order (from customer app)
- [ ] **TC-COUP-030**: Verify discount is calculated correctly
- [ ] **TC-COUP-031**: Try to apply expired coupon
- [ ] **TC-COUP-032**: Try to apply coupon that reached max usage
- [ ] **TC-COUP-033**: Try to apply coupon on order below minimum price
- [ ] **TC-COUP-034**: Apply coupon multiple times by same user (test per-user limit)
- [ ] **TC-COUP-035**: Apply invalid/non-existent coupon code

---

## 6. Push Notifications

### 6.1 FCM Setup & Token Registration
- [ ] **TC-NOTIF-001**: Fresh install - verify FCM token is generated
- [ ] **TC-NOTIF-002**: Verify device token is registered on backend
- [ ] **TC-NOTIF-003**: Test token refresh on app restart
- [ ] **TC-NOTIF-004**: Test token update when changed by Firebase

### 6.2 Notification Reception
- [ ] **TC-NOTIF-005**: Receive notification while app is in foreground
- [ ] **TC-NOTIF-006**: Receive notification while app is in background
- [ ] **TC-NOTIF-007**: Receive notification while app is closed/terminated
- [ ] **TC-NOTIF-008**: Verify local notification displays correctly
- [ ] **TC-NOTIF-009**: Test notification sound/vibration

### 6.3 Notification Types
- [ ] **TC-NOTIF-010**: Receive "New Order" notification
- [ ] **TC-NOTIF-011**: Receive "Order Status Update" notification
- [ ] **TC-NOTIF-012**: Receive "Driver Assigned" notification
- [ ] **TC-NOTIF-013**: Receive "Order Completed" notification
- [ ] **TC-NOTIF-014**: Receive "Order Cancelled" notification
- [ ] **TC-NOTIF-015**: Receive "Coupon Expiring" notification (if implemented)

### 6.4 Notification Interaction
- [ ] **TC-NOTIF-016**: Tap notification - verify navigates to correct screen
- [ ] **TC-NOTIF-017**: Tap "New Order" notification - opens order details
- [ ] **TC-NOTIF-018**: Dismiss notification without tapping
- [ ] **TC-NOTIF-019**: Test notification with invalid/missing order ID
- [ ] **TC-NOTIF-020**: Multiple notifications - test notification grouping

### 6.5 Notification History
- [ ] **TC-NOTIF-021**: View notification history in profile
- [ ] **TC-NOTIF-022**: Verify unread count badge
- [ ] **TC-NOTIF-023**: Mark notification as read
- [ ] **TC-NOTIF-024**: Mark all notifications as read
- [ ] **TC-NOTIF-025**: Verify read/unread status persists
- [ ] **TC-NOTIF-026**: Test notification list pagination/scrolling

### 6.6 Notification Permissions
- [ ] **TC-NOTIF-027**: Deny notification permission - verify app requests permission
- [ ] **TC-NOTIF-028**: Grant notification permission
- [ ] **TC-NOTIF-029**: Revoke permission from system settings - test app behavior
- [ ] **TC-NOTIF-030**: Test notification settings toggle in app

---

## 7. Tour System

### 7.1 Full App Tour (22 Steps)
- [ ] **TC-TOUR-001**: First-time user - verify tour starts automatically
- [ ] **TC-TOUR-002**: Tap "Start Tour" from profile/settings
- [ ] **TC-TOUR-003**: Navigate through all 22 steps using "Next" button
- [ ] **TC-TOUR-004**: Verify each step highlights correct UI element
- [ ] **TC-TOUR-005**: Verify step descriptions are clear and accurate
- [ ] **TC-TOUR-006**: Test auto-scroll functionality for off-screen elements
- [ ] **TC-TOUR-007**: Verify theme colors match app theme
- [ ] **TC-TOUR-008**: Complete full tour and verify completion is saved
- [ ] **TC-TOUR-009**: Skip tour at any step
- [ ] **TC-TOUR-010**: Restart tour after completion
- [ ] **TC-TOUR-011**: Test tour overlay tap handling (should not close tour)

### 7.2 Orders Quick Tour
- [ ] **TC-TOUR-012**: Start Orders Quick Tour
- [ ] **TC-TOUR-013**: Navigate through all steps
- [ ] **TC-TOUR-014**: Verify focuses on order-specific features
- [ ] **TC-TOUR-015**: Complete tour and verify saved

### 7.3 Menu Quick Tour
- [ ] **TC-TOUR-016**: Start Menu Quick Tour
- [ ] **TC-TOUR-017**: Navigate through all steps
- [ ] **TC-TOUR-018**: Verify focuses on menu-specific features
- [ ] **TC-TOUR-019**: Complete tour and verify saved

### 7.4 Tour Edge Cases
- [ ] **TC-TOUR-020**: Interrupt tour by pressing back button
- [ ] **TC-TOUR-021**: Receive notification during tour (verify polling is paused)
- [ ] **TC-TOUR-022**: Rotate device during tour
- [ ] **TC-TOUR-023**: Minimize app during tour and resume
- [ ] **TC-TOUR-024**: Test tour on different screen sizes (tablets, phones)
- [ ] **TC-TOUR-025**: Test tour with different system font sizes

---

## 8. Profile & Settings

### 8.1 User Profile Display
- [ ] **TC-PROF-001**: View user profile information
- [ ] **TC-PROF-002**: Verify name, email, phone display correctly
- [ ] **TC-PROF-003**: View user statistics (total orders, revenue)
- [ ] **TC-PROF-004**: View restaurant information

### 8.2 Language Settings
- [ ] **TC-PROF-005**: Change language to Arabic
- [ ] **TC-PROF-006**: Verify entire app UI switches to Arabic (RTL layout)
- [ ] **TC-PROF-007**: Change language to German
- [ ] **TC-PROF-008**: Verify app UI switches to German
- [ ] **TC-PROF-009**: Change language to French
- [ ] **TC-PROF-010**: Verify app UI switches to French
- [ ] **TC-PROF-011**: Change language to English
- [ ] **TC-PROF-012**: Verify language preference persists after restart
- [ ] **TC-PROF-013**: Test menu items display in selected language

### 8.3 Currency Settings
- [ ] **TC-PROF-014**: Change currency preference
- [ ] **TC-PROF-015**: Verify all prices update to new currency format
- [ ] **TC-PROF-016**: Test currency formatting (symbols, decimals)
- [ ] **TC-PROF-017**: Verify currency preference persists after restart

### 8.4 Notification Settings
- [ ] **TC-PROF-018**: View notification preferences
- [ ] **TC-PROF-019**: Toggle push notifications on/off
- [ ] **TC-PROF-020**: Toggle order polling on/off
- [ ] **TC-PROF-021**: Adjust polling interval
- [ ] **TC-PROF-022**: Verify settings are saved

### 8.5 About & Help
- [ ] **TC-PROF-023**: View About page (app version, terms, privacy)
- [ ] **TC-PROF-024**: Access Help/Knowledge Base
- [ ] **TC-PROF-025**: View FAQs
- [ ] **TC-PROF-026**: Contact support

### 8.6 Account Management
- [ ] **TC-PROF-027**: View account deletion option
- [ ] **TC-PROF-028**: Initiate account deletion
- [ ] **TC-PROF-029**: Cancel account deletion
- [ ] **TC-PROF-030**: Confirm account deletion and verify account is deleted
- [ ] **TC-PROF-031**: Try to login with deleted account

---

## 9. Public Menu

### 9.1 Public Menu Display
- [ ] **TC-PUB-001**: Generate/share public menu link
- [ ] **TC-PUB-002**: Open public menu link in browser
- [ ] **TC-PUB-003**: Verify restaurant name and info display
- [ ] **TC-PUB-004**: Verify menu items display correctly
- [ ] **TC-PUB-005**: Verify categories are shown
- [ ] **TC-PUB-006**: Verify item images load
- [ ] **TC-PUB-007**: Verify prices display
- [ ] **TC-PUB-008**: Test public menu on mobile browser
- [ ] **TC-PUB-009**: Test public menu on desktop browser
- [ ] **TC-PUB-010**: Verify public menu is read-only (no edit options)

### 9.2 Public Menu Sharing
- [ ] **TC-PUB-011**: Copy public menu link to clipboard
- [ ] **TC-PUB-012**: Share via WhatsApp
- [ ] **TC-PUB-013**: Share via SMS
- [ ] **TC-PUB-014**: Share via email
- [ ] **TC-PUB-015**: Generate QR code for public menu
- [ ] **TC-PUB-016**: Scan QR code and verify opens public menu

---

## 10. OCR Order Scanning

### 10.1 Image Capture
- [ ] **TC-OCR-001**: Navigate to Orders → Scan Order
- [ ] **TC-OCR-002**: Grant camera permission
- [ ] **TC-OCR-003**: Capture image of printed order form
- [ ] **TC-OCR-004**: Upload image from gallery
- [ ] **TC-OCR-005**: Test with clear, well-lit image
- [ ] **TC-OCR-006**: Test with blurry image
- [ ] **TC-OCR-007**: Test with low-light image
- [ ] **TC-OCR-008**: Test with angled/skewed image

### 10.2 OCR Text Recognition (Google ML Kit)
- [ ] **TC-OCR-009**: Verify text is extracted from image
- [ ] **TC-OCR-010**: Test with printed text
- [ ] **TC-OCR-011**: Test with handwritten text
- [ ] **TC-OCR-012**: Test with mixed printed/handwritten
- [ ] **TC-OCR-013**: Test with multiple languages
- [ ] **TC-OCR-014**: Verify extracted text is displayed for review

### 10.3 AI Parsing (Gemini AI)
- [ ] **TC-OCR-015**: Enable Gemini AI parsing
- [ ] **TC-OCR-016**: Verify AI extracts order details (items, quantities, prices)
- [ ] **TC-OCR-017**: Verify AI extracts customer information (name, phone)
- [ ] **TC-OCR-018**: Test with complex order (multiple items, customizations)
- [ ] **TC-OCR-019**: Test with simple order (single item)
- [ ] **TC-OCR-020**: Verify AI parsing accuracy

### 10.4 Order Verification & Submission
- [ ] **TC-OCR-021**: Review extracted order data
- [ ] **TC-OCR-022**: Edit extracted data if incorrect
- [ ] **TC-OCR-023**: Add missing information
- [ ] **TC-OCR-024**: Submit scanned order
- [ ] **TC-OCR-025**: Verify order appears in orders list
- [ ] **TC-OCR-026**: Verify order status is correct
- [ ] **TC-OCR-027**: Cancel/discard scanned order

### 10.5 OCR Edge Cases
- [ ] **TC-OCR-028**: Scan image with no text
- [ ] **TC-OCR-029**: Scan image with irrelevant text
- [ ] **TC-OCR-030**: Test OCR offline (should fail gracefully)
- [ ] **TC-OCR-031**: Test with very large image file
- [ ] **TC-OCR-032**: Test with corrupted image

---

## 11. Multi-Language Support

### 11.1 Language Switching
- [ ] **TC-LANG-001**: Switch to each supported language (EN, AR, DE, FR)
- [ ] **TC-LANG-002**: Verify UI text translates correctly
- [ ] **TC-LANG-003**: Verify button labels translate
- [ ] **TC-LANG-004**: Verify error messages translate
- [ ] **TC-LANG-005**: Verify success messages translate

### 11.2 RTL Layout (Arabic)
- [ ] **TC-LANG-006**: Switch to Arabic
- [ ] **TC-LANG-007**: Verify layout switches to RTL (right-to-left)
- [ ] **TC-LANG-008**: Verify icons flip/position correctly in RTL
- [ ] **TC-LANG-009**: Verify navigation flows right-to-left
- [ ] **TC-LANG-010**: Verify text alignment in RTL
- [ ] **TC-LANG-011**: Switch back to LTR language and verify layout

### 11.3 Content Translation
- [ ] **TC-LANG-012**: Verify menu items display in selected language
- [ ] **TC-LANG-013**: Verify categories display in selected language
- [ ] **TC-LANG-014**: Verify coupons display in selected language
- [ ] **TC-LANG-015**: Verify notifications display in selected language
- [ ] **TC-LANG-016**: Test content with missing translations (fallback behavior)

### 11.4 Date & Time Formatting
- [ ] **TC-LANG-017**: Verify dates format according to locale
- [ ] **TC-LANG-018**: Verify time format (12h vs 24h based on locale)
- [ ] **TC-LANG-019**: Verify order timestamps display correctly in all languages

### 11.5 Number & Currency Formatting
- [ ] **TC-LANG-020**: Verify number formatting per locale (commas, decimals)
- [ ] **TC-LANG-021**: Verify currency symbols and positions
- [ ] **TC-LANG-022**: Test large numbers (thousands, millions)
- [ ] **TC-LANG-023**: Test decimal places display correctly

---

## 12. Network & Connectivity

### 12.1 Network State Detection
- [ ] **TC-NET-001**: Start app with active internet connection
- [ ] **TC-NET-002**: Disable WiFi/mobile data during app usage
- [ ] **TC-NET-003**: Verify "No Internet" message appears
- [ ] **TC-NET-004**: Re-enable internet and verify connection restored
- [ ] **TC-NET-005**: Switch from WiFi to mobile data
- [ ] **TC-NET-006**: Switch from mobile data to WiFi

### 12.2 Offline Behavior
- [ ] **TC-NET-007**: Attempt to load orders offline
- [ ] **TC-NET-008**: Attempt to update order status offline
- [ ] **TC-NET-009**: Attempt to create menu item offline
- [ ] **TC-NET-010**: Verify cached data is shown when offline
- [ ] **TC-NET-011**: Queue actions when offline and sync when online

### 12.3 API Request Handling
- [ ] **TC-NET-012**: Test successful API requests (200 responses)
- [ ] **TC-NET-013**: Test 400 Bad Request errors
- [ ] **TC-NET-014**: Test 401 Unauthorized errors (token refresh)
- [ ] **TC-NET-015**: Test 403 Forbidden errors
- [ ] **TC-NET-016**: Test 404 Not Found errors
- [ ] **TC-NET-017**: Test 500 Internal Server errors
- [ ] **TC-NET-018**: Test network timeout errors
- [ ] **TC-NET-019**: Verify retry mechanism (max 2 retries)

### 12.4 Slow Network
- [ ] **TC-NET-020**: Test app on slow 2G network
- [ ] **TC-NET-021**: Verify loading indicators appear
- [ ] **TC-NET-022**: Test image loading on slow network
- [ ] **TC-NET-023**: Test timeout handling (30-second timeout)

### 12.5 Network Recovery
- [ ] **TC-NET-024**: Lose connection during API call - verify error handling
- [ ] **TC-NET-025**: Reconnect and retry failed request
- [ ] **TC-NET-026**: Verify pending data syncs after reconnection

---

## 13. Edge Cases & Error Handling

### 13.1 Empty States
- [ ] **TC-EDGE-001**: New restaurant with no orders - verify empty state
- [ ] **TC-EDGE-002**: Restaurant with no menu items - verify empty state
- [ ] **TC-EDGE-003**: No coupons created - verify empty state
- [ ] **TC-EDGE-004**: No notifications - verify empty state
- [ ] **TC-EDGE-005**: Search with no results - verify empty state

### 13.2 Input Validation
- [ ] **TC-EDGE-006**: Enter very long text in text fields (>1000 chars)
- [ ] **TC-EDGE-007**: Enter special characters in various fields
- [ ] **TC-EDGE-008**: Enter SQL injection attempts (should be sanitized)
- [ ] **TC-EDGE-009**: Enter XSS attempts (should be sanitized)
- [ ] **TC-EDGE-010**: Submit forms with only whitespace
- [ ] **TC-EDGE-011**: Test emoji input in text fields
- [ ] **TC-EDGE-012**: Test copy-paste of formatted text

### 13.3 Boundary Values
- [ ] **TC-EDGE-013**: Create menu item with price = ₹0
- [ ] **TC-EDGE-014**: Create menu item with price = ₹999999
- [ ] **TC-EDGE-015**: Create coupon with 0% discount
- [ ] **TC-EDGE-016**: Create coupon with 100% discount
- [ ] **TC-EDGE-017**: Order with 0 items (should be blocked)
- [ ] **TC-EDGE-018**: Order with 1000 items
- [ ] **TC-EDGE-019**: Test max image upload size

### 13.4 Race Conditions
- [ ] **TC-EDGE-020**: Rapidly tap "Accept Order" multiple times
- [ ] **TC-EDGE-021**: Update order status on two devices simultaneously
- [ ] **TC-EDGE-022**: Create multiple items with same name simultaneously
- [ ] **TC-EDGE-023**: Rapidly switch between restaurants
- [ ] **TC-EDGE-024**: Submit form multiple times rapidly

### 13.5 Data Consistency
- [ ] **TC-EDGE-025**: Update menu item price - verify reflects in new orders
- [ ] **TC-EDGE-026**: Delete menu item - verify behavior for existing orders
- [ ] **TC-EDGE-027**: Change restaurant details - verify updates everywhere
- [ ] **TC-EDGE-028**: Update coupon - verify doesn't affect past orders

### 13.6 Memory & Storage
- [ ] **TC-EDGE-029**: Test with 1000+ orders (large data sets)
- [ ] **TC-EDGE-030**: Test with 500+ menu items
- [ ] **TC-EDGE-031**: Test with 100+ notifications
- [ ] **TC-EDGE-032**: Verify app doesn't crash with large data
- [ ] **TC-EDGE-033**: Check local storage usage (SharedPreferences, Hive)
- [ ] **TC-EDGE-034**: Test behavior when storage is full

### 13.7 App State Management
- [ ] **TC-EDGE-035**: Minimize app and resume after long period
- [ ] **TC-EDGE-036**: Kill app and restart
- [ ] **TC-EDGE-037**: Test app state after force stop
- [ ] **TC-EDGE-038**: Verify state persists across app restarts

---

## 14. Performance & UI/UX

### 14.1 App Launch & Load Times
- [ ] **TC-PERF-001**: Measure cold start time (first launch)
- [ ] **TC-PERF-002**: Measure warm start time (restart)
- [ ] **TC-PERF-003**: Measure hot start time (resume)
- [ ] **TC-PERF-004**: Verify splash screen displays promptly
- [ ] **TC-PERF-005**: Test initial data load time (orders, menu)

### 14.2 Screen Navigation
- [ ] **TC-PERF-006**: Test navigation speed between tabs
- [ ] **TC-PERF-007**: Test deep link navigation
- [ ] **TC-PERF-008**: Test back button navigation
- [ ] **TC-PERF-009**: Verify smooth transitions/animations
- [ ] **TC-PERF-010**: Test navigation with large data sets

### 14.3 List Performance
- [ ] **TC-PERF-011**: Scroll through 100+ orders smoothly
- [ ] **TC-PERF-012**: Scroll through 100+ menu items smoothly
- [ ] **TC-PERF-013**: Test list rendering performance
- [ ] **TC-PERF-014**: Verify lazy loading/pagination works efficiently
- [ ] **TC-PERF-015**: Test search performance with large data sets

### 14.4 Image Loading
- [ ] **TC-PERF-016**: Verify images load progressively
- [ ] **TC-PERF-017**: Test image caching (cached images load instantly)
- [ ] **TC-PERF-018**: Test placeholder images appear while loading
- [ ] **TC-PERF-019**: Test image loading on slow network
- [ ] **TC-PERF-020**: Verify no memory leaks from images

### 14.5 Memory Management
- [ ] **TC-PERF-021**: Monitor memory usage during normal operation
- [ ] **TC-PERF-022**: Test memory usage with many images loaded
- [ ] **TC-PERF-023**: Verify no memory leaks after extended use
- [ ] **TC-PERF-024**: Test app with low memory conditions

### 14.6 Battery Consumption
- [ ] **TC-PERF-025**: Monitor battery drain during active use
- [ ] **TC-PERF-026**: Monitor battery drain with background polling
- [ ] **TC-PERF-027**: Monitor battery drain with push notifications

### 14.7 UI Responsiveness
- [ ] **TC-PERF-028**: Verify all buttons respond immediately (<100ms)
- [ ] **TC-PERF-029**: Test typing responsiveness in text fields
- [ ] **TC-PERF-030**: Verify no UI freezing during API calls
- [ ] **TC-PERF-031**: Test UI during heavy operations (image upload)
- [ ] **TC-PERF-032**: Verify loading indicators appear for slow operations

### 14.8 Animations & Transitions
- [ ] **TC-PERF-033**: Verify 60 FPS during animations
- [ ] **TC-PERF-034**: Test shimmer loading animations
- [ ] **TC-PERF-035**: Test fade-in animations for images
- [ ] **TC-PERF-036**: Test page transition animations

### 14.9 Accessibility
- [ ] **TC-PERF-037**: Test with large system font size
- [ ] **TC-PERF-038**: Test with screen reader (TalkBack/VoiceOver)
- [ ] **TC-PERF-039**: Test color contrast for readability
- [ ] **TC-PERF-040**: Verify all interactive elements have proper labels

---

## 15. Integration Testing

### 15.1 End-to-End Workflows
- [ ] **TC-INT-001**: Complete order lifecycle from new order to completion
  1. Receive new order notification
  2. Accept order
  3. Update to ON_THE_WAY
  4. Update to DELIVERED
  5. Complete order
  6. Verify statistics update

- [ ] **TC-INT-002**: Complete menu creation to order workflow
  1. Create new menu item
  2. Customer places order with that item
  3. Accept order
  4. Verify item details are correct
  5. Complete order

- [ ] **TC-INT-003**: Coupon creation to usage workflow
  1. Create coupon
  2. Customer applies coupon
  3. Verify discount in order
  4. Complete order
  5. Check coupon usage count

- [ ] **TC-INT-004**: Multi-language workflow
  1. Change language to Arabic
  2. Create menu item with Arabic name
  3. Change to English
  4. Verify both names display
  5. Place order and verify translations

- [ ] **TC-INT-005**: OCR to order completion workflow
  1. Scan order form
  2. Verify extracted data
  3. Submit order
  4. Accept and complete order
  5. Generate PDF receipt

### 15.2 Multi-Restaurant Workflow
- [ ] **TC-INT-006**: Switch restaurants mid-workflow
  1. Start with Restaurant A
  2. View orders
  3. Switch to Restaurant B
  4. Verify only Restaurant B orders shown
  5. Switch back to Restaurant A

### 15.3 Simultaneous Operations
- [ ] **TC-INT-007**: Accept order while creating menu item
- [ ] **TC-INT-008**: Receive notification while viewing order details
- [ ] **TC-INT-009**: Update order status while receiving new order
- [ ] **TC-INT-010**: Create coupon while orders are being placed

### 15.4 Background Processing
- [ ] **TC-INT-011**: Minimize app with active polling - verify continues
- [ ] **TC-INT-012**: Receive push notification while app in background
- [ ] **TC-INT-013**: Token refresh while app in background
- [ ] **TC-INT-014**: Resume app after background - verify state restored

### 15.5 Cross-Device Scenarios
- [ ] **TC-INT-015**: Login on Device A, update order status, verify updates on Device B
- [ ] **TC-INT-016**: Create menu item on Device A, verify appears on Device B
- [ ] **TC-INT-017**: Logout on Device A, verify Device B handles gracefully
- [ ] **TC-INT-018**: Update same order on two devices simultaneously (conflict test)

---

## Testing Checklist Summary

### Device Coverage
- [ ] Test on Android (minimum supported version)
- [ ] Test on Android (latest version)
- [ ] Test on iOS (minimum supported version)
- [ ] Test on iOS (latest version)
- [ ] Test on tablet (Android/iPad)
- [ ] Test on different screen sizes (small, medium, large)

### Network Coverage
- [ ] Test on WiFi
- [ ] Test on 4G/LTE
- [ ] Test on 3G
- [ ] Test on 2G (slow network)
- [ ] Test switching between network types
- [ ] Test offline scenarios

### Environment Coverage
- [ ] Test in development environment
- [ ] Test in staging environment
- [ ] Test in production environment
- [ ] Test with mock data
- [ ] Test with real data

### User Scenarios
- [ ] First-time user (onboarding)
- [ ] Returning user (normal usage)
- [ ] Power user (heavy usage)
- [ ] User with no restaurants
- [ ] User with single restaurant
- [ ] User with multiple restaurants
- [ ] User with large data sets (many orders, menu items)

---

## Critical Path Testing (Must-Pass Scenarios)

These are the most critical workflows that MUST work for the app to be functional:

1. **Authentication Flow**: Login with OTP → Success
2. **Accept Order**: Receive order → Accept → Update Status → Complete
3. **View Orders**: Navigate to orders → Filter by status → View details
4. **Create Menu Item**: Add item → Upload image → Set price → Save
5. **Push Notifications**: Receive notification → Tap → Navigate to order
6. **Real-time Polling**: New order appears automatically within 5 seconds
7. **Multi-language**: Switch language → Verify UI updates
8. **Token Refresh**: Session continues seamlessly without re-login

---

## Bug Reporting Template

When you find a bug, document it with:

**Bug ID**: [Unique identifier]
**Test Case**: [TC-XXX-XXX]
**Severity**: [Critical/High/Medium/Low]
**Device**: [Device model, OS version]
**Network**: [WiFi/4G/Offline]

**Steps to Reproduce**:
1. Step 1
2. Step 2
3. Step 3

**Expected Result**: [What should happen]
**Actual Result**: [What actually happens]
**Screenshots**: [Attach if applicable]
**Logs**: [Include error logs]

**Additional Notes**: [Any other relevant information]

---

## Testing Schedule Recommendation

### Phase 1: Core Functionality (Day 1-2)
- Authentication & User Management
- Order Management (all workflows)
- Restaurant Management

### Phase 2: Content Management (Day 3-4)
- Menu Management (CRUD operations)
- Coupon Management
- Multi-language Support

### Phase 3: Notifications & Real-time (Day 5)
- Push Notifications
- Real-time Order Polling
- Tour System

### Phase 4: Advanced Features (Day 6-7)
- OCR Order Scanning
- Public Menu
- Profile & Settings

### Phase 5: Integration & Edge Cases (Day 8-9)
- Integration Testing
- Edge Cases & Error Handling
- Network & Connectivity

### Phase 6: Performance & Polish (Day 10)
- Performance Testing
- UI/UX Testing
- Final Regression Testing

---

## Automated Testing Recommendations

Consider implementing automated tests for:
- Unit tests for business logic (repositories, notifiers)
- Widget tests for UI components
- Integration tests for critical workflows
- Golden tests for pixel-perfect UI
- Performance benchmarks

Suggested frameworks:
- Flutter Test (built-in)
- Mockito for mocking
- Integration Test package
- Golden Toolkit for screenshot testing

---

**Total Test Cases**: 350+ comprehensive test scenarios

**Estimated Testing Time**: 10-15 days for complete manual testing

**Priority Focus**: Start with Critical Path Testing, then expand to all scenarios.
