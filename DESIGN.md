# TurfIn Vendor — Design System

## Overview

The TurfIn Vendor design system is built on a single, almost violently simple idea: **the numbers speak, the chrome doesn't.** Every screen reads as an operational dashboard — towering Manrope display lockups for revenue and booking counts burned into dark surfaces, with everything else (nav, filters, buttons, cards, labels) reduced to neutral typography and pill geometry on `{colors.canvas}` and `{colors.carbon}`. There is no decorative gradient, no soft shadow nostalgia, no accent color used for "tone" — the system saves all chromatic energy for the ONE primary metric per screen and the small handful of moments that actually need to signal (active CTA, confirmed status, success indicator).

The result is a layout that feels like a live operations terminal — metric hero, booking list, field grid, earnings summary — stacked like a printed ops report rather than animated like a typical SaaS dashboard. Density is high but never crowded, because the system relies on three relentless devices: a single full-width hero stat card on `{colors.carbon}` with neon glow, pill-shaped primary CTAs (`{rounded.pill}`) anchoring every actionable surface, and a tight 8px-base spacing scale that keeps cards and list rows mathematically aligned across Dashboard, Bookings, Fields, and Profile.

Across every tab, the same chrome appears in identical proportions — only the metric values and field photography change. That is the system's signature: **maximum editorial expression in the numbers, maximum mechanical restraint everywhere else.**

**Key Characteristics:**
- Hero metric display with `{typography.displayCampaign}` (Manrope, 48px, weight 800, line-height 0.95) for the primary revenue stat on the dashboard
- Pure black / neon-green / white palette: `{colors.canvas}`, `{colors.carbon}`, `{colors.onSurface}`, and `{colors.primary}` carry ~98% of the chrome surface area
- Pill geometry everywhere: every CTA, filter chip, and status chip uses `{rounded.pill}` (30px) — there are no sharp-cornered buttons in the system
- Cards sit flat on `{colors.carbon}` with a `{colors.hairline}` border and zero elevation — the metric or field photo is the card
- Single-accent CTA hierarchy: `{component.button-primary}` (neon on black) is used exactly ONCE per screen viewport. Everything else defers to `{component.button-secondary}` or `{component.button-outline}`
- 8px spacing system with section rhythm at `{spacing.section}` (48px) creating consistent vertical breathing across all tabs
- Error signaling is the ONLY place red appears in the chrome: `{colors.error}` for error states and destructive actions, never for decoration

---

## Colors

### Brand & Accent
- **Primary Neon** (`{colors.primary}` — `#CCFF00`): The brand's only accent color. Used for the primary CTA, the hero revenue metric, the active nav indicator, the QR scanner trigger, and the confirmed booking status. When TurfIn wants to assert anything, it goes neon.
- **On-Primary Black** (`{colors.onPrimary}` — `#000000`): Text and icons that sit on any neon green surface. The only context where black text appears.

### Surface
- **Canvas** (`{colors.canvas}` — `#000000`): Every scaffold/page background. The "page."
- **Carbon** (`{colors.carbon}` — `#111111`): Card and component background. The "material." Most-used non-black surface.
- **Nav** (`{colors.navBg}` — `#F2000000`): Bottom navigation bar — 95% black to float above content without a hard line.

### Text
- **On-Surface** (`{colors.onSurface}` — `#FFFFFF`): Primary text on dark surfaces — headlines, field names, booking customer names, prices.
- **Mute** (`{colors.mute}` — `#99FFFFFF` / 60% white): Secondary text — field category, booking time, price secondary info.
- **Ghost** (`{colors.ghost}` — `#4DFFFFFF` / 30% white): Disabled and lowest-emphasis text, placeholder descriptions.
- **Section Label** (`{colors.sectionLabel}` — `#94A3B8`): Uppercase section headers ("NEXT CHECK-INS", "RECENT BOOKINGS") — the only slate-family color in the system.

### Structure
- **Hairline** (`{colors.hairline}` — `#333333`): 1px border on cards, list rows, and modal containers.
- **Hairline Subtle** (`{colors.hairlineSubtle}` — `#222222`): Bottom edge on the nav bar and sticky strip — the only "shadow" the system uses.

### Semantic
- **Neon Glow** (`{colors.neonGlow}` — `#33CCFF00` / 20% neon): Background tint for confirmed status chip and the hero revenue card's ambient glow. The only glow in the system and reserved for exactly ONE element per screen.
- **Error** (`{colors.error}` — `#EF4444`): Destructive actions, cancelled status, validation errors. Never decorative.
- **Success** (`{colors.success}` — `#22C55E`): Confirmation messages, completed booking indicator.

### Status Chip Colors
Status chips are the ONLY place opacity-tinted backgrounds appear. These are defined as `const Color(0xAARRGGBB)` constants — never `.withOpacity()`.
- **Confirmed**: bg `{colors.neonGlow}` (#33CCFF00), text `{colors.primary}` (#CCFF00)
- **Available / Completed**: bg `{colors.onSurface10}` (#1AFFFFFF), text `{colors.mute}` (#99FFFFFF)
- **Pending**: bg `{colors.onSurface10}`, text `{colors.mute}`
- **Cancelled**: bg `#1AEF4444`, text `{colors.error}` (#EF4444)
- **Blocked**: bg `{colors.onSurface10}`, text `{colors.ghost}` (#4DFFFFFF)

---

## Typography

**Font Family: Manrope** (Google Fonts) — a geometric sans-serif with strong optical weight at display sizes and clean legibility at caption sizes. Used at all weights from 400 to 800 across the entire system.

### Hierarchy

| Token | Size | Weight | Line Height | Letter Spacing | Use |
|---|---|---|---|---|---|
| `{typography.displayCampaign}` | 48px | 800 | 0.95 | -1.0px | Hero revenue metric on Dashboard — the system's ONE editorial lockup |
| `{typography.displayXL}` | 32px | 800 | 1.0 | -0.5px | Secondary metrics (booking count, occupancy %) |
| `{typography.headingXL}` | 24px | 700 | 1.2 | -0.3px | Screen title ("Welcome back."), dialog headline, section header on PDP-style screens |
| `{typography.headingLG}` | 20px | 700 | 1.2 | -0.2px | Card section title, earnings period header |
| `{typography.headingMD}` | 18px | 600 | 1.3 | 0 | Subsection label, tab header |
| `{typography.bodyStrong}` | 16px | 500 | 1.4 | 0 | Customer name in booking row, field name, primary nav link label |
| `{typography.bodyMD}` | 15px | 400 | 1.5 | 0 | Body copy, form field value text, description |
| `{typography.buttonMD}` | 16px | 700 | 1.0 | 0 | All pill CTA labels ("SIGN IN", "Earnings", "Save Field") |
| `{typography.captionMD}` | 13px | 600 | 1.4 | 0 | Card metadata — field name under customer name, time label, price secondary |
| `{typography.captionSM}` | 11px | 600 | 1.4 | 1.0px | Status chip label (always uppercase), small inline counts |
| `{typography.utilityXS}` | 9px | 700 | 1.5 | 1.5px | Section header in ALL CAPS — "NEXT CHECK-INS", "TODAY'S REVENUE" |

### Principles
The system runs on extreme typographic contrast: a single 48px display tier reserved for the hero revenue metric only, and a quiet 11–16px Manrope tier carrying everything else. The jump from `{typography.displayCampaign}` (48px) to `{typography.bodyStrong}` (16px) is intentional and creates the "billboard above, operations log below" effect across the Dashboard. Letter-spacing is negative on display sizes (tight optical fit at scale) and positive on utility labels (scan-readability at small sizes).

---

## Layout

### Spacing System
- **Base unit:** 8px
- **Tokens:** `{spacing.xxs}` (2px) · `{spacing.xs}` (4px) · `{spacing.sm}` (8px) · `{spacing.md}` (12px) · `{spacing.lg}` (16px) · `{spacing.xl}` (24px) · `{spacing.xxl}` (32px) · `{spacing.section}` (48px)
- **Universal rhythm:** every tab uses `{spacing.section}` (48px) as the top padding before content begins and `{spacing.xxl}` (32px) as the bottom padding. Within sections, components stack at `{spacing.xxl}` (32px). List rows gap at `{spacing.sm}` (8px) to `{spacing.md}` (12px).
- **Screen horizontal padding:** `{spacing.xl}` (24px) on all tabs.
- **Card internal padding:** `{spacing.lg}` (16px) all sides, except the hero metric card which uses `{spacing.xl}` (24px).

### Grid
- **Single-column:** All tabs use a single-column scroll layout. No sidebar.
- **2-column rows:** Secondary stat cards (Bookings + Occupancy) sit side-by-side in a `Row` with `{spacing.sm}` gap. Quick action buttons use a 2-column `Row`.
- **Field listing:** Full-width cards stacked vertically in the Fields tab.

### Whitespace Philosophy
Whitespace separates sections, not individual components. List rows sit flush with `{spacing.sm}` gaps — the `{colors.hairline}` border is the separator, not padding. The "air" comes from `{colors.canvas}` between cards, not from decorative margins around them.

---

## Elevation & Depth

| Level | Treatment | Use |
|---|---|---|
| 0 — Flat | No shadow, no elevation | Default for all cards, all buttons, all containers |
| 1 — Hairline border | 1px solid `{colors.hairline}` (#333333) | Every card, every list row container, modal border |
| 2 — Neon glow | `BoxShadow(color: #33CCFF00, blurRadius: 12)` | **One element per screen only** — the hero revenue card on Dashboard |
| 3 — Nav hairline | `BoxShadow: inset 0 -1px 0 {colors.hairlineSubtle}` | Bottom nav bar top border — the only structural hairline in the system |

The system has no Material elevation or drop shadows anywhere. Cards do not lift on the page. The only depth cue is the neon glow on the primary revenue card and the hairline borders separating cards from the canvas.

---

## Shapes

### Border Radius Scale

| Token | Value | Use |
|---|---|---|
| `{rounded.sm}` | 8px | Icon containers (logo box, avatar), small inline badge containers |
| `{rounded.md}` | 16px | Cards, bottom sheets, modal dialogs, input fields |
| `{rounded.pill}` | 30px | Every CTA button (primary, secondary, outline), every status chip, every filter chip |
| `{rounded.full}` | 9999px | Circular icon buttons (FAB alternative, close button), avatar circles |

### Field Photography
- **Field listing cards (Fields tab):** Full-width image placeholder with a 16:9 crop at the top of the card, then metadata below. Image has zero internal padding and `{rounded.md}` (16px) on the container — the photograph bleeds to the card edges.
- **Scanner target:** QR finder uses a centered square with `{colors.primary}` corner brackets — the ONLY decorative drawing in the system.
- **Avatar / profile icon:** Circular at 48px with `{rounded.full}`.

---

## Components

### Buttons

**`button-primary`** — the universal TurfIn CTA
- Background `{colors.primary}` (#CCFF00), foreground `{colors.onPrimary}` (#000000), type `{typography.buttonMD}` (16px, w700), width `double.infinity`, height 56px, radius `{rounded.pill}` (30px).
- Used for the ONE primary action per screen: "SIGN IN", "Save Field", "Generate Slots", "Submit KYC".
- Pressed state: `scale(0.97)`, opacity 0.9 — brief tap collapse.

**`button-secondary`** — soft alternative on dark surfaces
- Background `{colors.carbon}` (#111111), foreground `{colors.onSurface}` (#FFFFFF), 1px border `{colors.hairline}`, type `{typography.buttonMD}`, height 44px (compact) or 56px (full), radius `{rounded.pill}`.
- Used for lower-emphasis actions alongside an existing primary CTA: "Cancel", "Earnings", "All Bookings".

**`button-icon-circular`** — chrome icon controls
- Background transparent or `{colors.carbon}`, icon `{colors.onSurface}`, radius `{rounded.full}`, size 44×44px minimum.
- Used for back-arrow in AppBar, close buttons, and the QR scanner FAB.

**FAB — QR scanner trigger**
- Background `{colors.primary}`, icon `{colors.onPrimary}`, size 56×56, radius `{rounded.full}`. This is the ONE primary interactive element on the main home scaffold and receives the neon glow treatment.

### Status Chips

**`status-chip`** — booking and slot status indicators
- Pill shape `{rounded.pill}` (30px), padding 10px horizontal / 4px vertical.
- Label is always UPPERCASE, type `{typography.captionSM}` (11px, w600, ls 1.0).
- Color variants are the ONLY place opacity-tinted backgrounds appear (see Color › Status Chip Colors).

### Cards & Containers

**`vendor-card`** — the universal container
- Background `{colors.carbon}` (#111111), border 1px `{colors.hairline}` (#333333), radius `{rounded.md}` (16px), padding `{spacing.lg}` (16px), elevation 0.
- Tappable variant: wraps in `GestureDetector`, no hover state.
- Glowing variant (one per screen max): adds `BoxShadow(color: {colors.neonGlow}, blurRadius: 12)`.

**`metric-hero-card`** — Dashboard primary revenue stat
- Full-width `vendor-card` with glowing variant active.
- Section label `{typography.utilityXS}` `{colors.sectionLabel}` at top.
- Value `{typography.displayCampaign}` (48px, w800) in `{colors.primary}` — the system's editorial lockup.
- No secondary metadata on this card — the number is the entire message.

**`metric-secondary-card`** — Dashboard supporting stats (Bookings, Occupancy)
- Half-width (2-column `Row`) `vendor-card`. No glow.
- Section label `{typography.utilityXS}` `{colors.sectionLabel}`.
- Value `{typography.displayXL}` (32px, w800) in `{colors.onSurface}`.

**`booking-row-card`** — booking entry in Dashboard and Bookings tab
- Full-width `vendor-card`, padding 14px.
- Left: customer name `{typography.bodyStrong}` + field name `{typography.captionMD}` `{colors.mute}` + time chip + status chip in a `Row`.
- Right: amount `{typography.captionMD}` `{colors.primary}` OR scan icon in `{colors.primary}`.

**`section-label`** — section header above content lists
- Text `{typography.utilityXS}` (9px, w700, ls 1.5), color `{colors.sectionLabel}`.
- Always ALL CAPS. No decoration, no divider line.

### Navigation

**`bottom-nav`**
- Background `{colors.navBg}` (#F2000000), height 64px + SafeArea.
- Top border: 1px `{colors.hairlineSubtle}`.
- 4 items split around a centered FAB gap: Dashboard · Bookings · [FAB] · Fields · Profile.
- Active item: `{colors.primary}` icon + label + 3px wide underline strip above icon (animated width 0→24px on activation).
- Inactive item: `{colors.onSurface50}` icon + label.
- Labels: `{typography.captionSM}` (11px), active weight 700, inactive weight 400.

**`app-bar`**
- Background `{colors.canvas}` (#000000), elevation 0, centered title `{typography.headingMD}` (18px, w600).
- Back button: `{component.button-icon-circular}` with system back arrow in `{colors.onSurface}`.

### Forms

**`input-field`**
- Background `{colors.carbon}`, border 1px `{colors.hairline}`, radius `{rounded.md}` (16px), padding 16px.
- Text style: 15px, w500, `{colors.onSurface}`.
- Focused border: 1.5px `{colors.primary}`.
- Error border: 1px `{colors.error}`.
- Hint color: `{colors.ghost}` (30% white).

### Signature Components

**`loading-overlay`**
- Full-screen scrim `{colors.scrim}` (#80000000) with centered `CircularProgressIndicator` in `{colors.primary}`.

**`scanner-screen`**
- Full-screen `{colors.canvas}` background.
- Camera preview centered with `{colors.primary}` corner brackets at the QR target area — the only decorative drawing element.
- Instruction text below in `{typography.captionMD}` `{colors.mute}`.

**`kyc-status-badge`**
- Inline pill badge `{rounded.pill}` 30px with 4px v-padding, 12px h-padding.
- Verified: bg `#1A22C55E`, text `{colors.success}`. Pending: bg `{colors.onSurface10}`, text `{colors.mute}`. Rejected: bg `#1AEF4444`, text `{colors.error}`.

---

## Do's and Don'ts

### Do
- Reserve `{typography.displayCampaign}` exclusively for the hero revenue metric on the Dashboard — never use 48px Manrope for card titles or section headers.
- Use `{component.button-primary}` (neon pill) as the single primary action per screen. Pair it at most with `{component.button-secondary}` (carbon pill with border) for a soft alternative.
- Keep all CTAs pill-shaped at `{rounded.pill}` (30px). Never introduce a square or `{rounded.md}` button.
- Apply neon glow (`{colors.neonGlow}` box shadow) to exactly ONE element per screen — always the hero metric card on Dashboard, always the primary CTA on action screens.
- Use `{colors.error}` only for error states, cancelled status, and destructive actions — never for decoration.
- Stack content sections at `{spacing.xxl}` (32px) rhythm with no decorative dividers between them.
- Use `const Color(0xAARRGGBB)` for all opacity variants — never `.withOpacity()` or `.withAlpha()`.
- Always use `AppThemeColors.of(context).*` for structural colors. Only use `AppColors.*` directly for brand invariants (primary, error).

### Don't
- Don't introduce drop shadows or Material elevation. Cards sit flat with a 1px border.
- Don't use `{colors.primary}` neon green for section labels, descriptive text, or decoration — it's reserved for the ONE assertive element per screen.
- Don't pad inside booking row cards beyond 14px — the row is dense; the border is the separator.
- Don't put two `{component.button-primary}` (neon) actions in the same screen fold.
- Don't add a third button shape. Pill (`{rounded.pill}`) or circular (`{rounded.full}`) — those are the only button shapes in the system.
- Don't underline anything other than explicit `TextDecoration.underline` inline links. Buttons, headings, and prices stay un-underlined.
- Don't use `.withOpacity()` anywhere. All opacity values are baked into `const Color(0xAARRGGBB)` constants in `app_colors.dart`.
- Don't hardcode any color value in widget files. All colors flow from `AppColors.*` or `AppThemeColors.of(context).*`.

---

## Responsive Behavior

This is a mobile-only app (Android + iOS). No desktop or tablet layout is designed or needed.

### Screen Size Considerations
- **Standard phones (360–430dp width):** Default layout. 24px horizontal padding, 2-column stat row, full-width booking cards.
- **Small phones (<360dp):** Reduce `{spacing.xl}` horizontal padding to `{spacing.lg}` (16px). `{typography.displayCampaign}` holds at 48px — it fits on a 312dp content width.
- **Large phones / tablets (>430dp):** Content stays single-column. Cards max out at full width. No grid expansion.

### Touch Targets
All interactive elements meet WCAG AA minimum (44×44dp). Pill CTAs at 56dp height with 24dp horizontal padding exceed AA. Bottom nav items are 64dp tall. Icon buttons are 44×44dp minimum. Status chips are 32dp tall — below AA but not interactive (display only).

### Safe Areas
All screens use `SafeArea` at the scaffold body level. Bottom nav uses `SafeArea(top: false)` for the home indicator region.

---

## Token Quick Reference

```
colors.canvas          #000000         Scaffold background
colors.carbon          #111111         Card / component surface
colors.primary         #CCFF00         Neon green — ONE assertive element per screen
colors.onPrimary       #000000         Text on neon surfaces
colors.navBg           #F2000000       Bottom nav (95% black)
colors.onSurface       #FFFFFF         Primary text
colors.mute            #99FFFFFF       Secondary text (60%)
colors.ghost           #4DFFFFFF       Disabled / lowest emphasis (30%)
colors.hairline        #333333         Card border
colors.hairlineSubtle  #222222         Nav border
colors.neonGlow        #33CCFF00       Glow bg (20% neon) — ONE element max
colors.sectionLabel    #94A3B8         Section header label color
colors.error           #EF4444         Error / destructive only

typography.displayCampaign   48px  w800  lh 0.95  ls -1.0   Hero revenue metric
typography.displayXL         32px  w800  lh 1.0   ls -0.5   Secondary stats
typography.headingXL         24px  w700  lh 1.2   ls -0.3   Screen title
typography.headingLG         20px  w700  lh 1.2   ls -0.2   Card headline
typography.headingMD         18px  w600  lh 1.3   ls  0     Subsection header
typography.bodyStrong        16px  w500  lh 1.4   ls  0     Nav links, field names
typography.bodyMD            15px  w400  lh 1.5   ls  0     Body copy
typography.buttonMD          16px  w700  lh 1.0   ls  0     Pill CTA labels
typography.captionMD         13px  w600  lh 1.4   ls  0     Card metadata
typography.captionSM         11px  w600  lh 1.4   ls +1.0   Status chips (CAPS)
typography.utilityXS          9px  w700  lh 1.5   ls +1.5   Section labels (CAPS)

rounded.sm     8px      Icon containers
rounded.md    16px      Cards, inputs, modals
rounded.pill  30px      All CTAs and chips
rounded.full  9999px    Circular elements

spacing.sm    8px    List row gap
spacing.md    12px   Label-to-field gap
spacing.lg    16px   Card padding (default)
spacing.xl    24px   Screen horizontal padding
spacing.xxl   32px   Between major components
spacing.section  48px  Top-of-tab breathing room
```
