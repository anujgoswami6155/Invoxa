# Invoxa — Master Development Tasks & Roadmap

This file tracks the project's development roadmap, module milestones, current sprint tasks, and parked items.

---

## 1. High-Level Milestone Tracker

| Module / Phase | Branch | Status | Description |
|---|---|---|---|
| **Phase 1: Authentication & User Profile** | `feature/authentication` | ✅ **Completed** | Full auth lifecycle (register, login, verify email, forgot password, `AuthGate`, `users/{uid}`). |
| **Phase 2: Dashboard UI** | `feature/dashboard` | ✅ **Completed** | Professional oceanic dashboard layout with KPI cards, quick actions, and recent invoices. |
| **Phase 3: Customer Management** | `feature/customers` | ✅ **Completed** | Customer CRUD, client details, billing address, search & filtering, and phone/email actions. |
| **Phase 4: Product & Service Catalog** | `feature/products` | ✅ **Completed** | Catalog CRUD, pricing, units of measure, goods vs services, descriptions. |
| **Phase 5: Invoice Management** | `feature/invoice` | ✅ **Completed** | Invoice builder, line items, auto-calculations, status tracking (`Draft`, `Pending`, `Partially Paid`, `Paid`, `Overdue`, `Cancelled`). |
| **Phase 6: Payment Tracking** | `feature/payments` | ✅ **Completed** | Payment capture against invoices, balance recalculations, payment method logging, payment history ledger. |
| **Phase 7: Dashboard Real Data Integration** | `feature/dashboard` | ✅ **Completed** | Connected dashboard KPIs, revenue analytics, outstanding balances, and recent invoice feeds to live Firestore providers. |
| **Phase 8: Storage, PDF & Export** | `feature/invoicing-tools` | ✅ **Completed** | Professional A4 PDF generation, print preview dialog, multi-platform direct download (Web/Windows/macOS/Linux/Android). |

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
- [x] Build `SignInScreen` (`lib/screens/auth/sign_in_screen.dart`).
- [x] Build `RegisterScreen` (`lib/screens/auth/register_screen.dart`).
- [x] Build `VerifyEmailScreen` with resend functionality (`lib/screens/auth/verify_email_screen.dart`).
- [x] Build `ForgotPasswordScreen` (`lib/screens/auth/forgot_password_screen.dart`).
- [x] Build reactive `AuthGate` router (`lib/screens/auth/auth_gate.dart`).

---

### Phase 2: Dashboard UI (`feature/dashboard`) (COMPLETED)
- [x] **Step 1: Base Screen Setup**
  - [x] Create `lib/screens/dashboard/dashboard_screen.dart`.
- [x] **Step 2: Dashboard Shell & Header**
  - [x] Oceanic Charcoal & Pure Black canvas with crisp white headers and navigation.
  - [x] Clean header with Invoxa logo, business suite badge, and logout action.
  - [x] Time-based greeting ("Good morning / afternoon / evening") with business name.
  - [x] Scrollable content wrapper (`SingleChildScrollView`).
- [x] **Step 3: Summary / KPI Cards**
  - [x] Total revenue collected KPI card.
  - [x] Total outstanding amount alert card.
  - [x] Invoices count card.
  - [x] Paid invoices count card.
  - [x] Pending & overdue invoices count card.
- [x] **Step 4: Quick Action Section**
  - [x] Quick actions sheet: "New Invoice", "Add Customer", "Add Product / Service".
- [x] **Step 5: Recent Invoices Section**
  - [x] Recent Invoices section header with "View All" button.
  - [x] Preview cards showing invoice number (`INV-0001`), customer name, date, formatted amounts, and colored status chips.
- [x] **Step 6: Responsive Layout & Visual Polish**
  - [x] Verify padding, elevation, corner radii, and color consistency per `DESIGN.md`.
  - [x] Run `flutter analyze` and ensure 0 errors/warnings.
- [x] **Step 7: Connect Dashboard to AuthGate**
  - [x] Verify seamless transition from email verification to dashboard upon successful verification.

---

### Phase 3: Customer Module (`feature/customers`) (COMPLETED)
- [x] Create `lib/models/customer_model.dart`.
- [x] Create `lib/services/customer_service.dart` with user-scoped Firestore queries.
- [x] Create `lib/providers/customer_provider.dart` with in-memory caching, search, and real-time list updates.
- [x] Build `CustomersScreen` (list, live search query filtering, and customer statistics).
- [x] Build `AddCustomerScreen` (form with validation for name, email, phone, and billing address).
- [x] Build Customer Details modal (contact shortcuts, copy to clipboard, and edit/delete actions).

---

### Phase 4: Product / Service Module (`feature/products`) (COMPLETED)
- [x] Create `lib/models/product_model.dart`.
- [x] Create `lib/services/product_service.dart`.
- [x] Create `lib/providers/product_provider.dart`.
- [x] Build `ProductsScreen` (catalog list, category filters: `All`, `Physical Good`, `Hourly Service`, and search).
- [x] Build `AddProductScreen` (item name, description, unit price in ₹, item type, and unit of measure).

---

### Phase 5: Invoice Module (`feature/invoice`) (COMPLETED)
- [x] Create `lib/models/invoice_model.dart` and `invoice_item_model.dart`.
- [x] Create `lib/services/invoice_service.dart`.
- [x] Create `lib/providers/invoice_provider.dart` (subtotal, tax rate, and discount computations).
- [x] Build `CreateInvoiceScreen` (customer picker bottom sheet, quick-add item, item picker, date pickers, notes, auto-number generation `INV-0001`).
- [x] Build `InvoicesScreen` (filtering by status: `Draft`, `Pending`, `Paid`, `Overdue`, live search).
- [x] Build `InvoiceDetailsScreen` (itemized breakdown, balance summary, PDF trigger, payment recording, and delete invoice).

---

### Phase 6: Payment Module (`feature/payments`) (COMPLETED)
- [x] Create `InvoicePaymentModel` entity.
- [x] Implement payment recording in `InvoiceService` with validation against balance due.
- [x] Implement `recordPayment` in `InvoiceProvider`.
- [x] Build Record Payment dialog (custom amount input, 50% quick chip, full payment quick chip, payment methods: Bank Transfer, UPI, Cash, Cheque, Card).
- [x] Implement automatic invoice status transitions (`Partially Paid`, `Paid`).

---

### Phase 7: Real Dashboard Data Integration (COMPLETED)
- [x] Connect live aggregated totals (Revenue, Outstanding, Counts) from Firestore providers.
- [x] Feed real recent invoices list into `DashboardScreen`.
- [x] Wire Quick Action bottom sheet buttons to appropriate screens.

---

### Phase 8: PDF Generation, Print & Export (COMPLETED)
- [x] Implement `InvoicePdfService` generating standard clean A4 invoices.
- [x] Implement `pdf_downloader` with cross-platform support (Web blob download, Windows/macOS/Linux native file save and launch).
- [x] Integrate Print / Export PDF action dialog in `InvoiceDetailsScreen`.

---

## 3. Parked Issues & Known Bugs

- **Issue #1 — Firebase-hosted Action Links Expired Error:**
  - *Symptom:* Verification and password reset emails arrive successfully, but opening the link in a desktop browser throws an "expired or already used" Firebase Auth page error.
  - *Status:* **Parked.** Client-side Flutter dispatch and state handling are complete. Will be resolved during backend deep-dive.
