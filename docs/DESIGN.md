# Invoxa — UI/UX Design System & Guidelines

## 1. Design Philosophy

Invoxa is engineered for small business owners, freelancers, and independent contractors. The interface must communicate **clarity, trust, speed, and precision**.

### Core Tenets
1. **Clean & Uncluttered:** Prioritize whitespace, generous padding, and clear visual hierarchy over flashy decorations.
2. **Professional & Restrained:** Avoid hyper-saturated colors, heavy gradients, or excessive bouncy animations. The tool should feel like high-end financial software.
3. **Scannable Information:** Financial figures, invoice IDs, and payment statuses must be immediately readable at a glance.
4. **Consistency:** Reusable design tokens (colors, border radii, typography, spacing) apply universally across mobile, tablet, and desktop views.

---

## 2. Color Palette & Design Tokens

### 2.1 Surfaces & Neutrals
| Token Name | Hex Code | Purpose |
|---|---|---|
| `appBackground` | `#F7F8FA` | App-wide screen background (soft neutral grey) |
| `surfaceWhite` | `#FFFFFF` | Card backgrounds, dialogs, sheets, and input fields |
| `borderLight` | `#E5E7EB` | Subtle outlines, card borders, and list dividers |
| `borderFocus` | `#6366F1` | Active input field border |

### 2.2 Typography Colors
| Token Name | Hex Code | Purpose |
|---|---|---|
| `textPrimary` | `#111827` | Headings, primary labels, invoice numbers |
| `textSecondary` | `#4B5563` | Subheadings, descriptive text, table column headers |
| `textMuted` | `#6B7280` | Timestamps, placeholders, inactive icons |
| `textInverse` | `#FFFFFF` | Text on solid dark or primary-colored buttons |

### 2.3 Brand & Primary Accents
| Token Name | Hex Code | Purpose |
|---|---|---|
| `primary` | `#4F46E5` | Primary brand color (Indigo 600) — CTA buttons, active tabs |
| `primaryHover` | `#4338CA` | Hover/Pressed button state |
| `primaryLight` | `#EEF2FF` | Selected item tint, icon background badge |

### 2.4 Semantic Status Colors
Status chips and financial indicators use standard, unmistakable semantic tones:

| Status | Background | Text / Icon | Meaning |
|---|---|---|---|
| **Paid / Success** | `#ECFDF5` | `#059669` | Invoice settled, payment successful |
| **Pending / Warning** | `#FFFBEB` | `#D97706` | Awaiting client payment |
| **Partially Paid** | `#EFF6FF` | `#2563EB` | Partial payment captured |
| **Overdue / Danger** | `#FEF2F2` | `#DC2626` | Past due date, action required |
| **Draft / Inactive** | `#F3F4F6` | `#4B5563` | Incomplete or unissued invoice |

---

## 3. Typography & Hierarchy

The application uses standard platform typography (or Inter / Roboto) with consistent weights and sizes:

| Text Style | Size | Weight | Line Height | Application |
|---|---|---|---|---|
| **Display Title** | `28px` | Bold (`700`) | `34px` | "Welcome back 👋" & primary screen titles |
| **Section Header** | `20px` | SemiBold (`600`) | `26px` | Section headers ("Quick Actions", "Recent Invoices") |
| **Card Title / Metric** | `22px` | Bold (`700`) | `28px` | Metric card counts (`25`, `₹45,000`) |
| **Body Large** | `16px` | Medium (`500`) | `24px` | Card headers, primary list titles |
| **Body Standard** | `14px` | Regular (`400`) | `20px` | Subtitles, input text, table contents |
| **Caption / Badge** | `12px` | SemiBold (`600`) | `16px` | Status chips, timestamp indicators |

---

## 4. Spacing & Sizing Scale

A standard **4px / 8px grid** governs all padding and margins:

- **`4px` (xs):** Tight badge padding, micro spacing between icon and text.
- **`8px` (sm):** Gap between label and input field, chip internal padding.
- **`12px` (md):** Card internal padding for compact list items.
- **`16px` (base):** Standard spacing between elements, form field gaps.
- **`20px` (lg):** Screen horizontal padding for mobile viewports.
- **`24px` (xl):** Card internal padding for primary KPI cards.
- **`28px` / `32px` (2xl):** Spacing between major visual sections.

### Border Radius
- **`8px`:** Small buttons, chips, status badges, text fields.
- **`12px`:** Action cards, dialog boxes, dropdown menus.
- **`16px`:** Main content containers, dashboard summary cards.

---

## 5. Key UI Component Standards

### 5.1 Dashboard Summary Cards (KPIs)
- **Container:** Pure white (`#FFFFFF`), `16px` border radius, subtle border (`1px solid #E5E7EB`).
- **Layout:** Icon with tinted circular badge on top-left, title in muted text (`14px`), bold metric below (`22px`).
- **Arrangement:** 2x2 responsive grid on mobile viewports; 4-column row on tablets or desktop screens.

### 5.2 Quick Actions Bar
- **Design:** Elevated or tinted icon buttons arranged horizontally with descriptive labels underneath.
- **Actions:**
  - `Add Customer` (Icon: `person_add_rounded`)
  - `Add Product` (Icon: `inventory_2_rounded`)
  - `Create Invoice` (Icon: `post_add_rounded` — Primary emphasized style)

### 5.3 Recent Invoices List
- **Card Design:** Horizontal row inside a rounded white card.
- **Left Column:** Invoice number (e.g. `INV-001`) in bold primary text, with customer name directly below in secondary text.
- **Right Column:** Formatted currency amount (e.g. `₹12,500`) with a semantic status chip (`Paid`, `Pending`, `Overdue`).
- **Interaction:** Tap navigates directly to `InvoiceDetailsScreen`.

### 5.4 Form Input Fields (`custom_text_field.dart`)
- Clean outline with `8px` border radius.
- Inactive border: `#E5E7EB`; focused border: `#4F46E5`.
- Floating label with clear placeholder hint.
- Integrated validation message displayed directly beneath the field in red (`#DC2626`).

---

## 6. Anti-Patterns to Avoid

- **No heavy drop shadows:** Prefer subtle `BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: Offset(0, 2))` or clean `1px` borders.
- **No multicolored rainbow cards:** All metric cards share the same clean white background; color is reserved for small badge icons and status indicators.
- **No arbitrary font styling:** Use `Theme.of(context).textTheme` rather than hardcoding random font sizes and colors inside widgets.
- **No raw unformatted numbers:** Always pass numbers through `CurrencyFormatter` or `DateFormatter`.
