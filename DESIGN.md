---
name: "Hora Day - Warm Zen & Minimal Studio"
description: "A serene, modern, breathable Thai astrological CRM and auspicious birthday sanctuary"
colors:
  primary: "#A87532"
  primary-hover: "#926226"
  accent-gold: "#D4A359"
  champagne: "#F5EEDB"
  deep-gold-text: "#8A5B22"
  surface-canvas: "#FAF8F5"
  surface-sand: "#F3EFE6"
  surface-card: "#FFFFFF"
  border-hairline: "#EBE5DC"
  text-ink: "#1F1D1A"
  text-sub: "#5E5953"
  text-muted: "#8C847A"
  day-sunday: "#DC2626"
  day-monday: "#D97706"
  day-tuesday: "#DB2777"
  day-wednesday: "#059669"
  day-thursday: "#EA580C"
  day-friday: "#0284C7"
  day-saturday: "#7C3AED"
typography:
  display:
    fontFamily: "Prompt, sans-serif"
    fontSize: "24px"
    fontWeight: 700
  title:
    fontFamily: "Prompt, sans-serif"
    fontSize: "17.5px"
    fontWeight: 700
  body:
    fontFamily: "Prompt, sans-serif"
    fontSize: "14px"
    fontWeight: 400
  caption:
    fontFamily: "Prompt, sans-serif"
    fontSize: "12px"
    fontWeight: 500
rounded:
  sm: "6px"
  md: "10px"
  lg: "14px"
  xl: "16px"
  full: "999px"
spacing:
  xs: "4px"
  sm: "8px"
  md: "12px"
  lg: "16px"
  xl: "24px"
components:
  button-primary:
    backgroundColor: "{colors.primary}"
    textColor: "#FFFFFF"
    rounded: "{rounded.md}"
    padding: "8px 14px"
  button-secondary:
    backgroundColor: "{colors.surface-sand}"
    textColor: "{colors.text-ink}"
    rounded: "{rounded.md}"
    padding: "8px 12px"
  card-zen:
    backgroundColor: "{colors.surface-card}"
    rounded: "{rounded.lg}"
    padding: "16px"
---

# Design System: Warm Zen & Minimal Studio

## Overview

Hora Day is redesigned in a **Warm Zen & Minimal Studio** aesthetic — combining the sacred dignity of Thai astrology (โหราศาสตร์ไทย) with modern Japanese washi minimalism. It replaces heavy, clashing dark blocks and garish golden gradients with a breathable, tranquil ivory ground, gentle ambient lighting, crisp typography, and quiet mineral accents.

## Colors

- **Canvas & Surfaces:**
  - `AppColors.ivory` (`#FAF8F5`): Primary washi cream canvas. Warm, soothing, zero harsh eye strain.
  - `AppColors.warmSand` (`#F3EFE6`): Secondary muted container surface for pills and inactive selectors.
  - `AppColors.warmCard` (`#FFFFFF`): Crisp white cards creating gentle, airy contrast against the ivory background.
  - `AppColors.warmBorder` (`#EBE5DC`): Delicate hairline border that structures space without visual clutter.
- **Accents:**
  - `AppColors.caramelBronze` (`#A87532`): Refined caramel bronze used with restraint for primary actions and key milestones.
  - `AppColors.amberGold` (`#D4A359`): Auspicious warm gold for subtle badges and celebration highlights.
  - `AppColors.champagne` (`#F5EEDB`): Soft champagne tone for category pills.
- **Typographic Ink (WCAG AAA/AA):**
  - `AppColors.darkText` (`#1F1D1A`): Warm sumi charcoal ink (>13:1 contrast against white).
  - `AppColors.subText` (`#5E5953`): Warm stone neutral (>5.5:1 contrast).
  - `AppColors.mutedText` (`#8C847A`): Muted pebble tone for hints and secondary icons (>4.5:1 contrast).
  - `AppColors.deepGoldText` (`#8A5B22`): Auspicious gold text with verified high readability (>7:1 contrast).
- **Auspicious Astrological Minerals:**
  - 7 weekday mineral tones (Ruby Sunday `#DC2626`, Amber Monday `#D97706`, Lotus Tuesday `#DB2777`, Jade Wednesday `#059669`, Terracotta Thursday `#EA580C`, Cerulean Friday `#0284C7`, Amethyst Saturday `#7C3AED`).

## Typography

- **Font Family:** `Prompt` (Google Fonts), supporting Thai and Latin glyphs with modern clean geometric curves.
- **Scale:**
  - Screen Titles: 17.5px–18px, Bold (`FontWeight.w700`), `-0.2px` letter spacing.
  - Section Headers: 13.5px–14.5px, Bold (`FontWeight.w700`).
  - Card Titles (Client Names): 14.5px–15.5px, Semi-Bold / Bold.
  - Body Text: 13px–14px, Regular (`FontWeight.w400`).
  - Metadata & Captions: 11px–12.5px, Medium (`FontWeight.w500`).

## Layout

- **Mobile-First & Adaptive Spatial Architecture:**
  - Standard max-width constraint: `760px` centered on desktop/tablet, fluid on mobile.
  - 16px lateral padding for comfortable one-handed thumb grip.
  - 4-unit base spacing cadence: 4px tight proximity, 8-12px standard gap, 16-20px generous group separation, 88dp bottom padding on scrollable lists to ensure floating action buttons never block content.
- **Home Hub Layout:**
  - 3-Metric Pulse Row: Fast-tap wayfinding cards (วันเกิดใกล้ถึง, ลูกดวงทั้งหมด, มีบันทึกดวง).
  - 4-Quadrant Quick Action Grid: Immediate 1-tap shortcuts (เพิ่มลูกดวง, ปฏิทินวันเกิด, สมุดบันทึก, สถิติภาพรวม).
  - High-priority Celebratory Birthday Cards with direct blessing dispatch.
- **Dual View Modes in Birthday Hub:**
  - **Timeline Flow:** Chronological groupings (Today / Next 7 Days / Later this Month) eliminating the need to click empty calendar squares.
  - **Celestial Calendar Grid:** Airy 7-day grid with mineral dot indicators.
- **Notes & Stats Sanctuaries:**
  - Clean card lists with inline quote boxes and mineral day indicators.
  - Horizontal astrological distribution bars with proportional percentage tracks.

## Elevation & Depth

- **Ambient Zen Diffused Shadows:**
  - Hairline borders (`#EBE5DC`) carry structural form instead of heavy drop shadows.
  - Diffused ambient shadow: `BoxShadow(color: Color(0x06000000), blurRadius: 10, offset: Offset(0, 3))`.
  - Auspicious celebrating cards: Soft golden ambient glow `BoxShadow(color: Color(0x1AA87532), blurRadius: 8, offset: Offset(0, 2))`.

## Shapes

- Small Badges & Chips: `BorderRadius.circular(6)` to `BorderRadius.circular(8)`.
- Buttons & Search Field: `BorderRadius.circular(10)` to `BorderRadius.circular(12)`.
- Cards: `BorderRadius.circular(14)` to `BorderRadius.circular(16)`.
- Floating Action Buttons: `BorderRadius.circular(16)`.

- **Mobile & Adaptive Ergonomics (Android & iOS):**
  - **Adaptive Bottom Sheets over Centered Dialogs:** On mobile phone viewports (`width < 640px`), forms (`CustomerFormDialog`), detail views (`CustomerDetailDialog`), chatboxes (`BirthdayChatboxDialog`), and confirmation modals slide up as native Modal Bottom Sheets with top drag handles (`width: 38`, `height: 4`, `radius: 2`) and 22-25px rounded top corners. On tablets and desktops (`width >= 640px`), they gracefully render as centered dialogs.
  - **Virtual Keyboard Resiliency:** All mobile modal sheets dynamically pad against `MediaQuery.of(context).viewInsets.bottom` so inputs never get compressed, squished, or pushed off-screen when the soft keyboard opens.
  - **Safe Area Insets:** The bottom navigation bar is wrapped in `SafeArea(top: false)` to prevent overlap with the iPhone Home Indicator swipe bar and Android 3-button/gesture bars.
  - **Thumb-Zone Touch Targets:** Interactive chips, phone/LINE copy buttons, and action triggers strictly maintain $\ge 40$–$48$dp touch heights with clear tactile press feedback.
  - **Bottom Scroll Clearances:** All primary scrollable views maintain `88`–`96`dp bottom padding so lists can be scrolled completely clear of the docked bottom navigation bar and floating action buttons.

## Components

- **Auspicious Focus Hero Card:** Clean white card summarizing today's auspicious color, direction, and celebrants with one-tap action.
- **Zen Birthday Card:** Tokenized mineral weekday badge, crisp name hierarchy, and prominent tactile "อวยพร" button.
- **Category Filter Pills:** Horizontal scrollable pills with live badge counters.
- **Mobile Action FAB:** Bottom-right anchored `FloatingActionButton.extended` in warm caramel bronze.

## Do's and Don'ts

- **DO** use generous whitespace and maintain clean separation between cards.
- **DO** use the refined `caramelBronze` and `amberGold` accents intentionally, letting the washi ivory ground breathe.
- **DO** use `CustomerFormDialog.show()`, `CustomerDetailDialog.show()`, and `BirthdayChatboxDialog.show()` to automatically provide the best mobile bottom sheet or desktop dialog experience.
- **DON'T** introduce heavy dark navy or black rectangular blocks that disrupt the calm, zen aesthetic.
- **DON'T** use harsh colored drop shadow rings or zero-offset borders.

