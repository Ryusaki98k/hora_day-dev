---
target: home / morning hub
total_score: 20
max_score: 40
na_heuristics: 
p0_count: 1
p1_count: 2
target_identity: "file:D:\\VSCode work\\repo\\development\\hora_day\\lib\\views\\home_view.dart"
target_fingerprint: "sha256:88bc8b2c81c7d1ec31a81caf988800822f8cd790699a05db9cccb455f0dc4191"
target_path: "D:\\VSCode work\\repo\\development\\hora_day\\lib\\views\\home_view.dart"
timestamp: 2026-09-28T03-31-45Z
slug: lib-views-home-view-dart
---
# Critique: lib/views/home_view.dart (morning hub + birthday flow)

Method: dual-agent (A: f63f8278-bcd8-434f-bc54-8da51cc673ae · B: eea344c6-f99a-44ba-add2-f78d4db300f4)

## Design Health Score

| # | Heuristic | Score | Key Issue |
|---|-----------|-------|-----------|
| 1 | Visibility of System Status | 2 | SnackBars on save/delete/copy; no “อวยพรแล้ววันนี้” ritual progress; Home pulse can go stale after add |
| 2 | Match System / Real World | 3 | Strong Thai domain copy; morning auspicious check absent on Home; dead “Chatbox” jargon |
| 3 | User Control and Freedom | 3 | Cancel on delete; tab escape; no undo after delete; blessing path unmounted |
| 4 | Consistency and Standards | 2 | Day colors split AppColors vs hardcoded hex; dead HBD indigo vs Warm Zen; Inter in StudioQuickActions |
| 5 | Error Prevention | 2 | Delete confirm solid; no “already blessed” guard; dual ครับ/ค่ะ honorific risk |
| 6 | Recognition Rather Than Recall | 2 | Today/countdown chips help; blessing tools never surface on live routes |
| 7 | Flexibility and Efficiency | 1 | No one-tap อวยพร / bulk bless / LINE share from Home or Hub |
| 8 | Aesthetic and Minimalist Design | 2 | Calm washi Home; notes ledger competes with ritual; orphaned banner/card off-palette |
| 9 | Error Recovery | 2 | Clear SnackBars; permanent delete; no blessing recovery story |
| 10 | Help and Documentation | 1 | No ritual onboarding; empty states don’t teach LINE blessing workflow |
| **Total** | | **20/40** | **Acceptable (borderline Poor)** |

## Design Specificity Verdict

**LLM assessment:** Mostly a category-interchangeable CRM shell with Thai astrology labels. Vocabulary (`ลูกดวง`, mineral weekday tints, Warm Zen canopy) is specific; structure is generic metric+list dashboard. DESIGN’s Auspicious Focus Hero and primary อวยพร never appear on Home. LINE blessing UI exists as dead widgets and visually drifts toward Western greeting SaaS (indigo “HAPPY BIRTHDAY”).

**Deterministic scan:** 1 warning — `design-system-font` / `Inter` at `lib/widgets/studio_quick_actions.dart:169` (not in DESIGN.md). Exit 0. Confirms token schizophrenia. Browser overlays skipped (Flutter adaptive; no injectable HTML surface). Manual mechanical notes: no Semantics in target files; multiple sub-48dp / shrinkWrap tap targets in home, banner, HBD, chatbox, customer_card.

## Overall Impression

Warm canopy craft is real, but the product’s stated job — morning auspicious check → one-tap LINE blessing — is not on the critical path. Biggest opportunity: wire อวยพร onto today’s rows and put สีมงคล/ฤกษ์ back on Home.

## What's Working

1. Home birthday row craft — mineral monogram, `วันนี้!` / countdown, Thai weekday + turning age, seamless inset list.
2. Warm Zen canopy — Prompt brand, Sarabun subtitle, celestial watermark, caramel primary CTA atmosphere.
3. Adaptive shell hygiene — labeled NavigationBar, cake Badge, SafeArea, bottom-sheet delete on mobile.

## Priority Issues

### P0 — Morning LINE blessing not on critical path
- **What:** Home birthday rows open detail only; Hub copies LINE ID; `BirthdayChatboxDialog` / `HbdCardDialog` / `BirthdayAlertBanner` unmounted from views.
- **Why:** PRODUCT success = deliver blessings via LINE with zero friction — currently impossible from live UI.
- **Fix:** Primary `อวยพร` on today’s Home rows + Hub spotlight; wire HBD/chatbox; drop “Chatbox” label.
- **Suggested command:** clarify (then delight for post-copy ritual feedback)

### P1 — Home omits auspicious morning check
- **What:** No สีมงคล / ทิศมงคล / ฤกษ์ on Home; only in Hub empty-today pavilion.
- **Why:** Morning ritual is auspicious day AND birthdays; Home fails half the brief when celebrants exist.
- **Fix:** Auspicious Focus Hero above birthday list.
- **Suggested command:** layout

### P1 — Visual / token schizophrenia across blessing stack
- **What:** Live Warm Zen vs dead indigo HBD card; banner blue Chatbox; day hex ≠ AppColors; Inter in StudioQuickActions (detector confirmed).
- **Why:** Undermines sacred-trust brand if those widgets ship as-is.
- **Fix:** One mineral palette + Prompt/Sarabun only; warm champagne HBD card; delete Inter.
- **Suggested command:** colorize / quieter

### P2 — Competing secondary jobs on Home
- **What:** สถิติ + notes ledger peer with birthday ritual; StudioQuickActions unused.
- **Why:** Distracted morning users miss celebrants.
- **Fix:** Demote notes; one add affordance; mount or delete Quick Actions.
- **Suggested command:** distill

### P3 — Blessing copy / honorific polish
- **What:** Templates `ครับ/ค่ะ`; English HAPPY BIRTHDAY on card.
- **Why:** Awkward paste into LINE.
- **Fix:** Neutral Thai close or voice setting; Thai card title.
- **Suggested command:** clarify

## Persona Red Flags

**Casey (Distracted Mobile):** Bless action absent (not in thumb zone); top-right add/stats compete; no “เหลือต้องอวยพร” checklist; shrinkWrap buttons if banner wired.

**Jordan (First-Timer):** Sees CRM metrics not “เช้านี้ทำอะไร”; `วันนี้!` → detail not bless; near-synonym tab labels; never discovers dead blessing UI.

**คุณหมอ (Thai astrologer morning ritual):** Cannot complete open → สีมงคล → list today → compose blessing → LINE; Hub copies handle not message; feels like contact directory with cake badges.

## Minor Observations

- DESIGN Quick Actions / อวยพร diverged from Home without ritual IA update.
- `CustomerCard.onBirthdayBlessing` declared never rendered.
- Header gradient may wash contrast; compact header icon-only สถิติ.
- Confetti on chatbox open (dead) celebrates panel open not blessing done.
- Manual: missing Semantics; sub-48dp targets across blessing widgets.

## Questions to Consider

1. If Home’s only 9 a.m. job is who to bless and with what text, why do สถิติ and notes share first scroll?
2. Is the product a LINE ID copy tool, or a ready-to-paste auspicious message — and why is that UI unmounted?
3. Should today-birthdays replace the auspicious pavilion, or should สีมงคล always lead?
4. Confident end-state: SnackBar “คัดลอกแล้ว”, or “อวยพรแล้ว · N/M” checklist?
