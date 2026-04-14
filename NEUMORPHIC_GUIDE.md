# Fit Freak X — Neumorphic Design Guide

## 1. Color Palette

| Token | Hex | Usage |
|---|---|---|
| **Base Surface** | `#F0F0F3` | Every `Scaffold`, card, and container background. **Never** use pure `#FFFFFF` as a surface. |
| **Accent** | `#FF6B00` | CTA buttons, progress rings, active nav icons, hero metrics. Use sparingly for maximum impact. |
| **Accent Pressed** | `#E55D00` | Darker shade for button press states. |
| **Light Shadow** | `#FFFFFF` | Top-left highlight to simulate light source. |
| **Dark Shadow** | `#BEBEBE` | Bottom-right depth to simulate shadow. |
| **Text Primary** | `#2D2D2D` | Headings and high-importance body text. |
| **Text Secondary** | `#8A8A8E` | Subtitles, labels, and helper text. |
| **Error / Danger** | `#E53935` | Delete Account, validation errors. |

---

## 2. Shadow Constants

### Extruded (Outer / Convex) — For Buttons, Cards, Containers

The element appears to **rise out** of the surface.

```dart
const kNeumorphicExtruded = [
  BoxShadow(
    color: Color(0xFFBEBEBE),   // dark shadow
    offset: Offset(5, 5),
    blurRadius: 15,
    spreadRadius: 1,
  ),
  BoxShadow(
    color: Color(0xFFFFFFFF),   // light shadow
    offset: Offset(-5, -5),
    blurRadius: 15,
    spreadRadius: 1,
  ),
];
```

### Inverted (Inner / Concave) — For Text Fields, Sliders, Inset Areas

The element appears to **sink into** the surface. Achieved by painting an inner shadow using a `Container` > `DecoratedBox` stack or using `ShaderMask`.

```dart
// Simulated with a gradient + border trick:
BoxDecoration kNeumorphicInverted = BoxDecoration(
  color: const Color(0xFFF0F0F3),
  borderRadius: BorderRadius.circular(12),
  boxShadow: const [
    BoxShadow(
      color: Color(0xFFBEBEBE),
      offset: Offset(2, 2),
      blurRadius: 4,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0xFFFFFFFF),
      offset: Offset(-2, -2),
      blurRadius: 4,
      spreadRadius: 0,
    ),
  ],
  gradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      const Color(0xFFE8E8EB),  // slightly darker top-left
      const Color(0xFFF0F0F3),  // base
      const Color(0xFFF8F8FB),  // slightly lighter bottom-right
    ],
  ),
);
```

---

## 3. Widget-to-Shadow Mapping

| Widget | Shadow Type | Notes |
|---|---|---|
| `NeumorphicBox` (card) | **Extruded** | Hero tiles, info cards, chart containers |
| `NeumorphicButton` | **Extruded → Flat on press** | Shadows animate to zero on tap-down |
| `NeumorphicButton (accent)` | **Extruded + orange glow** | CTA buttons, filled with `#FF6B00` |
| `NeumorphicInput` | **Inverted** | Login fields, meal input, search bars |
| `NeumorphicProgressRing` | **Extruded circle** | Daily calorie ring on Dashboard |

---

## 4. Corner Radii

| Element | Radius | Rationale |
|---|---|---|
| Cards / Containers | `20px` | Large, soft curves for the pillowy feel |
| Buttons | `12px` | Tighter, more interactive affordance |
| Text Inputs | `12px` | Match buttons for visual consistency |
| Bottom Nav | `24px` (top corners) | Soft float above the scaffold edge |
| Avatar / Icons | `50%` (circle) | — |

---

## 5. Typography

- **Primary Font:** Google Fonts **Poppins** — headings, metric numbers.
- **Secondary Font:** Google Fonts **Inter** — body text, labels.
- **Impact Rule:** Use font **weight** (Bold / ExtraBold) over font **size** to create hierarchy. Reserve the orange accent color for **hero numbers** (e.g., `1000 kcal left`, `74 kg`, `BMI 22.1`).

---

## 6. Implementation Rules

1. **Background is sacred.** `Scaffold.backgroundColor` and every container surface = `#F0F0F3`. If the white highlight shadow is invisible, the background is wrong.
2. **Orange screams, not whispers.** Reserve `#FF6B00` for: CTA buttons, the calorie ring progress arc, active bottom-nav icons, and hero metric labels. Everything else stays grayscale.
3. **Press = Flatten.** When a user taps a neumorphic element, remove the box shadows entirely (creating the "pressed into surface" illusion). Release restores them with a 150ms `AnimatedContainer`.
4. **Inverted inputs.** Text fields must use the concave/inverted shadow to feel "recessed" into the surface, contrasting with the extruded cards around them.
5. **No elevation.** Never use Material `elevation`. It produces a single hard drop-shadow that breaks the dual-shadow neumorphic contract.
