# CLAUDE.md

Guidance for Claude Code when working with the **Maia** codebase.

---

## Commands

```bash
npm run dev       # dev server at http://localhost:3000
```

> No test runner is configured yet.

---

## What is Maia?

Maia is an AI personal assistant / "second brain" app. The goal is to combine chat, persistent memory, project/task management, mood tracking, reminders, and user-curated lists in one place. The Anthropic Claude API is the AI backbone; Supabase handles persistence, auth, and vector search.

---

## Tech stack

| Layer     | Technology                                                   |
| --------- | ------------------------------------------------------------ |
| Framework | Nuxt 3 (using the Nuxt 4 `app/` directory convention)        |
| UI        | Vue 3 + Tailwind CSS (custom design system — see below)      |
| State     | Pinia (`pinia@^2.3.0` + `@pinia/nuxt@^0.9.0`)                |
| Backend   | Nuxt server routes (`server/api/`)                           |
| Database  | Supabase (PostgreSQL + pgvector)                             |
| AI        | Anthropic Claude API via `@anthropic-ai/sdk`                 |
| Auth      | `@nuxtjs/supabase` — magic link OTP + Google OAuth           |
| Email     | Supabase default during dev; Resend deferred (no domain yet) |
| Node      | 22+ required (nvm)                                           |

---

## Directory layout

All Vue source lives under `app/` (Nuxt 4 convention):

```
app/
  app.vue                    # root shell: <NuxtLayout> + <NuxtPage>
  layouts/
    default.vue              # sidebar with nav (Chat, Tasks, Projects, Memory) + avatar/sign-out
  pages/
    auth.vue                 # login / register / forgot-password (mode-switched, layout: false)
    index.vue                # main chat page (in development)
  middleware/
    auth.ts                  # protects private routes; redirects authed users away from /auth
  types/
    database.types.ts        # auto-generated Supabase TS types

server/
  api/                       # ALL Anthropic API calls happen here — never from the client
    ...                      # e.g. chat.post.ts, memory.post.ts

supabase/
  migrations/                # SQL migrations pushed to Supabase
```

---

## Coding conventions

### Vue components

- File names: **PascalCase** (`ChatMessage.vue`, `SidebarNav.vue`)
- Usage in templates: **PascalCase tags** (`<ChatMessage />`, not `<chat-message />`)
- Follow Nuxt's recommended patterns otherwise (composables in `composables/`, utils in `utils/`, etc.)

### Styling

- **Always use Tailwind classes** — avoid inline styles or raw CSS unless Tailwind genuinely can't do it
- Use the custom design token names (see Design system below) instead of raw colors or hex values
- Responsive and dark-mode-first by default

### Server routes

- All calls to the Anthropic API must go through `server/api/` routes
- Access the API key via `useRuntimeConfig().anthropicApiKey` (server-only, never `runtimeConfig.public`)
- Use streaming responses where appropriate for chat

### State

- Global state lives in Pinia stores under `app/stores/`
- Prefer `defineStore` with the composition API style

---

## Auth flow

- `@nuxtjs/supabase` is configured with `redirect: false` — no auto-redirects from the module
- All redirects are managed manually via `useRouter`
- `/auth` page handles three modes via query param / local state: `login`, `register`, `forgot-password`
- After auth, Supabase redirects back to `window.location.origin/`
- `app/middleware/auth.ts` protects private routes

---

## Database schema

All tables have a `user_id` FK referencing `users`.

| Table       | Purpose                                                              |
| ----------- | -------------------------------------------------------------------- |
| `users`     | Profile: email, name, timezone, checkin_time                         |
| `messages`  | Chat history (role, content)                                         |
| `memories`  | AI memory store — embeddings (pgvector), importance score, expiry    |
| `projects`  | User projects (title, description, color, status)                    |
| `tasks`     | Tasks linked to optional project; priority, status, due_date, source |
| `moods`     | Mood check-ins (score, label, note)                                  |
| `reminders` | Scheduled reminders optionally linked to a task                      |

Regenerate TS types after schema changes:

```bash
supabase gen types typescript --linked > app/types/database.types.ts
```

Migrations live in `supabase/migrations/`.

---

## Design system

Tailwind is extended with a custom dark-theme token set. **Always use these tokens** — not raw Tailwind colors or hex values.

### Surfaces (dark, deepest → elevated)

| Token     | Role               |
| --------- | ------------------ |
| `void`    | Deepest background |
| `surface` | Cards and panels   |
| `raised`  | Elevated elements  |
| `border`  | Borders            |
| `muted`   | Dividers           |

### Text

| Token   | Role                      |
| ------- | ------------------------- |
| `ink`   | Primary text (warm white) |
| `dim`   | Secondary text            |
| `ghost` | Placeholder text          |

### Accent

| Token        | Role                                     |
| ------------ | ---------------------------------------- |
| `gold`       | Brand amber (`#c9a84c`) — primary accent |
| `gold-light` | Lighter gold variant                     |
| `gold-dim`   | Dimmer gold variant                      |

### Semantic

| Token   | Role               |
| ------- | ------------------ |
| `sage`  | Success / positive |
| `rose`  | Error / caution    |
| `slate` | Info / neutral     |

### Typography

| Class          | Font               | Use               |
| -------------- | ------------------ | ----------------- |
| `font-display` | Cormorant Garamond | Headings, logo    |
| `font-body`    | DM Sans            | Default body text |
| `font-mono`    | JetBrains Mono     | Code, monospaced  |

### Shadows

| Class          | Use               |
| -------------- | ----------------- |
| `shadow-glow`  | Gold ambient glow |
| `shadow-panel` | Panel depth       |
| `shadow-float` | Floating elements |

---

## Environment variables

```env
SUPABASE_URL=
NUXT_PUBLIC_SUPABASE_KEY=
NUXT_SUPABASE_SECRET_KEY=
ANTHROPIC_API_KEY=
```

`ANTHROPIC_API_KEY` is server-only. Never add it to `runtimeConfig.public`.

---

## Features in development

The foundational auth and UI scaffolding is in place. The next layer being built:

1. **Chat** — `app/pages/index.vue` + `server/api/chat.post.ts` (Anthropic streaming)
2. **Memory** — semantic search via pgvector; Maia reads/writes `memories` table
3. **Tasks & Projects** — CRUD off Supabase, surfaced in sidebar
4. **Mood tracking** — periodic check-ins stored in `moods`
5. **Reminders** — scheduled, optionally linked to tasks
6. **Lists** — user-curated lists (separate from memory); schema includes `lists` + `list_items` with `metadata jsonb`

> The database schema doubles as the product spec — understand the tables and you understand Maia's scope.
