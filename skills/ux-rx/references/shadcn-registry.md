# shadcn/ui Registry Reference

> Component catalog for UX recommendations. When prescribing improvements,
> always check this reference for ready-to-use components before recommending custom code.
>
> Registry source: https://ui.shadcn.com and https://shadcn.com/r (community registry)

---

## Core Components by UX Dimension

### D1: Accessibility

| Component | UX Purpose | Install |
|---|---|---|
| `label` | Accessible form labels, auto-association | `npx shadcn@latest add label` |
| `checkbox` | Accessible checkboxes with Radix | `npx shadcn@latest add checkbox` |
| `radio-group` | Accessible radio with keyboard nav | `npx shadcn@latest add radio-group` |
| `switch` | Toggle with aria-checked | `npx shadcn@latest add switch` |
| `slider` | Accessible range input | `npx shadcn@latest add slider` |
| `toggle` | Pressed state toggle | `npx shadcn@latest add toggle` |
| `toggle-group` | Multi-toggle with roving tabindex | `npx shadcn@latest add toggle-group` |
| `tooltip` | Accessible tooltips (not for critical info) | `npx shadcn@latest add tooltip` |

### D3: Component & Design System

| Component | UX Purpose | Install |
|---|---|---|
| `button` | Consistent CTAs, variants, loading states | `npx shadcn@latest add button` |
| `badge` | Status indicators, tags | `npx shadcn@latest add badge` |
| `avatar` | User identity display | `npx shadcn@latest add avatar` |
| `card` | Content containers | `npx shadcn@latest add card` |
| `separator` | Visual section dividers | `npx shadcn@latest add separator` |
| `aspect-ratio` | Consistent media containers | `npx shadcn@latest add aspect-ratio` |
| `scroll-area` | Custom scrollbars, mobile-friendly | `npx shadcn@latest add scroll-area` |
| `resizable` | Resizable panels | `npx shadcn@latest add resizable` |
| `sidebar` | App navigation sidebar | `npx shadcn@latest add sidebar` |

### D5: Interaction & Motion

| Component | UX Purpose | Install |
|---|---|---|
| `skeleton` | Loading state placeholders | `npx shadcn@latest add skeleton` |
| `progress` | Determinate progress feedback | `npx shadcn@latest add progress` |
| `sonner` | Toast notifications (non-blocking) | `npx shadcn@latest add sonner` |
| `drawer` | Mobile-friendly bottom sheets | `npx shadcn@latest add drawer` |
| `collapsible` | Expandable sections | `npx shadcn@latest add collapsible` |
| `accordion` | Progressive disclosure | `npx shadcn@latest add accordion` |
| `carousel` | Content rotation | `npx shadcn@latest add carousel` |
| `hover-card` | Preview-on-hover | `npx shadcn@latest add hover-card` |

### D6: Navigation & Wayfinding

| Component | UX Purpose | Install |
|---|---|---|
| `navigation-menu` | Top-level navigation | `npx shadcn@latest add navigation-menu` |
| `breadcrumb` | Hierarchical wayfinding | `npx shadcn@latest add breadcrumb` |
| `tabs` | Content organization | `npx shadcn@latest add tabs` |
| `menubar` | Application menu bar | `npx shadcn@latest add menubar` |
| `dropdown-menu` | Contextual actions | `npx shadcn@latest add dropdown-menu` |
| `context-menu` | Right-click menus | `npx shadcn@latest add context-menu` |
| `command` | Command palette / search (cmdk) | `npx shadcn@latest add command` |
| `sheet` | Slide-over panels | `npx shadcn@latest add sheet` |
| `pagination` | Page navigation | `npx shadcn@latest add pagination` |

### D7: Form & Input UX

| Component | UX Purpose | Install |
|---|---|---|
| `form` | React Hook Form + Zod integration | `npx shadcn@latest add form` |
| `input` | Text input with consistent styling | `npx shadcn@latest add input` |
| `textarea` | Multi-line text input | `npx shadcn@latest add textarea` |
| `select` | Single-value selection | `npx shadcn@latest add select` |
| `combobox` | Searchable select (command-based) | `npx shadcn@latest add popover command` |
| `date-picker` | Date selection | `npx shadcn@latest add calendar popover` |
| `input-otp` | OTP / verification code input | `npx shadcn@latest add input-otp` |

### D8: Error & Edge States

| Component | UX Purpose | Install |
|---|---|---|
| `alert` | Inline error/warning/info messages | `npx shadcn@latest add alert` |
| `alert-dialog` | Destructive action confirmation | `npx shadcn@latest add alert-dialog` |
| `dialog` | Modal dialogs | `npx shadcn@latest add dialog` |
| `skeleton` | Loading placeholders | `npx shadcn@latest add skeleton` |
| `sonner` | Error toasts | `npx shadcn@latest add sonner` |

### D11: Data Display & Search

| Component | UX Purpose | Install |
|---|---|---|
| `table` | Data tables | `npx shadcn@latest add table` |
| `data-table` | Full-featured data table (TanStack) | See shadcn data table guide |
| `command` | Search / command palette | `npx shadcn@latest add command` |
| `popover` | Filter dropdowns | `npx shadcn@latest add popover` |
| `chart` | Data visualization (Recharts) | `npx shadcn@latest add chart` |

---

## Community Registry (shadcn/r)

Check https://shadcn.com/r for community components. Common high-value additions:

| Pattern | Registry Search | UX Dimension |
|---|---|---|
| File upload with drag-and-drop | `file-upload` | D7 Forms |
| Multi-select with tags | `multi-select` | D7 Forms |
| Date range picker | `date-range-picker` | D7 Forms |
| Stepper / wizard | `stepper` | D7 Forms |
| Timeline | `timeline` | D11 Data Display |
| Kanban board | `kanban` | D11 Data Display |
| Tree view | `tree-view` | D6 Navigation |
| Color picker | `color-picker` | D7 Forms |
| Rich text editor | `editor` | D7 Forms |
| Image cropper | `image-cropper` | D7 Forms |

---

## Discovery Script Integration

The D3 dimension script (`d03-components.sh`) automatically:
1. Lists all installed shadcn components from `components/ui/`
2. Compares against the full registry catalog above
3. Reports gaps: components that would improve specific dimensions
4. Checks for custom implementations that could be replaced by registry components

## Recommendation Rules

1. **Registry first.** Always recommend `npx shadcn@latest add [component]` before custom code.
2. **Include install command.** Every component recommendation must include the exact install command.
3. **Map to dimension.** Every component recommendation must state which dimension(s) it improves.
4. **Check community registry.** For patterns not in core, check https://shadcn.com/r.
5. **Composition over custom.** Prefer composing existing components over building from scratch.
