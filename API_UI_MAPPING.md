# TaybatSeller App - API & UI Feature Mapping

## 📱 Current UI Features vs API Endpoints

### 🔐 Authentication
**UI Screens:**
- Login Screen (OTP phone-based)
- OTP Verification Screen
- Register Screen
- Forgot Password Screen

**Available APIs:**
- `POST /api/auth/otp/request/` - Request OTP
- `POST /api/auth/otp/verify/` - Verify OTP and get tokens
- `POST /api/auth/token/refresh/` - Refresh access token
- `POST /api/auth/token/blacklist/` - Logout

**Status:** ✅ Fully Connected

---

### 🏪 Restaurant Management
**UI Screens:**
- Restaurant Settings Screen (basic info editing)
- Profile Screen (displays restaurant name, owner email)

**Available APIs:**
- `GET /api/seller/restaurants/` - List seller's restaurants
- `POST /api/seller/restaurants/` - Create new restaurant
- `GET /api/seller/restaurants/{id}/` - Get details + today's stats
- `PUT /api/seller/restaurants/{id}/` - Update restaurant
- `PATCH /api/seller/restaurants/{id}/` - Partial update
- `DELETE /api/seller/restaurants/{id}/` - Delete restaurant

**Status:** 🔌 Needs Connection

---

### 🍔 Menu Items
**UI Screens:**
- Menu Screen (list items with filters by category)
- Add/Edit Menu Item Screen (full CRUD with image, price, description, ingredients, customizations)
- Menu Item Details Screen (view-only with toggle availability)

**Available APIs:**
- `GET /api/seller/items/?restaurant_id=<id>` - List items
- `POST /api/seller/items/?restaurant_id=<id>` - Create item
- `GET /api/seller/items/{id}/` - Get item details
- `PUT /api/seller/items/{id}/` - Update item
- `PATCH /api/seller/items/{id}/` - Partial update
- `DELETE /api/seller/items/{id}/` - Delete item
- `GET /api/seller/items/{id}/stats/` - Sales analytics (quantity, orders, revenue)

**Status:** 🔌 Needs Connection

---

### 📂 Categories
**UI Screens:**
- Categories Screen (reorderable list, CRUD operations)

**Available APIs:**
- `GET /api/seller/categories/?restaurant_id=<id>` - List categories
- `POST /api/seller/categories/?restaurant_id=<id>` - Create category
- `GET /api/seller/categories/{id}/` - Get details
- `PUT /api/seller/categories/{id}/` - Update category
- `PATCH /api/seller/categories/{id}/` - Partial update
- `DELETE /api/seller/categories/{id}/` - Delete category

**Status:** 🔌 Needs Connection

---

### 📦 Orders
**UI Screens:**
- Orders Screen (tabs: New/Active/Completed with counts)
- Order Details Screen (status timeline, customer info, payment summary)
- Create Order Screen (manual order creation for walk-ins)

**Available APIs:**
- `GET /api/seller/orders/` - List orders (paginated)
- `GET /api/seller/orders/{id}/` - Order details
- `POST /api/seller/orders/{id}/accept/` - Accept order
- `POST /api/seller/orders/{id}/status/` - Update status
- `POST /api/seller/orders/{order_id}/refund/` - Process refund
- `POST /api/seller/orders/manual/` - Log manual order
- `GET /api/seller/orders/export/excel/` - Export to Excel
- `GET /api/seller/orders/export/pdf/` - Export to PDF

**Status:** 🔌 Needs Connection

---

### 🎫 Coupons
**UI Screens:**
- Coupons Screen (list view)
- Add/Edit Coupon Screen (code, discount %, min order, usage limits, validity dates)

**Available APIs:**
- `GET /api/seller/coupons/` - List seller's coupons
- `POST /api/seller/coupons/` - Create coupon
- `GET /api/seller/coupons/{id}/` - Get details
- `PATCH /api/seller/coupons/{id}/` - Update coupon
- `DELETE /api/seller/coupons/{id}/` - Delete coupon

**Status:** 🔌 Needs Connection

---

### 👤 Profile & Settings
**UI Screens:**
- Profile Screen (restaurant info, quick stats, settings access)
- Settings Screen (theme, language, notifications)
- Statistics Screen (revenue and order analytics)
- Language Screen
- Currency Screen
- Notifications Screen
- Help Screen
- About Screen

**Available APIs:**
- `GET /api/me/` - Get user profile
- `PATCH /api/me/` - Update profile (name, phone, age)
- `PATCH /api/seller/profile/` - Update seller profile

**Status:** 🔌 Needs Connection for profile data

---

### 🏠 Dashboard
**UI Screens:**
- Home Screen (pending orders, today's revenue, total orders, quick actions)

**Available APIs:**
- `GET /api/seller/restaurants/{id}/` - Includes today's stats
- `GET /api/seller/orders/` - To fetch pending orders

**Status:** 🔌 Needs Connection

---

## 🆕 API Features NOT in UI

### 📊 Item Analytics
**API:** `GET /api/seller/items/{id}/stats/`
**Returns:** total_quantity, total_orders, total_revenue per item
**UI Status:** ❌ Not implemented

---

### 💰 Order Refunds
**API:** `POST /api/seller/orders/{order_id}/refund/`
**Params:** amount, reason, idempotency_key
**UI Status:** ❌ Not implemented (needs refund button in Order Details)

---

### 📤 Order Exports
**APIs:**
- `GET /api/seller/orders/export/excel/`
- `GET /api/seller/orders/export/pdf/`
**UI Status:** ❌ Not implemented (needs export buttons in Orders Screen)

---

### 🔔 Push Notifications
**API:** `POST /api/notifications/device`
**Params:** FCM device token
**UI Status:** ❌ Not implemented (needs Firebase FCM setup)

---

### 📍 Address Management
**APIs:**
- `GET /api/addresses/`
- `POST /api/addresses/`
- `PUT/PATCH/DELETE /api/addresses/{id}/`
**UI Status:** ⚠️ Partially implemented (Create Order Screen has address widget, but not connected)

---

### ⚖️ Legal & Config
**APIs:**
- `GET /api/config/legal` - Privacy policy, terms, support URLs
- `GET /api/config/version` - Version check for force updates
**UI Status:** ❌ Not implemented (needs version checking on app start)

---

### 💳 Payment Methods
**APIs:**
- `GET /api/payments/` - List payment methods
- `POST /api/payments/` - Add payment method
- `DELETE /api/payments/{id}/` - Remove payment method
**UI Status:** ❌ Not implemented

---

## 🔄 Required UI Changes to Connect APIs

### 1. Add `restaurant_id` Handling
**Issue:** Most seller endpoints require `?restaurant_id=<id>` query parameter
**Solution:**
- Store selected restaurant ID in global state after login
- Add restaurant selector if seller owns multiple restaurants
- Pass restaurant_id to all menu/category/order API calls

---

### 2. Add Image Upload Support
**Issue:** Menu items have image fields but UI just shows placeholder
**Solution:**
- Implement image picker (camera/gallery)
- Add image upload to server (multipart/form-data)
- Handle image URLs in menu item display

---

### 3. Update Models for API Schema
**Issue:** Current models use mock data structure
**Solution:**
- Update `MenuItemModel` to match API schema exactly
- Update `OrderModel` with all API fields (address, driver, status_history)
- Update `CategoryModel` with view_order field
- Update `CouponModel` with restaurant_id field

---

### 4. Implement Restaurant Selection Flow
**Issue:** Seller can own multiple restaurants, need to handle selection
**Solution:**
- After login, fetch `/api/seller/restaurants/`
- If multiple restaurants, show selector
- Store selected restaurant_id in Riverpod state
- Show restaurant switcher in AppBar

---

### 5. Add Missing UI Features
**Features to add:**
- Item Statistics Screen (connect to `/api/seller/items/{id}/stats/`)
- Refund Dialog in Order Details (connect to refund API)
- Export buttons in Orders Screen (Excel/PDF download)
- Payment Methods Screen
- Version Check on splash screen
- Push notification registration

---

### 6. Handle Order Status Flow
**Issue:** UI has simplified status flow, API has detailed driver statuses
**API Statuses:** PENDING, SEARCHING_FOR_DRIVER, DRIVER_NOTIFICATION_SENT, ACCEPTED, ON_THE_WAY, DELIVERED, COMPLETED, REJECTED, CANCELLED
**Solution:**
- Update `OrderStatus` enum to match API exactly
- Update status timeline in Order Details Screen
- Map statuses to appropriate UI display

---

### 7. Implement Proper Error Handling
**Solution:**
- Parse API error responses (400, 401, 403, 404, 500)
- Show user-friendly error messages
- Handle token expiration and refresh
- Add retry logic for failed requests

---

### 8. Add Pagination Support
**Issue:** API returns paginated responses with `count`, `next`, `previous`, `results`
**Solution:**
- Implement infinite scroll in list screens (Orders, Menu Items, Categories)
- Handle page loading states
- Show "Load More" buttons or auto-load on scroll

---

## 🛠️ Backend Changes Needed

### ❌ None Required!
**All necessary seller endpoints are now available in the API.**

Previous issues resolved:
- ✅ Seller coupons API added
- ✅ Restaurant management API added
- ✅ Seller profile API added
- ✅ Order refunds for sellers added
- ✅ Export functionality added

---

## 📋 Implementation Priority

### 🔴 CRITICAL (Core Business)
1. **Orders Integration** - Connect all order management APIs
2. **Menu Items Integration** - Connect menu CRUD operations
3. **Categories Integration** - Connect category management
4. **Restaurant Selection** - Handle multi-restaurant sellers
5. **Authentication Token Refresh** - Ensure sessions don't expire

### 🟡 HIGH PRIORITY (Business Value)
6. **Restaurant Details** - Fetch and display restaurant info
7. **Coupons Integration** - Connect coupon management
8. **Item Statistics** - Add analytics screen
9. **Order Refunds** - Add refund capability
10. **Image Upload** - Enable menu item photos

### 🟢 MEDIUM PRIORITY (Enhanced UX)
11. **Order Exports** - Excel/PDF download
12. **Push Notifications** - FCM integration
13. **Address Management** - Customer address CRUD
14. **Version Checking** - Force update mechanism
15. **Payment Methods** - Payment management UI

### ⚪ LOW PRIORITY (Nice to Have)
16. **Legal Pages** - Privacy/Terms display
17. **Pagination** - Infinite scroll for lists
18. **Advanced Filtering** - Date range, status filters on orders
