# Neumorphic Design Guide

This guide defines the core constants and logic for building the Neumorphic (Soft UI) aesthetic in Fit Freak X.

## Color Palette
| Element | Hex Code | Description |
| :--- | :--- | :--- |
| **Base Surface** | `#F0F0F3` | The primary background color. Crucial for making white shadows pop. Never use pure #FFFFFF as the background. |
| **Accent Primary** | `#FF6B00` | High-energy Orange for active states, CTA buttons, and progress charts. Used for screaming attention. |
| **Highlight Shadow** | `#FFFFFF` | Top-left shadow for structural pop. |
| **Depth Shadow** | `#BEBEBE` | Bottom-right shadow for structural depth. |
| **Text Primary** | `#2D2D2D` | Dark gray for readable titles and primary text. |
| **Text Secondary**| `#8A8A8E` | Lighter gray for subtitles and body text. |

## Neumorphic Shadow Constants
To ensure consistency across the application, use these established shadows rather than hardcoding BoxShadows across components.

```dart
// The typical raised effect (Convex)
const List<BoxShadow> neumorphicShadowOuter = [
  BoxShadow(
    color: Color(0xFFBEBEBE), // Depth Shadow
    offset: Offset(4.0, 4.0),
    blurRadius: 10.0,
    spreadRadius: 1.0,
  ),
  BoxShadow(
    color: Color(0xFFFFFFFF), // Highlight Shadow
    offset: Offset(-4.0, -4.0),
    blurRadius: 10.0,
    spreadRadius: 1.0,
  ),
];
```

## Typography
Font Family: **Google Fonts 'Poppins'** or **'Inter'**.
- Emphasize weight over size to create impact (e.g., bold orange text for metrics/totals).

## Key Implementation Rules
1. **The Base is Everything.** The base scaffold and app background must always be `#F0F0F3` to allow the `#FFFFFF` highlight to function.
2. **Orange Accent Sparingly.** Use `#FF6B00` exclusively for active interactions (pressed states) or critical data that needs attention (e.g., "Total Protein" or "Max Bench").
3. **Corner Radii.** Standardize on continuous curves to maintain the soft aesthetic.
   - Cards/Containers: `BorderRadius.circular(20.0)`
   - Buttons: `BorderRadius.circular(12.0)`
4. **Icons.** Use simple, line-based icons that scale well without cluttering the UI. When active, tint them with the Orange Accent.
