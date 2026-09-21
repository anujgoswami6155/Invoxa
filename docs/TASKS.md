# Invoxa — Master Development Tasks & Roadmap

This file tracks the project's development roadmap, module milestones, current sprint tasks, and parked items.

---

## 1. High-Level Milestone Tracker

| Module / Phase | Branch | Status | Description |
|---|---|---|---|
| **Phase 1: Authentication & User Profile** | `feature/authentication` | ✅ **Completed** | Full auth lifecycle (register, login, verify email, forgot password, `AuthGate`, `users/{uid}`). |
| **Phase 2: Dashboard UI (Mock Data)** | `feature/dashboard` | 🟡 **In Progress** | Professional dashboard layout with KPI cards, quick actions, and recent invoices. |
| **Phase 3: Customer Management** | `feature/customers` | ⚪ **Planned** | Customer CRUD, client details, billing address, and history. |
| **Phase 4: Product & Service Catalog** | `feature/products` | ⚪ **Planned** | Catalog CRUD, pricing, units of measure, descriptions. |
| **Phase 5: Invoice Management** | `feature/invoices` | ⚪ **Planned** | Invoice builder, line items, auto-calculations, status tracking. |
| **Phase 6: Payment Tracking** | `feature/payments` | ⚪ **Planned** | Payment capture against invoices, balance updates, payment ledger. |
| **Phase 7: Dashboard Real Data Integration** | `feature/dashboard` | ⚪ **Planned** | Connect dashboard KPIs and recent lists to live Firestore providers. |
| **Phase 8: Storage, PDF & Export** | `feature/invoicing-tools` | ⚪ **Planned** | PDF generation, sharing, logo upload via Firebase Storage. |

---

## 2. Detailed Task Breakdown

### Phase 1: Authentication & Foundation (COMPLETED)
- [x] Set up Flutter project with null safety.
- [x] Configure Firebase with platform credentials (`lib/firebase_options.dart`).
- [x] Implement `UserModel` with serialization (`lib/models/user_model.dart`).
- [x] Implement `AuthService` wrapping `FirebaseAuth` (`lib/services/auth_service.dart`).
- [x] Implement `UserService` wrapping `users/{uid}` in Firestore (`lib/services/user_service.dart`).
- [x] Implement `AuthProvider` (`lib/providers/auth_provider.dart`).
- [x] Build `LoginScreen` (`lib/screens/auth/login_screen.dart`).
- [x] Build `RegisterScreen` (`lib/screens/auth/register_screen.dart`).
- [x] Build `VerifyEmailScreen` with resend functionality (`lib/screens/auth/verify_email_screen.dart`).
- [x] Build `ForgotPasswordScreen` (`lib/screens/auth/forgot_password_screen.dart`).
- [x] Build reactive `AuthGate` router (`lib/screens/auth/auth_gate.dart`).

---

### Phase 2: Dashboard UI (`feature/dashboard`) — IMMEDIATE TASK

> **Important:** At this stage, dashboard values are mock/static placeholders. Do NOT connect Firestore queries yet.

- [x] **Step 1: Base Screen Setup**
  - [x] Create `lib/screens/dashboard/dashboard_screen.dart`.
- [x] **Step 2: Dashboard Shell & Header**
  - [x] Light background `#F7F8FA`.
  - [x] Clean white `AppBar` with Invoxa title and notification icon button.
  - [x] "Welcome back 👋" greeting and subtitle.
  - [x] Scrollable content wrapper (`SingleChildScrollView`).
- [ ] **Step 3: Summary / KPI Cards (NEXT UP)**
  - [ ] Extract reusable `DashboardStatCard` widget (or create `lib/widgets/dashboard_stat_card.dart`).
  - [ ] Implement Customers card (e.g. `25` with user icon).
  - [ ] Implement Products card (e.g. `48` with inventory icon).
  - [ ] Implement Invoices card (e.g. `32` with invoice icon).
  - [ ] Implement Revenue card (e.g. `₹45,000` with wallet/currency icon).
  - [ ] Configure responsive 2x2 grid layout.
- [ ] **Step 4: Quick Action Section**
  - [ ] "Quick Actions" section header.
  - [ ] "Add Customer" action card/button.
  - [ ] "Add Product" action card/button.
  - [ ] "Create Invoice" emphasized action card/button.
- [ ] **Step 5: Recent Invoices Section**
  - [ ] "Recent Invoices" section header with "View All" button.
  - [ ] Preview list cards showing invoice number (`INV-001`), customer name, formatted amount, and status chip (`Paid`, `Pending`).
- [ ] **Step 6: Responsive Layout & Visual Polish**
  - [ ] Verify padding, elevation, corner radii, and color consistency per `DESIGN.md`.
  - [ ] Run `flutter analyze` and ensure 0 errors/warnings.
- [ ] **Step 7: Connect Dashboard to AuthGate**
  - [ ] Verify seamless transition from email verification to dashboard upon successful verification.

---

### Phase 3: Customer Module (`feature/customers`)
- [ ] Create `lib/models/customer_model.dart`.
- [ ] Create `lib/services/customer_service.dart` with user-scoped Firestore queries.
- [ ] Create `lib/providers/customer_provider.dart`.
- [ ] Build `CustomersScreen` (list & search).
- [ ] Build `AddCustomerScreen` (form with validation).
- [ ] Build `CustomerDetailsScreen` (profile & invoice history).
- [ ] Create `lib/widgets/customer_card.dart`.

---

### Phase 4: Product / Service Module (`feature/products`)
- [ ] Create `lib/models/product_model.dart`.
- [ ] Create `lib/services/product_service.dart`.
- [ ] Create `lib/providers/product_provider.dart`.
- [ ] Build `ProductsScreen` (catalog list).
- [ ] Build `AddProductScreen` (item details, price, unit type).

---

### Phase 5: Invoice Module (`feature/invoices`)
- [ ] Create `lib/models/invoice_model.dart` and `invoice_item_model.dart`.
- [ ] Create `lib/services/invoice_service.dart`.
- [ ] Create `lib/providers/invoice_provider.dart` (subtotal, tax, and discount computations).
- [ ] Build `CreateInvoiceScreen` (customer picker, line item picker, quantity, notes).
- [ ] Build `InvoicesScreen` (filtering by status: `Draft`, `Pending`, `Paid`, `Overdue`).
- [ ] Build `InvoiceDetailsScreen` (breakdown, share trigger).

---

### Phase 6: Payment Module (`feature/payments`)
- [ ] Create `lib/models/payment_model.dart`.
- [ ] Create `lib/services/payment_service.dart`.
- [ ] Create `lib/providers/payment_provider.dart`.
- [ ] Build `RecordPaymentScreen` (amount, payment method, date).
- [ ] Implement automatic invoice status updates (`Partially Paid`, `Paid`).

---

### Phase 7: Real Dashboard Data Integration
- [ ] Replace mock KPI numbers with aggregated totals from Firestore streams/queries.
- [ ] Feed real recent invoices list into `DashboardScreen`.
- [ ] Wire Quick Action buttons to appropriate screens.

---

## 3. Parked Issues & Known Bugs

- **Issue #1 — Firebase-hosted Action Links Expired Error:**
  - *Symptom:* Verification and password reset emails arrive successfully, but opening the link in a desktop browser throws an "expired or already used" Firebase Auth page error.
  - *Status:* **Parked.** Client-side Flutter dispatch and state handling are complete. Will be resolved during backend deep-dive.
