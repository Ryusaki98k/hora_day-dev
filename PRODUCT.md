# Product

<!-- impeccable:product-schema 1 -->

## Platform

adaptive

## Users

Thai astrologers, fortune tellers, and spiritual advisors (หมอดู / นักพยากรณ์).
They manage ongoing relationships with multiple clients ("ลูกดวง"), record birth charts and consultation notes during or after divination sessions, and nurture long-term client goodwill through timely, personalized auspicious birthday blessings and daily astrological advice.

## Product Purpose

Hora Day (โหราเดย์) is a dedicated astrological CRM and auspicious calendar management tool. It eliminates scattered paper notebooks, disjointed chat notes, and missed client birthdays by uniting client astrological profiles (birth date, exact birth time, day of week) with daily auspicious indicators (colors, directions, rerk) and one-tap personalized birthday greeting workflows.

Success means the astrologer can instantly look up any client's details, effortlessly monitor who has a birthday today or in the next 1–2 days, and deliver warm, respectful, auspicious blessings directly via LINE with zero friction.

## Positioning

Unlike generic CRM platforms or basic contact lists, Hora Day is built natively around Thai astrological traditions (โหราศาสตร์ไทย). It directly links client data to astrological rules: calculating Thai weekday birth planetary colors, turning age, next birthday countdowns, daily auspicious colors/directions, and pre-composing culturally authentic, respectful birthday blessings tailored for Thai messaging habits.

## Operating Context

- **Environment:** Mobile smartphones (iOS and Android), used either in one-on-one consultation settings or on-the-go.
- **Rituals:**
  - Morning check: Reviewing today's auspicious colors, directions, and clients celebrating birthdays today or in the next 48 hours.
  - Active consultation: Quickly pulling up or recording birth time, province, and astrological observations.
  - Client outreach: Generating and sending personalized auspicious birthday wishes and digital cards via LINE chat.

## Capabilities and Constraints

- **Client Directory:** Add, view, edit, search, and filter clients by name, nickname, phone, province, or upcoming birthday status.
- **Astrological Profile Data:** Full name, nickname, birth date, exact birth time (e.g. 08:30 น.), Thai birth weekday, turning age, LINE ID, phone, province, address, and consultation notes.
- **Auspicious Daily Calculations:** Dynamic Thai day-of-week colors, auspicious directions, auspicious rerk (ฤกษ์มงคล), and daily blessings.
- **Birthday Hub & Auspicious Calendar:** Monthly visual calendar highlighting client birthdays with day-level drill-down.
- **Birthday Chatbox & Card Generator:** Instant generation of respectful Thai astrological birthday messages with copy-to-clipboard and sharing capabilities.
- **Technical Constraints:** Built with Flutter (Material 3, Dart 3.13+, Prompt typography). Mobile-first adaptive design.

## Brand Commitments

- **Name:** Hora Day (โหราเดย์)
- **Voice & Tone:** สุภาพ, อบอุ่น, เป็นสิริมงคล, น่าเชื่อถือ (Respectful, warm, auspicious, professional, and trustworthy).
- **Established Aesthetics:** Auspicious Warm Gold & Champagne Palette (Ivory, Champagne, Amber Gold, Caramel Bronze) with clear readability and serene sacred warmth.

## Evidence on Hand

- Runnable Flutter application in [lib/main.dart](file:///d:/VSCode%20work/repo/development/hora_day/lib/main.dart)
- Data model in [lib/models/customer.dart](file:///d:/VSCode%20work/repo/development/hora_day/lib/models/customer.dart)
- UI Views in [lib/views/home_view.dart](file:///d:/VSCode%20work/repo/development/hora_day/lib/views/home_view.dart), [lib/views/birthday_hub_view.dart](file:///d:/VSCode%20work/repo/development/hora_day/lib/views/birthday_hub_view.dart), [lib/views/notes_view.dart](file:///d:/VSCode%20work/repo/development/hora_day/lib/views/notes_view.dart), and [lib/views/stats_view.dart](file:///d:/VSCode%20work/repo/development/hora_day/lib/views/stats_view.dart)
- UI Widgets in [lib/widgets/customer_card.dart](file:///d:/VSCode%20work/repo/development/hora_day/lib/widgets/customer_card.dart), [lib/widgets/birthday_chatbox_dialog.dart](file:///d:/VSCode%20work/repo/development/hora_day/lib/widgets/birthday_chatbox_dialog.dart), [lib/widgets/hbd_card_dialog.dart](file:///d:/VSCode%20work/repo/development/hora_day/lib/widgets/hbd_card_dialog.dart)
- Theme and helpers in [lib/utils/app_colors.dart](file:///d:/VSCode%20work/repo/development/hora_day/lib/utils/app_colors.dart) and [lib/utils/thai_date_helper.dart](file:///d:/VSCode%20work/repo/development/hora_day/lib/utils/thai_date_helper.dart)

## Product Principles

1. **Astrological Authenticity & Dignity:** Honor Thai astrological traditions, naming, and auspicious calculations with sacred warmth and cultural respect.
2. **Effortless Mobile Routine:** Empower the astrologer to accomplish daily checks and send birthday greetings in seconds without friction.
3. **Client Respect & Intimacy:** Treat client records ("ลูกดวง") with high confidentiality, precision, and personal care.
4. **Direct Channel Alignment:** Seamlessly bridge app data with the astrologer's primary communication channel (LINE) through copy-ready, beautifully structured blessings.

## Accessibility & Inclusion

- Maintain WCAG AAA/AA text contrast across warm gold, ivory, and cream backgrounds.
- High-legibility typography with comfortable font scaling for readability under varied lighting conditions.
- Touch-friendly tap targets optimized for one-handed mobile interactions.
