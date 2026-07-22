<template>
  <div class="app-shell">
    <!-- Sidebar -->
    <aside class="sidebar">
      <!-- Logo -->
      <div class="sidebar-logo">
        <span class="logo-mark">M</span>
        <span class="logo-text">maia</span>
      </div>

      <!-- Nav -->
      <nav class="sidebar-nav">
        <NuxtLink
          v-for="item in navItems"
          :key="item.to"
          :to="item.to"
          class="nav-item"
          :class="{ active: $route.path === item.to }"
        >
          <component :is="item.icon" class="nav-icon" />
          <span class="nav-label">{{ item.label }}</span>
          <span v-if="item.badge" class="nav-badge">{{ item.badge }}</span>
        </NuxtLink>
      </nav>

      <!-- Bottom: user + mood -->
      <div class="sidebar-footer">
        <div class="mood-indicator">
          <span class="mood-dot" :class="moodColor" />
          <span class="mood-label">{{ currentMood }}</span>
        </div>
        <button class="user-avatar" @click="handleSignOut">
          <span class="avatar-initials">{{ initials }}</span>
        </button>
      </div>
    </aside>

    <!-- Main content -->
    <main class="main-content">
      <slot />
    </main>
  </div>
</template>

<script setup>
import { computed } from "vue";
import { useRoute, useRouter } from "vue-router";
import { useSupabaseUser, useSupabaseClient } from "#imports";

const route = useRoute();
const router = useRouter();
const user = useSupabaseUser();
const supabase = useSupabaseClient();

const initials = computed(() => {
  const email = user.value?.email ?? "";
  return email.slice(0, 2).toUpperCase();
});

// Placeholder mood — will be driven by Pinia store later
const currentMood = ref("calm");
const moodColor = computed(
  () =>
    ({
      calm: "bg-slate",
      focused: "bg-gold",
      anxious: "bg-rose",
      content: "bg-sage",
    })[currentMood.value] ?? "bg-ghost",
);

async function handleSignOut() {
  await supabase.auth.signOut();
  router.push("/login");
}

// Icons as inline SVG functional components
const IconChat = defineComponent({
  template: `<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="M8.625 12a.375.375 0 1 1-.75 0 .375.375 0 0 1 .75 0Zm0 0H8.25m4.125 0a.375.375 0 1 1-.75 0 .375.375 0 0 1 .75 0Zm0 0H12m4.125 0a.375.375 0 1 1-.75 0 .375.375 0 0 1 .75 0Zm0 0h-.375M21 12c0 4.556-4.03 8.25-9 8.25a9.764 9.764 0 0 1-2.555-.337A5.972 5.972 0 0 1 5.41 20.97a5.969 5.969 0 0 1-.474-.065 4.48 4.48 0 0 0 .978-2.025c.09-.457-.133-.901-.467-1.226C3.93 16.178 3 14.189 3 12c0-4.556 4.03-8.25 9-8.25s9 3.694 9 8.25Z" /></svg>`,
});

const IconTasks = defineComponent({
  template: `<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="M9 12.75 11.25 15 15 9.75M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z" /></svg>`,
});

const IconProjects = defineComponent({
  template: `<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="M3.75 6A2.25 2.25 0 0 1 6 3.75h2.25A2.25 2.25 0 0 1 10.5 6v2.25a2.25 2.25 0 0 1-2.25 2.25H6a2.25 2.25 0 0 1-2.25-2.25V6ZM3.75 15.75A2.25 2.25 0 0 1 6 13.5h2.25a2.25 2.25 0 0 1 2.25 2.25V18a2.25 2.25 0 0 1-2.25 2.25H6A2.25 2.25 0 0 1 3.75 18v-2.25ZM13.5 6a2.25 2.25 0 0 1 2.25-2.25H18A2.25 2.25 0 0 1 20.25 6v2.25A2.25 2.25 0 0 1 18 10.5h-2.25a2.25 2.25 0 0 1-2.25-2.25V6ZM13.5 15.75a2.25 2.25 0 0 1 2.25-2.25H18a2.25 2.25 0 0 1 2.25 2.25V18A2.25 2.25 0 0 1 18 20.25h-2.25A2.25 2.25 0 0 1 13.5 18v-2.25Z" /></svg>`,
});

const IconMemory = defineComponent({
  template: `<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="M12 18v-5.25m0 0a6.01 6.01 0 0 0 1.5-.189m-1.5.189a6.01 6.01 0 0 1-1.5-.189m3.75 7.478a12.06 12.06 0 0 1-4.5 0m3.75 2.383a14.406 14.406 0 0 1-3 0M14.25 18v-.192c0-.983.658-1.823 1.508-2.316a7.5 7.5 0 1 0-7.517 0c.85.493 1.509 1.333 1.509 2.316V18" /></svg>`,
});

const navItems = [
  { to: "/chat", label: "Chat", icon: IconChat, badge: null },
  { to: "/tasks", label: "Tasks", icon: IconTasks, badge: null },
  { to: "/projects", label: "Projects", icon: IconProjects, badge: null },
  { to: "/memories", label: "Memory", icon: IconMemory, badge: null },
];
</script>

<style>
/* ── Google Fonts ── */
@import url("https://fonts.googleapis.com/css2?family=Cormorant+Garamond:ital,wght@0,400;0,500;0,600;1,400&family=DM+Sans:wght@300;400;500&family=JetBrains+Mono:wght@400;500&display=swap");

*,
*::before,
*::after {
  box-sizing: border-box;
  margin: 0;
  padding: 0;
}

html,
body,
#__nuxt {
  height: 100%;
  background: #0d0c0b;
  color: #f0ead8;
  font-family: "DM Sans", sans-serif;
  -webkit-font-smoothing: antialiased;
}

/* ── App shell ── */
.app-shell {
  display: flex;
  height: 100vh;
  overflow: hidden;
}

/* ── Sidebar ── */
.sidebar {
  width: 220px;
  flex-shrink: 0;
  display: flex;
  flex-direction: column;
  background: #141310;
  border-right: 1px solid #2a2722;
  padding: 24px 16px;
}

.sidebar-logo {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 0 8px;
  margin-bottom: 36px;
}

.logo-mark {
  width: 32px;
  height: 32px;
  border-radius: 8px;
  background: #c9a84c;
  color: #0d0c0b;
  font-family: "Cormorant Garamond", serif;
  font-size: 1.25rem;
  font-weight: 600;
  display: flex;
  align-items: center;
  justify-content: center;
  letter-spacing: -0.02em;
}

.logo-text {
  font-family: "Cormorant Garamond", serif;
  font-size: 1.4rem;
  font-weight: 500;
  color: #f0ead8;
  letter-spacing: 0.06em;
}

/* ── Nav ── */
.sidebar-nav {
  display: flex;
  flex-direction: column;
  gap: 4px;
  flex: 1;
}

.nav-item {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 9px 12px;
  border-radius: 8px;
  color: #9a8f7e;
  text-decoration: none;
  font-size: 0.875rem;
  font-weight: 400;
  transition:
    background 0.15s,
    color 0.15s;
  position: relative;
}

.nav-item:hover {
  background: #1c1a17;
  color: #f0ead8;
}

.nav-item.active {
  background: #1c1a17;
  color: #c9a84c;
}

.nav-item.active::before {
  content: "";
  position: absolute;
  left: 0;
  top: 50%;
  transform: translateY(-50%);
  width: 3px;
  height: 18px;
  background: #c9a84c;
  border-radius: 0 2px 2px 0;
}

.nav-icon {
  width: 18px;
  height: 18px;
  flex-shrink: 0;
}
.nav-label {
  flex: 1;
}

.nav-badge {
  background: #7a6128;
  color: #e2c47a;
  font-size: 0.65rem;
  font-weight: 500;
  padding: 2px 6px;
  border-radius: 999px;
}

/* ── Sidebar footer ── */
.sidebar-footer {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 8px;
  margin-top: 16px;
  border-top: 1px solid #2a2722;
  padding-top: 16px;
}

.mood-indicator {
  display: flex;
  align-items: center;
  gap: 8px;
}

.mood-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  animation: pulseGold 3s ease-in-out infinite;
}

.mood-label {
  font-size: 0.75rem;
  color: #9a8f7e;
  text-transform: capitalize;
}

.user-avatar {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  background: #2a2722;
  border: 1px solid #3d3830;
  color: #9a8f7e;
  font-size: 0.7rem;
  font-weight: 500;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition:
    border-color 0.15s,
    color 0.15s;
}

.user-avatar:hover {
  border-color: #c9a84c;
  color: #c9a84c;
}

/* ── Main content ── */
.main-content {
  flex: 1;
  overflow-y: auto;
  overflow-x: hidden;
}

/* ── Keyframes ── */
@keyframes pulseGold {
  0%,
  100% {
    opacity: 0.4;
  }
  50% {
    opacity: 0.9;
  }
}

@keyframes fadeUp {
  0% {
    opacity: 0;
    transform: translateY(12px);
  }
  100% {
    opacity: 1;
    transform: translateY(0);
  }
}

@keyframes fadeIn {
  0% {
    opacity: 0;
  }
  100% {
    opacity: 1;
  }
}

/* ── Scrollbar ── */
::-webkit-scrollbar {
  width: 4px;
}
::-webkit-scrollbar-track {
  background: transparent;
}
::-webkit-scrollbar-thumb {
  background: #3d3830;
  border-radius: 4px;
}
::-webkit-scrollbar-thumb:hover {
  background: #5a5248;
}
</style>
