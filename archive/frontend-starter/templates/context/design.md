# Design & UI — AI Agent Rules

Applies to: Tailwind CSS, component design systems, accessibility, responsive design.

## Design System Foundations (Tailwind v4 — CSS-first config)

This project uses **Tailwind CSS v4**. There is **no `tailwind.config.ts`/`.js` file**. All design tokens (colors, spacing, typography, radii, shadows, breakpoints) are defined directly in `globals.css` using the `@theme` directive and plain CSS variables. Do not create a `tailwind.config.*` file and do not instruct the user to add one — that pattern is v3-only and must not be reintroduced.

- All colors, spacing, typography, radii, and shadows must come from tokens defined in `globals.css`, never hardcoded arbitrary values (`text-[#3b82f6]`, `mt-[13px]`) unless there is no reasonable token and the one-off is justified in a comment.
- Tokens are declared in **two layers**, always in `globals.css`:
  1. **`:root`** — the raw value (source of truth): hex/oklch/rgb, raw pixel/rem spacing values, font stacks, etc.
  2. **`@theme`** — maps each raw variable into a Tailwind-recognized theme variable (`--color-*`, `--spacing-*`, `--font-*`, `--radius-*`, `--shadow-*`, `--breakpoint-*`), pointing back to the `:root` variable via `var(...)`.

  ```css
  /* globals.css */

  :root {
    --primary-tint-color-400: #499cf5;
    --font-sans-family: "Inter", sans-serif;
    --radius-card: 0.75rem;
  }

  @theme {
    --color-primary-tint-400: var(--primary-tint-color-400);
    --font-sans: var(--font-sans-family);
    --radius-card: var(--radius-card);
  }
  ```

  This two-layer split matters: `:root` holds the raw, swappable value (e.g., what changes per dark mode or white-label theme), while `@theme` is what actually generates the Tailwind utility classes (`bg-primary-tint-400`, `font-sans`, `rounded-card`, etc.). Never define a color directly inside `@theme` without a backing `:root` variable — this breaks theme-switching and forces hunting through `@theme` to change a single value.

- Dark mode / white-labeling: override the `:root` variable's value inside `.dark` (or the relevant theme class/attribute selector) — the `@theme` mapping itself never changes, only what the `:root` variable resolves to.
  ```css
  .dark {
    --primary-tint-color-400: #1e5fa8;
  }
  ```
- Component variants (size, intent, state) must be handled with a variant utility (`class-variance-authority`/`cva` or `tailwind-variants`), not chained ternaries of class strings.
- Never use the Tailwind v3 patterns: no `tailwind.config.js` `theme.extend`, no `theme()` helper function in CSS (use the CSS variable directly instead), no `content: []` glob config (v4 auto-detects via the CSS `@import`/`@source` mechanism).

## Color Palette Rules

**Goal:** every color in the project must be defined systematically and extensibly so it can be reused consistently across UI, theming, and Tailwind utilities. No color may be hardcoded (`#HEX`, `rgb()`, `oklch()`, etc.) directly inside a component, inline style, or class — it must always resolve through a named token.

### Structure

Colors are defined in `globals.css` and **only** in `globals.css`, split across the same two sections described above:

1. **`:root`** — the raw color value:
   ```css
   :root {
     --primary-tint-color-400: #499cf5;
   }
   ```
2. **`@theme`** — the Tailwind-facing color token, bound to the `:root` variable:
   ```css
   @theme {
     --color-primary-tint-400: var(--primary-tint-color-400);
   }
   ```

This produces a usable utility class automatically (e.g. `bg-primary-tint-400`, `text-primary-tint-400`, `border-primary-tint-400`).

### Naming & Scale Convention

- Each color family gets a semantic or brand-based name (`primary`, `red`, `yellow`, `green`, `gray`, `light`, etc.) followed by a numeric scale.
- **Lower number = darker/more intense; higher number = lighter/more muted**, consistently across every family in the project. Do not mix conventions (e.g., one family going light-to-dark and another dark-to-light) — pick one direction project-wide and follow it exactly, matching whatever numbering convention the design/product team has already established for that palette.
- Numbered variants may map to specific interaction states where relevant (e.g., a "darker" shade used for a `:hover` state, a "very light/tinted" shade used for subtle backgrounds) — this mapping should be documented as a comment next to the token if it isn't self-evident from the name alone.
- Every raw value in `:root` must have a corresponding `@theme` mapping — never leave a defined color unused/unmapped, and never add a color to `@theme` that doesn't trace back to a `:root` source variable.

### Rules for the AI Agent

- When asked to add a new color to the palette, add it in **both** places (`:root` raw value, then `@theme` mapping) — never one without the other.
- When a new color is needed but not yet defined, do not invent an arbitrary Tailwind value (`bg-[#123456]`) as a permanent solution — stop and add the proper token to `globals.css` first, following the existing naming/scale convention already used in the file.
- Reuse an existing token if a close match already exists in the palette rather than introducing a near-duplicate shade.
- Component code must only ever reference color tokens via Tailwind utility classes generated from `@theme` (`bg-red-2`, `text-gray-1`, etc.) — never via raw CSS variables sprinkled directly in `className` inline styles, and never via hardcoded hex/rgb/oklch values anywhere in `.tsx`/`.jsx` files.

## Component API Design

- Every reusable UI component accepts `className` and merges it via `cn()`/`clsx` + `tailwind-merge`, so consumers can extend without fighting specificity:
  ```tsx
  function Button({ className, variant, ...props }: ButtonProps) {
    return (
      <button
        className={cn(buttonVariants({ variant }), className)}
        {...props}
      />
    );
  }
  ```
- Prefer **composition over configuration**: expose `children`/slot patterns instead of a growing list of boolean props (`showIcon`, `showBadge`, `showFooter`...).
- Use `forwardRef` on any component wrapping a native element that might need ref access (inputs, buttons, dialogs).
- Controlled and uncontrolled variants: support both where it's a form input (`value`/`onChange` optional, fallback to internal state).

## Accessibility (Non-Negotiable)

- All interactive elements must be reachable and operable via keyboard (`Tab`, `Enter`, `Space`, `Esc`, arrow keys where semantically expected — e.g., menus, tabs, radio groups).
- Use semantic HTML first (`<button>`, `<nav>`, `<label>`, `<table>`) before reaching for ARIA. ARIA supplements semantics, it doesn't replace them.
- Every image needs meaningful `alt` (or `alt=""` if purely decorative).
- Every form input needs an associated `<label>` (visible or `sr-only`, never placeholder-as-label).
- Color contrast must meet WCAG AA minimum (4.5:1 for normal text, 3:1 for large text/UI components) — verify token pairs (e.g., text on brand background) against this, not just "looks fine."
- Focus states must be visible (`focus-visible:ring-2` or equivalent) — never `outline-none` without a replacement focus indicator.
- Modals/dialogs must trap focus, restore focus on close, and be dismissible via `Esc`. Prefer a primitive library (Radix UI, React Aria) over hand-rolled focus trapping.
- Respect `prefers-reduced-motion` for non-essential animations.
- Use headless/accessible primitive libraries (Radix UI, React Aria, Headless UI) for complex interactive components (dropdowns, comboboxes, dialogs, tooltips) rather than building from scratch — accessibility edge cases are extremely easy to get wrong manually.

## Responsive Design

- Mobile-first: base classes target the smallest viewport, then layer `sm:`/`md:`/`lg:`/`xl:` upward. Never design desktop-first and add `max-md:` overrides as the primary strategy.
- Use Tailwind's default breakpoints unless the product has a documented reason to customize them.
- Test/consider three reference widths minimum: ~375px (mobile), ~768px (tablet), ~1280px+ (desktop).
- Avoid fixed pixel widths on containers that should flex; prefer `max-w-*`, `w-full`, and grid/flex layouts.
- Touch targets on mobile must be at least 44x44px (`min-h-11 min-w-11` or equivalent padding).

## Dark Mode

- Use Tailwind's `dark:` variant with `class` strategy (not `media`) so it can be user-toggled and persisted, unless the product explicitly wants OS-only. In v4, configure this via `@custom-variant dark (&:where(.dark, .dark *));` in `globals.css` — not a `darkMode` config option, since there is no config file.
- Every custom color token needs a dark-mode counterpart defined at the `:root`/`.dark` variable level (raw value swap, as shown in the Color Palette Rules section), not sprinkled `dark:` utility overrides all over feature code.

## Performance-Conscious UI

- Use `next/image` for all images — never raw `<img>` for content images — to get automatic sizing, lazy loading, and format optimization.
- Use `next/font` for font loading (avoids layout shift, self-hosts Google Fonts).
- Avoid layout shift: reserve space (aspect-ratio, explicit width/height) for images, ads, embeds, and async-loaded content.
- Animate only `transform` and `opacity` where possible (GPU-accelerated); avoid animating `width`/`height`/`top`/`left` for anything performance-sensitive.
- Lazy-load below-the-fold heavy components with `next/dynamic`.

## Consistency Rules

- One icon library per project (e.g., `lucide-react`) — do not mix icon sets.
- One date library per project (`date-fns` or `dayjs` preferred over `moment`, which is legacy/unmaintained).
- Reuse existing UI primitives from `components/ui` before creating a new one; if a similar component exists, extend its variants rather than duplicating.
- Follow existing spacing rhythm (4px/8px base scale via Tailwind default) — don't introduce arbitrary spacing that breaks the grid.

## Anti-Patterns

- ❌ Inline `style={{}}` for anything expressible in Tailwind utilities.
- ❌ `!important` (`!text-red-500`) as a first resort for specificity issues — fix the source of the conflict.
- ❌ Copy-pasting a component and tweaking classes instead of adding a variant.
- ❌ Divs with `onClick` acting as buttons/links (breaks keyboard access and semantics) — use real `<button>`/`<a>`.
- ❌ Disabling ESLint's `jsx-a11y` rules to silence warnings instead of fixing them.
- ❌ Shipping a component with only a "happy path" visual state — always account for loading, empty, error, and disabled states.
- ❌ Creating a `tailwind.config.ts`/`.js` file, or writing v3-style `theme.extend` config — this project uses Tailwind v4's CSS-first `@theme` config in `globals.css`.
- ❌ Hardcoding a raw color value (`#499cf5`, `rgb(...)`, `oklch(...)`) anywhere outside the `:root` block in `globals.css`.
- ❌ Adding a color to `@theme` without a matching `:root` source variable, or vice versa.
