# UX/UI Quality — Full Metric Reference

> Based on WCAG 2.2 (W3C, 2023), WAI-ARIA 1.2 (W3C, 2023), Core Web Vitals (Google, 2024),
> Lighthouse Scoring (Google), Nielsen's 10 Usability Heuristics (Nielsen, 1994), Laws of UX
> (Yablonski, 2020), Atomic Design (Frost, 2016), Material Design Motion Guidelines (Google),
> Baymard Institute UX Research, NNGroup Research, Gestalt Principles of Visual Perception,
> W3C Internationalization Best Practices, and ICU MessageFormat specification.
>
> Fixed stack: **Next.js App Router + shadcn/ui + Tailwind CSS**

---

## Grading Scale

| Grade | Score | Interpretation |
|-------|-------|----------------|
| A+ | 97-100 | World-class — accessible, performant, polished, delightful at every breakpoint |
| A | 93-96 | Excellent — mature UX, minor gaps in edge states or polish |
| A- | 90-92 | Very Good — strong UX across dimensions, few missing pieces |
| B+ | 87-89 | Good — solid UX, some accessibility or responsive gaps |
| B | 83-86 | Above Average — key UX patterns in place, gaps in polish/consistency |
| B- | 80-82 | Adequate — basic UX, significant interaction or edge-state opportunities |
| C+ | 77-79 | Below Average — functional but unpolished, accessibility debt |
| C | 73-76 | Mediocre — inconsistent UX, no systematic approach to components/states |
| C- | 70-72 | Poor — usability issues actively impacting user satisfaction |
| D+ | 67-69 | Bad — major accessibility violations, broken responsive, no loading states |
| D | 63-66 | Very Bad — inaccessible, visually broken, no error handling |
| D- | 60-62 | Critical — unusable for significant user segments |
| F | 0-59 | Failing — UX actively prevents task completion and excludes users |

---

## D1: Accessibility & Inclusivity (Weight: 12%)

**Source:** WCAG 2.2 (W3C, 2023), WAI-ARIA 1.2 (W3C, 2023), Inclusive Design Principles (Microsoft)

### M1.1: Semantic HTML & ARIA Usage (25% of D1)

Proper heading hierarchy, landmark regions, ARIA roles, and semantic elements.

| Score | Criteria |
|-------|----------|
| 100 | All pages use semantic HTML5 landmarks (`<main>`, `<nav>`, `<aside>`, `<header>`, `<footer>`), proper heading hierarchy (h1-h6, no skips), ARIA roles only where native semantics insufficient, `role="alert"` / `role="status"` for dynamic content, all shadcn Dialog/Sheet/Popover use proper `aria-*` attributes |
| 90 | Semantic landmarks on all pages, heading hierarchy mostly correct, ARIA used correctly on custom widgets, shadcn components unmodified (inheriting built-in a11y) |
| 80 | Landmarks on main layouts, heading hierarchy with minor skips, ARIA on most custom interactive elements |
| 70 | Some semantic elements, heading hierarchy has gaps, `<div>` used for some interactive elements with ARIA |
| 60 | Basic `<main>` present, headings inconsistent, some clickable `<div>` without roles |
| 40 | Mostly `<div>` soup, no landmarks, headings used for styling not structure |
| 20 | No semantic HTML, no ARIA, `<div>` and `<span>` for everything including interactive elements |

### M1.2: Keyboard Navigation (25% of D1)

Focus order, focus visibility, skip links, absence of keyboard traps.

| Score | Criteria |
|-------|----------|
| 100 | Logical tab order on all pages, visible focus rings (Tailwind `ring-*`), skip-to-content link, no keyboard traps, `Escape` closes all overlays (shadcn Dialog/Sheet/DropdownMenu), arrow key navigation in menus/lists, roving tabindex in composite widgets, focus restored after modal close |
| 90 | Logical tab order, visible focus rings, skip link, `Escape` closes overlays, focus restoration, shadcn components navigable via keyboard |
| 80 | Logical tab order, visible focus rings, most overlays keyboard-dismissible, no keyboard traps |
| 70 | Mostly logical tab order, focus visible on most elements, some overlays trap focus correctly |
| 60 | Basic tab order works, focus rings on some elements (Tailwind `focus-visible:ring-*`), some keyboard traps in custom components |
| 40 | Tab order mostly works but has gaps, focus rings removed or invisible, overlays not keyboard-dismissible |
| 20 | Tab order broken, no focus visibility, keyboard traps present, cannot complete flows via keyboard |

### M1.3: Color Contrast & Visual (25% of D1)

WCAG AA contrast ratios, information not conveyed by color alone.

| Score | Criteria |
|-------|----------|
| 100 | All text meets WCAG AA (4.5:1 normal, 3:1 large), all UI components meet 3:1 against adjacent, color never sole indicator (icons/patterns/text accompany), Tailwind color palette validated, dark mode contrast verified, focus indicators 3:1 contrast |
| 90 | All text AA compliant, UI components 3:1, color not sole indicator for status/errors, dark mode passes |
| 80 | 95%+ text AA compliant, most UI components pass, color augmented with icons for errors/status |
| 70 | 90%+ text AA compliant, some low-contrast secondary text, error states use red + icon |
| 60 | Most body text passes, headings pass, some interactive elements or muted text below 4.5:1 |
| 40 | Significant contrast failures, placeholder text unreadable, status conveyed by color alone |
| 20 | Widespread contrast failures, color-only indicators, text on images without overlay |

### M1.4: Screen Reader Compatibility (25% of D1)

Alt text, live regions, form labels, status announcements.

| Score | Criteria |
|-------|----------|
| 100 | All `next/image` have meaningful `alt` (or `alt=""` for decorative), `aria-live` regions for dynamic content (toast via shadcn Sonner/Toast), all form inputs labeled (`<Label>` from shadcn), `aria-describedby` for help text, `aria-invalid` + `aria-errormessage` for errors, route changes announced, loading states announced |
| 90 | Alt text on all images, live regions for toasts/alerts, form inputs labeled, error states announced |
| 80 | Alt text on most images, some live regions, form labels present, basic error announcement |
| 70 | Alt text on key images, form labels mostly present, toast notifications not announced |
| 60 | Some alt text, form labels via placeholder only (not accessible), no live regions |
| 40 | Missing alt text widespread, form inputs without labels, no announcements for dynamic content |
| 20 | No alt text, no form labels, no live regions, screen reader cannot navigate the application |

**D1 formula:** `D1 = (M1.1 * 0.25) + (M1.2 * 0.25) + (M1.3 * 0.25) + (M1.4 * 0.25)`

---

## D2: Performance & Web Vitals (Weight: 12%)

**Source:** Core Web Vitals (Google, 2024), Lighthouse Scoring v11, web.dev performance guidelines

### M2.1: LCP — Largest Contentful Paint (25% of D2)

Time until the largest content element is rendered.

| Score | Criteria |
|-------|----------|
| 100 | LCP < 1.5s on all routes, `next/image` with `priority` on LCP element, `next/font` for web fonts, above-fold content server-rendered (RSC), no layout-blocking resources |
| 90 | LCP < 2.0s on all routes, `next/image` with priority on hero images, fonts preloaded, RSC for main content |
| 80 | LCP < 2.5s on 90%+ routes (good threshold), `next/image` used, fonts loaded efficiently |
| 70 | LCP < 3.0s on most routes, `next/image` on some images, some render-blocking resources |
| 60 | LCP < 4.0s (needs improvement threshold), images unoptimized, client-side data fetching delays paint |
| 40 | LCP 4-6s, no `next/image`, large unoptimized hero images, fonts cause FOIT |
| 20 | LCP > 6s, entire page client-rendered, no image optimization, blocking resources |

### M2.2: INP — Interaction to Next Paint (25% of D2)

Responsiveness of the page to user interactions.

| Score | Criteria |
|-------|----------|
| 100 | INP < 100ms, all event handlers non-blocking, `useTransition` for expensive state updates, `useDeferredValue` for search/filter, no synchronous layout thrashing, Web Workers for heavy computation |
| 90 | INP < 150ms, `useTransition` for route-level updates, event handlers optimized, debounced inputs |
| 80 | INP < 200ms (good threshold), most interactions responsive, some heavy handlers identified |
| 70 | INP < 300ms, noticeable lag on some interactions, unoptimized re-renders |
| 60 | INP < 500ms (needs improvement), significant lag on filters/sorts, blocking state updates |
| 40 | INP 500ms-1s, UI freezes during data processing, no transition/deferral patterns |
| 20 | INP > 1s, UI unresponsive during interactions, synchronous heavy operations on main thread |

### M2.3: CLS — Cumulative Layout Shift (25% of D2)

Visual stability — unexpected layout movements.

| Score | Criteria |
|-------|----------|
| 100 | CLS < 0.05, all images have `width`/`height` (or `next/image` with `fill` + `sizes`), fonts use `next/font` (no FOUT shift), skeleton placeholders match final layout dimensions, no content injection shifts |
| 90 | CLS < 0.08, images sized, fonts stable, skeleton states prevent major shifts |
| 80 | CLS < 0.1 (good threshold), most images sized via `next/image`, minor shifts on dynamic content |
| 70 | CLS < 0.15, some images cause shifts, font loading causes minor FOUT |
| 60 | CLS < 0.25 (needs improvement), ads/banners shift content, lazy-loaded content causes jumps |
| 40 | CLS 0.25-0.5, significant shifts from images without dimensions, late-loading UI elements |
| 20 | CLS > 0.5, page jumps repeatedly during load, no image sizing, content injected above viewport |

### M2.4: Bundle & Asset Optimization (25% of D2)

Code splitting, image optimization, font loading, tree shaking.

| Score | Criteria |
|-------|----------|
| 100 | Route-based code splitting (App Router default), `dynamic()` for heavy components, `next/image` everywhere, `next/font` for all fonts, Tailwind purge configured, no unused JS, barrel file imports optimized, `@next/bundle-analyzer` used, total JS < 100KB first load |
| 90 | Route splitting + `dynamic()` for large components, `next/image`, `next/font`, Tailwind purged, first load JS < 150KB |
| 80 | Route splitting working, `next/image` on most images, `next/font`, first load JS < 200KB |
| 70 | Route splitting, some large client bundles, `next/image` partially adopted, first load JS < 300KB |
| 60 | Route splitting but large shared chunks, unoptimized images mixed in, first load JS < 400KB |
| 40 | Minimal code splitting, large bundles, many unoptimized images, first load JS > 400KB |
| 20 | No code splitting, all JS loaded upfront, no image optimization, no font strategy |

**D2 formula:** `D2 = (M2.1 * 0.25) + (M2.2 * 0.25) + (M2.3 * 0.25) + (M2.4 * 0.25)`

---

## D3: Component & Design System (Weight: 10%)

**Source:** Atomic Design (Frost, 2016), shadcn/ui best practices, Composition vs Inheritance (React docs)

### M3.1: shadcn Adoption Rate (30% of D3)

Percentage of UI built with shadcn components vs custom implementations.

| Score | Criteria |
|-------|----------|
| 100 | 95%+ of UI primitives from shadcn (Button, Input, Dialog, Sheet, DropdownMenu, Table, Card, Badge, Tabs, etc.), custom components only for domain-specific widgets, all shadcn components use `cn()` utility for className merging |
| 90 | 90%+ shadcn adoption, 1-2 custom primitives with documented rationale, `cn()` used consistently |
| 80 | 80%+ shadcn, some custom buttons/inputs that could be shadcn variants |
| 70 | 70%+ shadcn, several custom implementations of components available in shadcn registry |
| 60 | 50%+ shadcn, mix of custom and shadcn, inconsistent patterns |
| 40 | < 50% shadcn, many hand-rolled components duplicating shadcn functionality |
| 20 | Minimal shadcn usage, mostly custom components, no design system consistency |

### M3.2: Registry Utilization (25% of D3)

Available shadcn registry components that are not yet adopted where they would improve UX.

| Score | Criteria |
|-------|----------|
| 100 | All applicable registry components adopted (Command for search, Sonner/Toast for notifications, DataTable for lists, Calendar for dates, Combobox for select+search, Sheet for mobile nav, AlertDialog for destructive actions), zero missed opportunities |
| 90 | 90%+ applicable components adopted, 1-2 minor gaps identified |
| 80 | 80%+ adopted, some custom implementations where registry components exist (e.g., custom modal vs Dialog) |
| 70 | Core components adopted (Button, Input, Card), but missing specialized ones (Command, Combobox, DataTable) |
| 60 | Basic components adopted, significant registry components unused (e.g., hand-rolled toast, custom dropdown) |
| 40 | Minimal registry utilization, most UI hand-built despite registry alternatives |
| 20 | Registry essentially unused, all components custom-built |

### M3.3: Composition Patterns (25% of D3)

Compound components, slots, composition over prop drilling.

| Score | Criteria |
|-------|----------|
| 100 | Compound component pattern (e.g., `<Card><CardHeader>...`), render props/slots where needed, no prop drilling > 2 levels, `children` used for flexibility, `React.forwardRef` on all custom interactive components, `asChild` pattern from Radix used correctly |
| 90 | Compound components for complex UI, minimal prop drilling, `forwardRef` on custom components, composition via children |
| 80 | Good composition patterns, occasional prop drilling (3 levels), `forwardRef` on most components |
| 70 | Some composition, prop drilling in places (4+ levels), wrapper components instead of composition |
| 60 | Prop drilling common, monolithic components with many props (10+), limited composition |
| 40 | Heavy prop drilling, god components with 15+ props, no composition patterns |
| 20 | All-in-one components, no composition, massive prop lists, tightly coupled UI |

### M3.4: Design Token Consistency (20% of D3)

CSS variables, Tailwind config, absence of magic numbers.

| Score | Criteria |
|-------|----------|
| 100 | All colors via CSS variables (`--primary`, `--secondary`, etc. in `globals.css`), Tailwind config extends theme consistently, zero arbitrary values (`[#hex]`, `[13px]`), spacing uses Tailwind scale (p-4 not p-[15px]), border-radius via `rounded-*` tokens, shadows via design tokens |
| 90 | CSS variables for colors, Tailwind theme extended, < 5 arbitrary values in entire codebase |
| 80 | CSS variables for most colors, Tailwind config used, < 10 arbitrary values |
| 70 | CSS variables for primary palette, some inline hex codes, occasional arbitrary spacing |
| 60 | Mix of CSS variables and hardcoded values, arbitrary values in 10%+ of components |
| 40 | Mostly hardcoded colors/spacing, Tailwind config barely customized, many magic numbers |
| 20 | No design tokens, hardcoded hex everywhere, arbitrary values throughout, no Tailwind config customization |

**D3 formula:** `D3 = (M3.1 * 0.30) + (M3.2 * 0.25) + (M3.3 * 0.25) + (M3.4 * 0.20)`

---

## D4: Responsive & Adaptive (Weight: 10%)

**Source:** Mobile-First Design (Luke Wroblewski), WCAG 2.5 (Input Modalities), Responsive Web Design (Ethan Marcotte)

### M4.1: Mobile-First Implementation (30% of D4)

Base styles target mobile, progressive enhancement via breakpoints.

| Score | Criteria |
|-------|----------|
| 100 | All components mobile-first (base = mobile, `md:` / `lg:` for desktop), navigation collapses to Sheet/hamburger on mobile, tables convert to cards on mobile, sidebars become Sheet overlays, touch-optimized by default |
| 90 | 95%+ mobile-first, navigation responsive, tables/lists adapt, Sheet for mobile panels |
| 80 | 90%+ mobile-first, main layouts responsive, some components need horizontal scroll on mobile |
| 70 | Most layouts mobile-first, some desktop-first components (hidden on mobile or broken) |
| 60 | Key pages responsive, secondary pages desktop-only, some content clipped on mobile |
| 40 | Desktop-first with `sm:` overrides, many components break on mobile, horizontal scroll common |
| 20 | Desktop-only design, no responsive breakpoints, unusable on mobile devices |

### M4.2: Touch Target Size (25% of D4)

Minimum interactive element size per WCAG 2.5.8.

| Score | Criteria |
|-------|----------|
| 100 | All interactive elements >= 44x44px touch target (or 44px spacing between smaller targets), shadcn Button/IconButton sized appropriately, close buttons in Dialog/Sheet adequately sized, spacing between list action buttons sufficient, mobile nav items >= 48px height |
| 90 | 95%+ targets meet 44x44px, minor exceptions for inline text links with adequate spacing |
| 80 | 90%+ targets adequate, some icon buttons < 44px but with padding compensation |
| 70 | Most buttons/links adequate, some toolbar icons or table row actions too small |
| 60 | Primary CTAs sized well, secondary actions and icon buttons frequently < 44px |
| 40 | Many targets < 44px, especially on mobile, icon buttons 24-32px without padding |
| 20 | Touch targets widely undersized, fat-finger errors common, no mobile size consideration |

### M4.3: Fluid Typography & Spacing (25% of D4)

Responsive text sizing, no fixed px for body text, fluid scales.

| Score | Criteria |
|-------|----------|
| 100 | `clamp()` for headings (e.g., `text-[clamp(1.5rem,4vw,2.5rem)]`), Tailwind responsive text (`text-sm md:text-base lg:text-lg`), body text >= 16px on mobile, line height 1.5+ for body, spacing scales with viewport, no horizontal scroll from oversized text |
| 90 | Responsive text classes on headings, body text >= 16px, proper line heights, spacing scales at breakpoints |
| 80 | Most text responsive via Tailwind breakpoint classes, body text readable, occasional fixed sizes |
| 70 | Some responsive text, body text sometimes < 16px on mobile, line heights mostly ok |
| 60 | Basic responsive text on headings, body text fixed, some text overflow on mobile |
| 40 | Mostly fixed text sizes, small text on mobile, poor line heights, text truncation issues |
| 20 | All text fixed px, unreadable on mobile, no responsive typography consideration |

### M4.4: Breakpoint Coverage (20% of D4)

Tested at sm/md/lg/xl with no broken layouts.

| Score | Criteria |
|-------|----------|
| 100 | All pages tested at 320px/375px/768px/1024px/1280px/1536px, no layout breaks, no content overflow, no overlapping elements, container queries used for component-level responsiveness, Tailwind `container` configured |
| 90 | All key pages verified at 5+ widths, no critical breaks, minor cosmetic issues at uncommon widths |
| 80 | Main flows tested at mobile/tablet/desktop, no critical breaks, some non-ideal layouts at edge sizes |
| 70 | Primary pages responsive, secondary pages untested, some breaks at tablet widths |
| 60 | Homepage/key pages responsive, many internal pages only work at desktop widths |
| 40 | Only desktop width considered, major breaks at tablet and mobile |
| 20 | Single fixed-width layout, breaks at any non-desktop resolution |

**D4 formula:** `D4 = (M4.1 * 0.30) + (M4.2 * 0.25) + (M4.3 * 0.25) + (M4.4 * 0.20)`

---

## D5: Interaction & Motion (Weight: 10%)

**Source:** Laws of UX (Yablonski, 2020), Material Design Motion (Google), WCAG 2.3.3 (Animation from Interactions)

### M5.1: Loading State Coverage (30% of D5)

Skeleton, spinner, or progress indicator for every async operation.

| Score | Criteria |
|-------|----------|
| 100 | Every async operation has loading feedback, `loading.tsx` per route segment, `<Suspense>` boundaries around async Server Components, shadcn `Skeleton` matching exact content layout, progress bars for multi-step operations, `useTransition` with `isPending` for client mutations, optimistic `loading` prop on shadcn Button |
| 90 | `loading.tsx` on all routes, `<Suspense>` for key sections, Skeleton for main content areas, button loading states |
| 80 | `loading.tsx` on main routes, Skeleton for primary content, spinner for mutations |
| 70 | `loading.tsx` on some routes, generic spinner for data fetching, some bare loading states |
| 60 | Basic spinner/loader on main pages, some routes show blank while loading, no Skeleton usage |
| 40 | Inconsistent loading states, many routes flash blank, no `loading.tsx`, spinners only on some buttons |
| 20 | No loading states, pages appear broken while loading, no user feedback during async operations |

### M5.2: Transition & Animation Quality (25% of D5)

Consistent easing, appropriate duration, reduced motion support.

| Score | Criteria |
|-------|----------|
| 100 | Consistent easing curve (Tailwind `ease-in-out` / custom cubic-bezier), duration 150-300ms for UI transitions, `prefers-reduced-motion: reduce` disables non-essential animations, page transitions smooth, shadcn accordion/collapsible animate correctly, Framer Motion (if used) respects `useReducedMotion()` |
| 90 | Consistent easing/duration, `prefers-reduced-motion` supported, most transitions smooth |
| 80 | Mostly consistent timing, `prefers-reduced-motion` on major animations, some jarring transitions |
| 70 | Some animation consistency, `prefers-reduced-motion` partially supported, mixed durations |
| 60 | Animations present but inconsistent (mix of 100ms and 500ms), no reduced motion support |
| 40 | Few animations, jarring appear/disappear, no easing consideration, no reduced motion |
| 20 | No transitions, elements pop in/out, or excessive animations that distract/nauseate |

### M5.3: Optimistic UI & Instant Feedback (25% of D5)

Immediate visual response to user actions before server confirmation.

| Score | Criteria |
|-------|----------|
| 100 | All mutations show optimistic updates (toggle, add, delete reflected immediately), rollback on error with toast notification, `useOptimistic` or SWR/React Query `optimisticUpdate` used, form submissions show instant feedback, like/favorite toggles immediate |
| 90 | Critical mutations optimistic (create, update, delete), rollback on error, toast for confirmation |
| 80 | Key mutations optimistic (likes, toggles, simple updates), server errors handled gracefully |
| 70 | Some optimistic patterns (toggling states), most mutations wait for server response |
| 60 | Minimal optimistic UI, most actions show spinner then update, noticeable delay |
| 40 | No optimistic updates, all mutations wait for server, UI feels sluggish |
| 20 | No feedback during mutations, user unsure if action registered, double-clicks cause issues |

### M5.4: Micro-interactions (20% of D5)

Hover states, active states, focus rings, button press feedback.

| Score | Criteria |
|-------|----------|
| 100 | All interactive elements have hover state (Tailwind `hover:`), active/pressed state (`active:scale-95` or similar), focus ring (`focus-visible:ring-*`), disabled state visually distinct (`disabled:opacity-50`), cursor changes (pointer, not-allowed), shadcn Button variants all have interaction states |
| 90 | Hover/active/focus on all buttons and links, disabled states clear, cursor feedback |
| 80 | Hover/focus on most interactive elements, active states on primary buttons, disabled styles |
| 70 | Hover on buttons/links, focus rings on some elements, inconsistent active states |
| 60 | Basic hover on primary buttons, focus rings via browser default (inconsistent), no active states |
| 40 | Minimal hover states, no active/pressed feedback, focus rings removed or invisible |
| 20 | No interaction states, elements feel static, no visual feedback on hover/click/focus |

**D5 formula:** `D5 = (M5.1 * 0.30) + (M5.2 * 0.25) + (M5.3 * 0.25) + (M5.4 * 0.20)`

---

## D6: Navigation & Wayfinding (Weight: 8%)

**Source:** Nielsen Heuristic #7 (Flexibility and Efficiency of Use), Information Architecture (Rosenfeld & Morville), Don't Make Me Think (Krug)

### M6.1: Route Structure & Deep Linking (30% of D6)

Clean URLs, shareable links, browser back button support.

| Score | Criteria |
|-------|----------|
| 100 | Clean URL structure matching IA (`/settings/profile`, `/projects/[id]/tasks`), all meaningful states deep-linkable (filters, tabs, pagination in URL via `searchParams`), back button works correctly with `useRouter`, `Link` component used for all navigation (not `onClick` + `router.push`), parallel routes for modals (`@modal`) |
| 90 | Clean URLs, key states in URL (active tab, pagination), back button works, `Link` used consistently |
| 80 | Good URL structure, some state in URL (active tab), back button mostly works |
| 70 | URLs reflect routes but not state (filters/tabs lost on reload), back button sometimes unexpected |
| 60 | Basic route structure, no state in URL, some `onClick` navigation instead of `Link` |
| 40 | Messy URLs, state lost on refresh, back button often breaks, `router.push` for most navigation |
| 20 | No meaningful URL structure, hash-based navigation, back button broken, cannot share page state |

### M6.2: Breadcrumbs & Context (25% of D6)

User always knows where they are in the application.

| Score | Criteria |
|-------|----------|
| 100 | Breadcrumb component (shadcn `Breadcrumb`) on all nested routes, current page highlighted in nav, page titles in `<head>` via `metadata` / `generateMetadata`, active route indicator in sidebar/nav, document title updates on navigation |
| 90 | Breadcrumbs on deep routes, nav active states, page titles via metadata, context clear |
| 80 | Breadcrumbs on most nested routes, nav shows active page, page titles present |
| 70 | Breadcrumbs on some routes, nav has active states, some pages missing titles |
| 60 | No breadcrumbs but nav active state present, page titles inconsistent |
| 40 | No breadcrumbs, nav active state inconsistent, hard to determine current location |
| 20 | No wayfinding cues, user frequently lost, no active states, no breadcrumbs, generic page titles |

### M6.3: Search & Command Palette (25% of D6)

Keyboard-accessible search, command palette for power users.

| Score | Criteria |
|-------|----------|
| 100 | Command palette (shadcn `Command` / `CommandDialog`) via `Cmd+K`, global search with instant results, recent searches, keyboard navigation in results, search accessible from every page, results grouped by type |
| 90 | Command palette with `Cmd+K`, search with results, keyboard navigable, accessible globally |
| 80 | Search input in header, results page, `Cmd+K` shortcut, basic keyboard navigation |
| 70 | Search input available, results page works, no keyboard shortcut, no command palette |
| 60 | Basic search on some pages, no global search, no keyboard shortcut |
| 40 | Search exists but poor UX (full page reload, slow, no highlighting) |
| 20 | No search functionality, no command palette, no way to quickly find content |

### M6.4: Navigation Consistency (20% of D6)

Persistent navigation, active states, predictable structure.

| Score | Criteria |
|-------|----------|
| 100 | Persistent sidebar/header nav across all routes (via `layout.tsx`), consistent placement, active states on current route, mobile navigation via shadcn Sheet, nav items same across sessions, icons + labels, collapsible sidebar with state persisted |
| 90 | Persistent nav in layout, active states, mobile Sheet nav, consistent structure |
| 80 | Persistent nav, active states, mobile menu, mostly consistent placement |
| 70 | Nav present on all pages but some inconsistency, active states on main items |
| 60 | Nav present but varies between sections, inconsistent active states |
| 40 | Nav changes between pages, some pages missing nav, disorienting |
| 20 | No persistent navigation, ad-hoc links, user must rely on back button |

**D6 formula:** `D6 = (M6.1 * 0.30) + (M6.2 * 0.25) + (M6.3 * 0.25) + (M6.4 * 0.20)`

---

## D7: Form & Input UX (Weight: 10%)

**Source:** Nielsen Heuristic #9 (Help Users Recognize, Diagnose, Recover from Errors), Baymard Institute Form UX Research, Luke Wroblewski Form Design Best Practices

### M7.1: Validation Strategy (30% of D7)

Inline validation, timing, clear error messages.

| Score | Criteria |
|-------|----------|
| 100 | Inline validation on blur (not on every keystroke), real-time feedback for format (email, URL), client + server validation (Zod schema shared), errors disappear when corrected, success indicators on valid fields, shadcn `Input` + `Label` + error text pattern consistent, `react-hook-form` + Zod for schema validation |
| 90 | Inline validation on blur, Zod schemas, errors clear on fix, consistent error display pattern |
| 80 | Validation on blur for key fields, Zod or similar schema validation, errors near fields |
| 70 | Validation on submit with errors shown inline, some on-blur validation |
| 60 | Validation on submit, errors shown at top of form or inline inconsistently |
| 40 | Validation on submit, generic error messages, errors not near relevant fields |
| 20 | No client-side validation, errors only from server (page reload), unclear messages |

### M7.2: Error Recovery (25% of D7)

Errors near fields, preserved input, actionable messages.

| Score | Criteria |
|-------|----------|
| 100 | Errors displayed directly below the field (shadcn `FormMessage`), input values preserved on error, scroll to first error + focus, error count shown ("3 errors below"), messages are specific and actionable ("Email must include @"), `aria-invalid` + `aria-errormessage` set, form progress not lost on navigation |
| 90 | Errors below fields, input preserved, scroll to first error, specific messages, ARIA attributes |
| 80 | Errors near fields, input preserved, messages mostly specific, some ARIA |
| 70 | Errors near fields, input preserved, some generic messages ("Invalid input") |
| 60 | Errors shown but sometimes far from field, input usually preserved, generic messages |
| 40 | Errors at top of form only, some input lost on error, vague messages |
| 20 | Errors unclear or missing, input lost on validation failure, user must re-enter data |

### M7.3: Progressive Disclosure (25% of D7)

Multi-step forms, conditional fields, smart defaults.

| Score | Criteria |
|-------|----------|
| 100 | Complex forms split into steps (shadcn `Stepper` or custom), conditional fields shown/hidden based on selection, smart defaults from context/previous input, optional sections collapsible, form length feels manageable, progress indicator for multi-step |
| 90 | Multi-step for complex forms, conditional fields, smart defaults, progress shown |
| 80 | Some multi-step forms, basic conditional fields, sensible defaults |
| 70 | Long forms with some section grouping, occasional conditional fields |
| 60 | Long forms without steps, all fields shown at once, few defaults |
| 40 | Very long single-page forms, no progressive disclosure, no defaults |
| 20 | Overwhelming form dumps, irrelevant fields shown, no guidance, no defaults |

### M7.4: Input Optimization (20% of D7)

Proper input types, autocomplete, autofill, specialized pickers.

| Score | Criteria |
|-------|----------|
| 100 | Correct `type` on all inputs (`email`, `tel`, `url`, `number`), `autocomplete` attributes for autofill (`name`, `email`, `address-*`, `cc-*`), shadcn `DatePicker` for dates (not text input), `Combobox` for searchable selects, `Textarea` auto-resizes, `inputMode` set for mobile keyboards |
| 90 | Correct types, autocomplete on key fields, DatePicker for dates, Combobox where appropriate |
| 80 | Most input types correct, autocomplete on common fields (email, name), some specialized pickers |
| 70 | Basic types set (email, password), minimal autocomplete, basic select for searchable lists |
| 60 | Some types set, no autocomplete attributes, plain text inputs for dates |
| 40 | All inputs type="text", no autocomplete, no specialized pickers |
| 20 | No input optimization, wrong keyboard on mobile, dates as free text, no autofill support |

**D7 formula:** `D7 = (M7.1 * 0.30) + (M7.2 * 0.25) + (M7.3 * 0.25) + (M7.4 * 0.20)`

---

## D8: Error & Edge States (Weight: 8%)

**Source:** Nielsen Heuristic #9, Defensive Design for the Web (Headley & Cavett), Resilient Web Design (Keith)

### M8.1: Empty States (30% of D8)

Actionable empty states with call-to-action, not just "No data".

| Score | Criteria |
|-------|----------|
| 100 | All empty states have illustration/icon + descriptive message + primary CTA (e.g., "No projects yet" + "Create your first project" button), empty search results suggest alternatives, empty filtered results offer "Clear filters", first-run states guide onboarding, shadcn `Card` used for empty state containers |
| 90 | Empty states with message + CTA on all lists/tables, empty search suggests alternatives |
| 80 | Most lists/tables have empty states with CTA, some just show message without action |
| 70 | Primary lists have empty states, secondary views show "No data" text |
| 60 | Some empty states with basic messages, many lists just show blank space |
| 40 | Generic "No data" or "No results" without guidance, no CTAs |
| 20 | Blank areas with no indication of empty state, user confused about whether data is loading or absent |

### M8.2: Error Boundaries & Recovery (25% of D8)

`error.tsx` per route, retry actions, graceful fallbacks.

| Score | Criteria |
|-------|----------|
| 100 | `error.tsx` in every route segment, `global-error.tsx` at root, errors show user-friendly message + retry button + option to go home, errors logged (not swallowed), partial failures don't crash entire page (error boundary per section), `not-found.tsx` customized per route where meaningful |
| 90 | `error.tsx` on all main routes, `global-error.tsx`, retry buttons, partial error boundaries, custom 404 |
| 80 | `error.tsx` on key routes, `global-error.tsx`, retry available, custom 404 page |
| 70 | `error.tsx` on some routes, `global-error.tsx` present, basic retry |
| 60 | `global-error.tsx` only, generic error page, no per-route error boundaries |
| 40 | Default Next.js error page, no custom error handling, errors crash the page |
| 20 | No error boundaries, unhandled errors show white screen or stack trace, no recovery options |

### M8.3: Loading & Skeleton States (25% of D8)

`loading.tsx` per route, Suspense boundaries, skeleton matching layout.

| Score | Criteria |
|-------|----------|
| 100 | `loading.tsx` in every route segment with shadcn `Skeleton` matching the page layout shape, nested `<Suspense>` for independent data sections, streaming SSR for progressive rendering, skeleton pulse animation, loading states for images (blur placeholder via `next/image`), page shell (nav/sidebar) never re-loads |
| 90 | `loading.tsx` on all routes with Skeleton, Suspense for key sections, stable shell, image placeholders |
| 80 | `loading.tsx` on main routes, Skeleton for primary content, some Suspense boundaries |
| 70 | `loading.tsx` on key routes, generic spinner (not layout-matching skeleton) |
| 60 | `loading.tsx` on some routes, basic spinner, no Suspense, shell sometimes re-renders |
| 40 | Minimal loading states, pages flash blank, no skeleton, no Suspense |
| 20 | No loading states, white screen during navigation, no indication of pending content |

### M8.4: Offline & Degraded UX (20% of D8)

Network-aware UI, stale data display, reconnection handling.

| Score | Criteria |
|-------|----------|
| 100 | Network status detection (`navigator.onLine` or `use-online` hook), stale data shown with "Last updated" timestamp, offline banner/toast, queued mutations replayed on reconnect, Service Worker for critical assets, PWA-ready with offline page |
| 90 | Network detection, stale data displayed, offline indicator, basic queue for mutations |
| 80 | Network detection, stale data shown with warning, offline toast notification |
| 70 | Basic offline detection, generic "You're offline" message, cached pages viewable |
| 60 | SWR/React Query stale cache shown but no explicit offline handling, no user notification |
| 40 | No offline awareness, errors on network loss with no explanation |
| 20 | Application crashes on network loss, no caching, no offline consideration |

**D8 formula:** `D8 = (M8.1 * 0.30) + (M8.2 * 0.25) + (M8.3 * 0.25) + (M8.4 * 0.20)`

---

## D9: Visual Consistency & Polish (Weight: 8%)

**Source:** Gestalt Principles of Visual Perception, Laws of UX (Yablonski, 2020), Refactoring UI (Wathan & Schoger)

### M9.1: Spacing System (25% of D9)

Consistent spacing scale, 4px/8px grid, no arbitrary values.

| Score | Criteria |
|-------|----------|
| 100 | All spacing uses Tailwind scale (p-1 through p-16+, gap-*, space-*, m-*), consistent section spacing pattern (e.g., sections gap-8, cards gap-4, inline gap-2), zero arbitrary spacing values, padding/margin consistent within component types, layout grid alignment visible |
| 90 | 95%+ Tailwind spacing scale, consistent patterns per component type, < 3 arbitrary values |
| 80 | 90%+ Tailwind scale, mostly consistent patterns, < 5 arbitrary spacing values |
| 70 | Tailwind scale used but patterns inconsistent (gap-3 in some cards, gap-5 in others) |
| 60 | Mix of Tailwind scale and arbitrary values, no consistent spacing pattern |
| 40 | Frequent arbitrary spacing, visually inconsistent gaps, no spacing system |
| 20 | Random spacing throughout, no system, elements feel misaligned and chaotic |

### M9.2: Typography Scale (25% of D9)

Defined scale, consistent headings, readable body text.

| Score | Criteria |
|-------|----------|
| 100 | Defined type scale in Tailwind config or CSS variables, consistent heading sizes per level (h1 always `text-3xl font-bold`, etc.), body text `text-sm` or `text-base` consistently, `text-muted-foreground` for secondary text, `font-medium` / `font-semibold` used consistently for emphasis, line heights appropriate per size |
| 90 | Consistent heading sizes, body text standardized, muted text via token, font weights consistent |
| 80 | Mostly consistent headings, body text readable, some size inconsistencies in secondary text |
| 70 | Headings mostly consistent, body text varies between `text-xs` and `text-base` without pattern |
| 60 | Headings inconsistent (h2 sometimes `text-xl`, sometimes `text-2xl`), body text varies |
| 40 | No type scale, sizes chosen per-component, inconsistent weights and sizes throughout |
| 20 | Random font sizes, unreadable text, no hierarchy, everything looks the same weight/size |

### M9.3: Color System & Dark Mode (25% of D9)

Semantic colors, HSL variables, complete dark mode.

| Score | Criteria |
|-------|----------|
| 100 | Full HSL color system in CSS variables (`--background`, `--foreground`, `--primary`, `--muted`, `--destructive`, etc.), dark mode via `.dark` class with all variables redefined, shadcn `ThemeProvider` with system/light/dark toggle, no hardcoded colors, semantic color usage (destructive for delete, primary for CTAs), dark mode tested on all pages |
| 90 | HSL variables, complete dark mode, theme toggle, semantic colors, < 3 hardcoded colors |
| 80 | CSS variables for main colors, dark mode mostly complete (minor visual issues), theme toggle |
| 70 | CSS variables, dark mode partial (some components wrong colors), basic toggle |
| 60 | Some CSS variables, dark mode attempted but broken on many components, hardcoded colors in places |
| 40 | Minimal CSS variables, no dark mode or severely broken, many hardcoded colors |
| 20 | No color system, all hardcoded hex, no dark mode, inconsistent color usage throughout |

### M9.4: Animation Coherence (25% of D9)

Consistent timing, easing curves, no conflicting animations.

| Score | Criteria |
|-------|----------|
| 100 | Shared animation duration tokens (Tailwind `duration-150` / `duration-200`), consistent easing (`ease-in-out`), enter/exit animations paired (fade in + fade out), no competing animations on same element, Tailwind `animate-*` or custom keyframes in config, page transitions cohesive |
| 90 | Consistent durations and easing, enter/exit paired, animations in Tailwind config |
| 80 | Mostly consistent timing, some easing variation, animations don't conflict |
| 70 | Some consistency, mix of durations (100ms, 200ms, 500ms), occasional visual jank |
| 60 | Animations present but mixed timing, some jarring transitions, no system |
| 40 | Inconsistent animations, some elements animate while siblings don't, visual noise |
| 20 | No animation system, or conflicting/distracting animations, elements flash or jump |

**D9 formula:** `D9 = (M9.1 * 0.25) + (M9.2 * 0.25) + (M9.3 * 0.25) + (M9.4 * 0.25)`

---

## D10: Internationalization (Weight: 5%)

**Source:** W3C Internationalization Best Practices (2023), ICU MessageFormat, Unicode CLDR, next-intl documentation

### M10.1: i18n Framework Setup (30% of D10)

Translation framework, extracted strings, locale routing.

| Score | Criteria |
|-------|----------|
| 100 | `next-intl` or `next-i18next` configured, all user-facing strings extracted to JSON message files, locale in URL path (`/en/dashboard`), `middleware.ts` handles locale detection/redirect, `generateStaticParams` for locale segments, type-safe message keys |
| 90 | i18n framework configured, 95%+ strings extracted, locale routing, middleware redirect |
| 80 | i18n framework in place, 80%+ strings extracted, locale routing works |
| 70 | i18n framework set up, key pages translated, some hardcoded strings remain |
| 60 | Basic i18n setup, < 50% strings extracted, translation files exist but incomplete |
| 40 | i18n library installed but barely used, mostly hardcoded English strings |
| 20 | No i18n framework, all strings hardcoded in components, no locale support |

### M10.2: RTL Support (25% of D10)

Logical properties, `dir` attribute, mirrored layouts.

| Score | Criteria |
|-------|----------|
| 100 | CSS logical properties throughout (`ms-*` / `me-*` / `ps-*` / `pe-*` in Tailwind, or `start`/`end`), `dir="rtl"` on `<html>`, icons/chevrons mirror, layouts flip correctly, shadcn components work in RTL, tested in Arabic/Hebrew |
| 90 | Logical properties on 90%+ of directional styles, `dir` attribute set, layouts mirror correctly |
| 80 | Logical properties on most styles, RTL mostly works, some hardcoded `left`/`right` |
| 70 | Some logical properties, basic RTL attempted, significant layout issues in RTL |
| 60 | Minimal logical properties, RTL partially broken |
| 40 | No logical properties, RTL not considered, `ml-*` / `mr-*` / `pl-*` / `pr-*` throughout |
| 20 | No RTL support, application breaks completely in RTL context |

### M10.3: Locale-Aware Formatting (25% of D10)

Dates, numbers, currency using Intl API or i18n library.

| Score | Criteria |
|-------|----------|
| 100 | All dates via `Intl.DateTimeFormat` or `next-intl` `useFormatter`, numbers via `Intl.NumberFormat`, currency locale-aware, relative time ("2 hours ago") via `Intl.RelativeTimeFormat`, pluralization via ICU MessageFormat, timezone-aware date display |
| 90 | Dates and numbers via Intl API, currency formatted, relative time, basic pluralization |
| 80 | Dates and numbers locale-aware, currency mostly correct, basic pluralization |
| 70 | Dates use Intl or date-fns with locale, numbers mostly formatted, some hardcoded formats |
| 60 | Some locale-aware formatting, mix of Intl and hardcoded formats (e.g., "MM/DD/YYYY") |
| 40 | Mostly hardcoded date/number formats, US-centric ($ always, MM/DD/YYYY) |
| 20 | All dates/numbers hardcoded in US format, no locale consideration, `.toLocaleDateString()` not used |

### M10.4: Content Externalization (20% of D10)

No hardcoded strings in components.

| Score | Criteria |
|-------|----------|
| 100 | Zero hardcoded user-facing strings in components (all via `t('key')`), error messages externalized, button labels externalized, placeholder text externalized, `aria-label` values externalized, lint rule enforcing no string literals in JSX |
| 90 | < 5 hardcoded strings in entire codebase, all key UI text externalized |
| 80 | < 10 hardcoded strings, main UI text externalized, some aria-labels or tooltips hardcoded |
| 70 | Key pages externalized, secondary pages have hardcoded strings, error messages mixed |
| 60 | Some externalization effort, 50%+ of strings still hardcoded |
| 40 | Minimal externalization, mostly hardcoded English throughout |
| 20 | All strings hardcoded in components, no externalization effort |

**D10 formula:** `D10 = (M10.1 * 0.30) + (M10.2 * 0.25) + (M10.3 * 0.25) + (M10.4 * 0.20)`

---

## D11: Data Display & Search (Weight: 7%)

**Source:** NNGroup Data Table Guidelines, Baymard Institute Search & Filter UX Research, Tufte Principles of Data Visualization

### M11.1: Table UX (30% of D11)

Sortable columns, sticky headers, responsive behavior, row actions.

| Score | Criteria |
|-------|----------|
| 100 | shadcn `DataTable` (TanStack Table) with sortable columns, sticky header on scroll, column visibility toggle, row selection with bulk actions, responsive (card layout on mobile or horizontal scroll with shadow indicator), row click for detail, column resize, virtualization for large datasets |
| 90 | DataTable with sorting, sticky header, row selection, responsive, row actions menu (shadcn `DropdownMenu`) |
| 80 | DataTable with sorting, sticky header, basic row actions, responsive on most breakpoints |
| 70 | Basic table with sorting on some columns, header scrolls away, row actions present |
| 60 | Static table, no sorting, header not sticky, basic responsive (horizontal scroll only) |
| 40 | Plain `<table>` without features, breaks on mobile, no row actions |
| 20 | Data in unstructured lists or divs, no table UI, no sorting, no responsive consideration |

### M11.2: Pagination & Infinite Scroll (25% of D11)

Appropriate pattern for data size, position preservation.

| Score | Criteria |
|-------|----------|
| 100 | Pagination with page size selector, total count displayed, keyboard navigable, URL-synced page state (`?page=2`), position preserved on back navigation, cursor-based pagination for real-time data, "Load more" option for feeds, virtual scrolling for large lists (via `@tanstack/react-virtual`) |
| 90 | Pagination with page size, total count, URL-synced, back-navigation preserves position |
| 80 | Pagination with page controls, total count, position mostly preserved on back |
| 70 | Basic pagination (prev/next), page number shown, state lost on back navigation |
| 60 | Basic pagination, no total count, no URL sync, position lost |
| 40 | Load all data at once (performance issue), or pagination with no controls |
| 20 | No pagination, all data dumped on screen, page slows with data growth |

### M11.3: Search & Filter UX (25% of D11)

Instant feedback, clear filters, filter state management.

| Score | Criteria |
|-------|----------|
| 100 | Instant search with debounce (300ms), results highlighted, active filters shown as removable chips/badges (shadcn `Badge`), "Clear all filters" button, filter state in URL (`?q=&status=active`), saved/preset filters, filter count on trigger button, empty search results with suggestions |
| 90 | Debounced search, filter chips, clear all, URL-synced filters, empty result handling |
| 80 | Debounced search, filters visible, clear all available, most filter state in URL |
| 70 | Search works, filters present, some URL sync, no active filter display |
| 60 | Basic search (full page reload or delayed), dropdown filters, no URL sync |
| 40 | Search exists but slow/broken, filters limited, state lost on navigation |
| 20 | No search, no filters, or search so broken it's unusable |

### M11.4: Data Visualization (20% of D11)

Appropriate chart types, accessible, responsive.

| Score | Criteria |
|-------|----------|
| 100 | Charts use appropriate types (line for trends, bar for comparison, pie for composition), responsive sizing (container-aware), accessible colors (distinguishable in grayscale), `aria-label` on charts, tooltips on data points, legend with toggle, dark mode support, Recharts or similar library integrated cleanly |
| 90 | Appropriate chart types, responsive, accessible colors, tooltips, dark mode support |
| 80 | Good chart types, mostly responsive, tooltips present, some accessibility gaps |
| 70 | Charts present, reasonable types, fixed sizing, basic tooltips |
| 60 | Basic charts, some wrong types (pie for 12+ categories), not responsive |
| 40 | Minimal charts, poor type choices, no tooltips, not accessible |
| 20 | No data visualization where it would clearly help, or charts so broken they mislead |

**D11 formula:** `D11 = (M11.1 * 0.30) + (M11.2 * 0.25) + (M11.3 * 0.25) + (M11.4 * 0.20)`

---

## Overall Score Formula

```
Overall = (D1  * 0.12)   // Accessibility & Inclusivity
        + (D2  * 0.12)   // Performance & Web Vitals
        + (D3  * 0.10)   // Component & Design System
        + (D4  * 0.10)   // Responsive & Adaptive
        + (D5  * 0.10)   // Interaction & Motion
        + (D6  * 0.08)   // Navigation & Wayfinding
        + (D7  * 0.10)   // Form & Input UX
        + (D8  * 0.08)   // Error & Edge States
        + (D9  * 0.08)   // Visual Consistency & Polish
        + (D10 * 0.05)   // Internationalization
        + (D11 * 0.07)   // Data Display & Search
```

Weights sum to 1.00 (100%).

---

## Framework Sources

| Dimension | Primary Source | Key Reference |
|-----------|---------------|---------------|
| D1 | WCAG 2.2 (W3C, 2023) + WAI-ARIA 1.2 | Perceivable, Operable, Understandable, Robust |
| D2 | Core Web Vitals (Google, 2024) + Lighthouse | LCP, INP, CLS thresholds, Performance scoring |
| D3 | Atomic Design (Frost, 2016) + shadcn/ui | Component composition, design tokens, registry |
| D4 | Mobile-First (Wroblewski) + WCAG 2.5 | Input modalities, touch targets, responsive patterns |
| D5 | Laws of UX (Yablonski, 2020) + Material Motion | Doherty Threshold, feedback loops, motion principles |
| D6 | Nielsen Heuristic #7 + IA (Rosenfeld & Morville) | Flexibility, efficiency, wayfinding, information scent |
| D7 | Nielsen Heuristic #9 + Baymard Institute | Form usability, error recovery, input optimization |
| D8 | Defensive Design (Headley) + Resilient Web Design | Empty states, error boundaries, graceful degradation |
| D9 | Gestalt Principles + Refactoring UI (Wathan & Schoger) | Visual hierarchy, spacing, typography, color systems |
| D10 | W3C i18n Best Practices + ICU MessageFormat | Locale routing, RTL, formatting, string externalization |
| D11 | NNGroup + Baymard Institute + Tufte | Table UX, pagination, search/filter, data visualization |

---

## Opportunity Template Reference

Each opportunity in the scored map should follow this structure:

```
### OPP-NNN: [Opportunity Title]

- **Status**: Proposed
- **Dimension**: D[X] — [Dimension Name]
- **Sub-metric**: M[X.Y] — [Sub-metric Name]
- **Source**: [Framework/guideline reference]
- **Current state**: [What exists today — specific code/pattern observed]
- **Proposed change**: [Concrete implementation with shadcn/Tailwind/Next.js specifics]
- **Components involved**: [shadcn components, Next.js files, Tailwind classes]
- **Impact**:
  - Score impact: +[N] points on D[X] ([current] -> [projected])
  - User impact: [how this improves the user experience]
  - Accessibility impact: [WCAG criteria addressed, if any]
  - Risk: [migration risk, breaking changes]
- **Effort**: [S/M/L] — [sizing rationale]
- **Affected routes**: [list of routes/pages impacted]
```

This format ensures every recommendation is traceable to a framework source,
measurable via the scoring threshold, and actionable with stack-specific guidance.
