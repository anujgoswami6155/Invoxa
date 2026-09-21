# Invoxa — Product Requirements Document (PRD)

## 1. Executive Summary

**Invoxa** is a cross-platform mobile and desktop application built with Flutter and Firebase, designed specifically for small businesses, freelancers, and independent contractors. Invoxa streamlines and simplifies the complete business lifecycle: managing clients, tracking goods/services, generating professional invoices, calculating taxes and totals, recording payments, and monitoring business health through actionable dashboard metrics.

---

## 2. Problem Statement

Small businesses, solo practitioners, and freelancers frequently struggle with fragmented or overly complex invoicing workflows. Existing enterprise accounting and invoicing suites are often:
- **Overly complicated:** Packed with complex enterprise accounting modules, double-entry bookkeeping ledgers, and steep learning curves.
- **Fragmented:** Requiring separate tools for customer contacts, invoice creation, and payment tracking.
- **Slow & Cumbersome:** Time-consuming workflows to create a straightforward bill for services rendered or items sold.

**Invoxa solves this** by offering a focused, secure, intuitive, and responsive application where users can manage their core billing pipeline effortlessly in one place.

---

## 3. Product Vision & Value Proposition

> **"Provide a simple, organized, secure invoicing system for small businesses and independent users."**

### Core Value Drivers
- **Simplicity First:** Intuitive UI requiring minimal taps to create customers, log products, and issue invoices.
- **Total Data Privacy & Scoping:** Multi-tenant security where every record is strictly scoped to the authenticated user.
- **Lifecycle Cohesion:** Seamless transition from customer and product catalogs to invoice drafting, payment capture, and status updates.
- **Real-Time Visibility:** At-a-glance business performance via summary cards and recent activity directly on the dashboard.

---

## 4. Target Personas

| Persona | Role | Primary Need |
|---|---|---|
| **Freelancer / Consultant** | Creative, Developer, Writer | Bill clients for billable hours or flat project fees quickly and track payment receipt. |
| **Trade & Service Provider** | Electrician, Plumber, Mechanic | Generate invoices on mobile, itemize parts and labor, and monitor outstanding dues. |
| **Small Retailer / Solo Vendor** | Boutique, artisan, small shop | Keep a catalog of items/services with fixed rates and create simple itemized bills. |

---

## 5. End-to-End Application Flow

```
+-------------------------------------------------------------+
|                      1. Authentication                       |
|               (Register / Login / Verify Email)              |
+-------------------------------------------------------------+
                              |
                              v
+-------------------------------------------------------------+
|                     2. Dashboard Screen                     |
|           (KPI Cards, Quick Actions, Recent Invoices)       |
+-------------------------------------------------------------+
         |                                           |
         v                                           v
+--------------------+                     +--------------------+
| 3. Customer Catalog|                     | 4. Product Catalog |
| (Clients & Contacts)                     |  (Goods & Services)|
+--------------------+                     +--------------------+
         \                                           /
          \                                         /
           v                                       v
+-------------------------------------------------------------+
|                      5. Invoice Creation                    |
|    Select Customer -> Add Products/Quantities -> Auto-Calc  |
+-------------------------------------------------------------+
                              |
                              v
+-------------------------------------------------------------+
|                     6. Payment Tracking                     |
|         Record Customer Payments -> Update Balance Due       |
+-------------------------------------------------------------+
                              |
                              v
+-------------------------------------------------------------+
|                 7. Status & Dashboard Updates                |
|    Invoice Status (Paid/Pending) -> Real-Time Analytics     |
+-------------------------------------------------------------+
```

---

## 6. Functional Requirements

### 6.1 Authentication & User Management
- **Registration:** Email and password sign-up with validation (name, email, password strength).
- **Profile Initialization:** Automatic creation of a Firestore document (`users/{uid}`) storing display name, email, and timestamp upon registration.
- **Login & Logout:** Secure session management backed by Firebase Authentication.
- **Email Verification:** Verification link sent upon registration; `AuthGate` enforces verification before accessing the app.
- **Password Recovery:** Forgot password workflow delivering reset instructions via email.
- **Profile Management:** View and edit account profile details.

### 6.2 Customer Management (`feature/customers`)
- **Add Customer:** Capture name, email, phone number, billing address, and optional business notes.
- **Customer List:** Searchable, scrollable list of all customers scoped to the authenticated user.
- **Customer Details:** Dedicated view displaying customer contact info, associated invoices, payment history, and lifetime billing totals.
- **Edit / Delete:** Modify customer details or archive/delete customers with referential integrity warnings.

### 6.3 Product & Service Catalog (`feature/products`)
- **Add Product/Service:** Record item name, description, unit price, item type (Physical Good vs. Hourly Service), and unit of measure.
- **Catalog View:** Searchable list displaying pricing and quick-edit triggers.
- **Edit / Delete:** Modify item definitions or deactivate products without breaking historical invoice items.

### 6.4 Invoice Management (`feature/invoices`)
- **Create Invoice:**
  - Select an existing customer from the user's catalog.
  - Add line items (InvoiceItems) referencing products/services.
  - Specify item quantities and custom unit prices (with pre-filled catalog defaults).
  - Automatically compute subtotal, taxes, discounts, and grand total.
  - Set invoice issue date, payment due date, and custom notes/terms.
- **Invoice States:**
  - `Draft`: Being prepared, not finalized.
  - `Pending`: Finalized and issued, awaiting payment.
  - `Partially Paid`: Partial payment received against total.
  - `Paid`: Fully paid, zero balance remaining.
  - `Overdue`: Past due date without full settlement.
  - `Cancelled`: Voided invoice.
- **Invoice Detail View:** Full itemized view with payment history, status badge, and action triggers.

### 6.5 Payment Processing & Tracking (`feature/payments`)
- **Record Payment:** Log payments against a specific invoice with payment date, amount, payment method (Cash, Bank Transfer, Card, UPI, etc.), and reference/transaction note.
- **Balance Recalculation:** Automatic updates to `paidAmount`, `balanceDue`, and invoice status (`Paid` vs `Partially Paid`).
- **Payment History:** Chronological audit log of all payments applied to an invoice.

### 6.6 Dashboard & Business Overview (`feature/dashboard`)
- **Welcome & Header:** Professional branding, user greeting, and notification alerts.
- **Metric Cards (KPIs):**
  - Total Customers
  - Total Products/Services
  - Total Invoices
  - Total Revenue & Outstanding Balance
- **Quick Action Bar:** Direct one-tap navigation to "Add Customer", "Add Product", and "Create Invoice".
- **Recent Invoices:** Preview list of latest 5 invoices with customer name, invoice ID, amount, and visual status chips.

---

## 7. Non-Functional Requirements

| Category | Requirement |
|---|---|
| **Security** | 100% tenant isolation. All Firestore reads and writes must be validated against `request.auth.uid`. No global reads. Zero cross-user data leakage. |
| **Performance** | App launch to interactive under 2 seconds. Smooth 60fps scrolling across all list screens. |
| **Code Quality** | Zero warnings on `flutter analyze`. Strict null safety. Reusable components. Separation of concerns. |
| **Reliability** | Graceful error handling for offline or network connectivity drops; defensive null checking. |
| **Maintainability** | Layered architecture (`Screen` -> `Provider` -> `Service` -> `Firebase`). Modular features on independent Git branches. |
| **UI Aesthetics** | Clean, modern, distraction-free business UI; light neutral canvas (`#F7F8FA`), crisp white cards, balanced typography, and purposeful accent colors. |

---

## 8. Known Limitations & Parked Issues

- **Firebase Action Links Issue:** Firebase-hosted action links sent via email (for email verification and password reset) currently trigger an expired/used error when opened in the web browser. The client-side Flutter dispatch, listener, and state flow are fully functioning. Resolving the Firebase-hosted action URL handler is parked for a dedicated investigation phase.
