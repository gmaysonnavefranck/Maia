<template>
  <div
    class="min-h-screen flex flex-col items-center justify-center bg-void relative overflow-hidden gap-6 p-6"
  >
    <!-- Background atmosphere -->
    <div
      class="absolute -top-[200px] left-1/2 -translate-x-1/2 w-[600px] h-[600px] rounded-full pointer-events-none bg-[radial-gradient(circle,rgba(201,168,76,0.07)_0%,transparent_70%)]"
    />
    <div class="bg-grain absolute inset-0 opacity-[0.035] pointer-events-none" />

    <!-- Card -->
    <div
      class="w-full max-w-[400px] bg-surface border border-border rounded-xl px-9 py-10 flex flex-col gap-7 shadow-float animate-fade-up relative z-[1]"
    >
      <!-- Logo -->
      <div class="flex justify-center">
        <div
          class="w-[52px] h-[52px] bg-gold text-void rounded-lg font-display text-[2rem] font-semibold flex items-center justify-center tracking-tight shadow-[0_0_24px_-4px_rgba(201,168,76,0.4)]"
        >
          M
        </div>
      </div>

      <!-- Copy -->
      <div class="text-center">
        <h1 class="font-display text-[1.9rem] font-medium text-ink leading-tight mb-2">
          {{ title }}
        </h1>
        <p class="text-sm text-dim leading-relaxed transition-all duration-300">
          {{ subtitle }}
        </p>
      </div>

      <!-- Form / Success -->
      <div class="min-h-[140px] flex flex-col">
        <Transition name="swap" mode="out-in">
          <div v-if="!sent" :key="mode" class="flex flex-col gap-3">
            <!-- Email -->
            <div class="flex flex-col gap-1.5">
              <label class="text-xs font-medium text-dim uppercase tracking-[0.05em]" for="email">
                Email
              </label>
              <input
                id="email"
                v-model="email"
                type="email"
                :class="[
                  'w-full bg-raised border rounded px-3.5 py-[11px] font-body text-[0.9rem] text-ink outline-none transition-[border-color,box-shadow] duration-150 placeholder:text-ghost',
                  errorMsg
                    ? 'border-rose'
                    : emailFocused
                      ? 'border-gold shadow-[0_0_0_3px_rgba(201,168,76,0.1)]'
                      : 'border-border',
                ]"
                placeholder="you@example.com"
                autocomplete="email"
                @focus="emailFocused = true"
                @blur="emailFocused = false"
                @keydown.enter="handleSubmit"
              />
            </div>

            <!-- Password (password + register modes) -->
            <div
              v-if="mode === 'password' || mode === 'register'"
              class="flex flex-col gap-1.5"
            >
              <div class="flex items-baseline justify-between">
                <label
                  class="text-xs font-medium text-dim uppercase tracking-[0.05em]"
                  for="password"
                >
                  Password
                </label>
                <button
                  v-if="mode === 'password'"
                  class="text-xs text-dim hover:text-ink transition-colors duration-150 cursor-pointer"
                  type="button"
                  @click="switchMode('forgot')"
                >
                  Forgot?
                </button>
              </div>
              <input
                id="password"
                v-model="password"
                type="password"
                :class="[
                  'w-full bg-raised border rounded px-3.5 py-[11px] font-body text-[0.9rem] text-ink outline-none transition-[border-color,box-shadow] duration-150 placeholder:text-ghost',
                  passwordFocused
                    ? 'border-gold shadow-[0_0_0_3px_rgba(201,168,76,0.1)]'
                    : 'border-border',
                ]"
                :placeholder="mode === 'register' ? 'Choose a password' : '••••••••'"
                :autocomplete="mode === 'register' ? 'new-password' : 'current-password'"
                @focus="passwordFocused = true"
                @blur="passwordFocused = false"
                @keydown.enter="handleSubmit"
              />
            </div>

            <!-- Error -->
            <Transition name="error">
              <p v-if="errorMsg" class="text-[0.8rem] text-rose">{{ errorMsg }}</p>
            </Transition>

            <!-- Submit -->
            <button
              :class="[
                'w-full bg-gold text-void rounded font-body text-[0.9rem] font-medium flex items-center justify-center h-11 mt-1 transition-[opacity,transform] duration-150',
                isDisabled
                  ? 'opacity-[0.45] cursor-not-allowed'
                  : 'cursor-pointer hover:opacity-[0.88] active:scale-[0.99]',
              ]"
              :disabled="isDisabled"
              @click="handleSubmit"
            >
              <span v-if="!isLoading">{{ submitLabel }}</span>
              <span
                v-else
                class="w-4 h-4 border-2 border-void/30 border-t-void rounded-full animate-spin"
              />
            </button>

            <!-- Mode links -->
            <div class="flex items-center justify-center gap-3 pt-1 text-xs text-dim">
              <template v-if="mode === 'magic'">
                <button
                  class="hover:text-ink transition-colors duration-150 cursor-pointer"
                  type="button"
                  @click="switchMode('password')"
                >
                  Sign in with password
                </button>
              </template>
              <template v-else-if="mode === 'password'">
                <button
                  class="hover:text-ink transition-colors duration-150 cursor-pointer"
                  type="button"
                  @click="switchMode('magic')"
                >
                  Use magic link
                </button>
                <span class="text-ghost">·</span>
                <button
                  class="hover:text-ink transition-colors duration-150 cursor-pointer"
                  type="button"
                  @click="switchMode('register')"
                >
                  Create account
                </button>
              </template>
              <template v-else-if="mode === 'register'">
                <button
                  class="hover:text-ink transition-colors duration-150 cursor-pointer"
                  type="button"
                  @click="switchMode('password')"
                >
                  Already have an account?
                </button>
              </template>
              <template v-else-if="mode === 'forgot'">
                <button
                  class="hover:text-ink transition-colors duration-150 cursor-pointer"
                  type="button"
                  @click="switchMode('password')"
                >
                  ← Back to sign in
                </button>
              </template>
            </div>
          </div>

          <!-- Success state -->
          <div v-else key="success" class="flex-1 flex flex-col items-center justify-center gap-4">
            <div class="w-12 h-12 text-gold icon-bloom">
              <svg
                xmlns="http://www.w3.org/2000/svg"
                fill="none"
                viewBox="0 0 24 24"
                stroke-width="1.5"
                stroke="currentColor"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  d="M21.75 6.75v10.5a2.25 2.25 0 0 1-2.25 2.25h-15a2.25 2.25 0 0 1-2.25-2.25V6.75m19.5 0A2.25 2.25 0 0 0 19.5 4.5h-15a2.25 2.25 0 0 0-2.25 2.25m19.5 0v.243a2.25 2.25 0 0 1-1.07 1.916l-7.5 4.615a2.25 2.25 0 0 1-2.36 0L3.32 8.91a2.25 2.25 0 0 1-1.07-1.916V6.75"
                />
              </svg>
            </div>
            <button
              class="bg-transparent border-none text-dim text-[0.825rem] cursor-pointer underline underline-offset-[3px] font-body transition-colors duration-150 hover:text-ink"
              @click="sent = false"
            >
              Use a different email
            </button>
          </div>
        </Transition>
      </div>

      <!-- Divider + Google (hidden in success state) -->
      <template v-if="!sent">
        <div class="flex items-center gap-3 text-ghost text-xs">
          <div class="flex-1 h-px bg-border" />
          <span>or</span>
          <div class="flex-1 h-px bg-border" />
        </div>

        <button
          class="w-full flex items-center justify-center gap-2.5 px-4 py-[11px] bg-raised border border-border rounded text-ink font-body text-sm cursor-pointer transition-[border-color,background] duration-150 hover:border-muted hover:bg-[#222018]"
          @click="signInWithGoogle"
        >
          <svg
            class="w-[18px] h-[18px] flex-shrink-0"
            viewBox="0 0 24 24"
            xmlns="http://www.w3.org/2000/svg"
          >
            <path
              d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"
              fill="#4285F4"
            />
            <path
              d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"
              fill="#34A853"
            />
            <path
              d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"
              fill="#FBBC05"
            />
            <path
              d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"
              fill="#EA4335"
            />
          </svg>
          Continue with Google
        </button>
      </template>
    </div>

    <!-- Footer -->
    <p class="text-xs text-ghost text-center relative z-[1]">
      Maia keeps your data private and never shares it.
    </p>

    <!-- Dev state debugger -->
    <div
      v-if="isDev"
      class="fixed bottom-4 left-1/2 -translate-x-1/2 flex items-center gap-2 bg-surface border border-border rounded px-3 py-2 z-50"
    >
      <span class="font-mono text-2xs text-ghost uppercase tracking-wider">dev</span>
      <button
        v-for="state in DEBUG_STATES"
        :key="state"
        class="text-xs text-dim px-2 py-1 rounded cursor-pointer hover:bg-raised hover:text-ink transition-colors duration-150"
        @click="applyDebugState(state)"
      >
        {{ state }}
      </button>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from "vue";
import { useRouter } from "vue-router";
import { useSupabaseClient } from "#imports";

definePageMeta({ layout: false });

const router = useRouter();
const supabase = useSupabaseClient();

const mode = ref("magic"); // 'magic' | 'password' | 'register' | 'forgot'
const email = ref("");
const password = ref("");
const sent = ref(false);
const isLoading = ref(false);
const errorMsg = ref("");
const emailFocused = ref(false);
const passwordFocused = ref(false);

const title = computed(() => {
  if (sent.value) return "Check your inbox.";
  if (mode.value === "register") return "Create account.";
  if (mode.value === "forgot") return "Reset password.";
  return "Good to see you.";
});

const subtitle = computed(() => {
  if (sent.value) {
    return mode.value === "forgot"
      ? "A password reset link is on its way."
      : "A sign-in link is on its way.";
  }
  if (mode.value === "password") return "Sign in with your email and password.";
  if (mode.value === "register") return "Create your Maia account.";
  if (mode.value === "forgot") return "We'll send a reset link to your email.";
  return "Enter your email and Maia will send you a sign-in link.";
});

const submitLabel = computed(() => {
  if (mode.value === "password") return "Sign in";
  if (mode.value === "register") return "Create account";
  if (mode.value === "forgot") return "Send reset link";
  return "Send link";
});

const isDisabled = computed(() => {
  if (isLoading.value || !email.value) return true;
  if ((mode.value === "password" || mode.value === "register") && !password.value) return true;
  return false;
});

function switchMode(newMode) {
  mode.value = newMode;
  errorMsg.value = "";
  sent.value = false;
}

async function handleSubmit() {
  if (mode.value === "magic") await sendMagicLink();
  else if (mode.value === "password") await signInWithPassword();
  else if (mode.value === "register") await signUp();
  else await sendPasswordReset();
}

async function sendMagicLink() {
  if (!email.value) return;
  isLoading.value = true;
  errorMsg.value = "";
  const { error } = await supabase.auth.signInWithOtp({
    email: email.value,
    options: { emailRedirectTo: `${window.location.origin}/` },
  });
  isLoading.value = false;
  if (error) errorMsg.value = error.message;
  else sent.value = true;
}

async function signInWithPassword() {
  if (!email.value || !password.value) return;
  isLoading.value = true;
  errorMsg.value = "";
  const { error } = await supabase.auth.signInWithPassword({
    email: email.value,
    password: password.value,
  });
  isLoading.value = false;
  if (error) errorMsg.value = error.message;
  else await router.push("/");
}

async function signUp() {
  if (!email.value || !password.value) return;
  isLoading.value = true;
  errorMsg.value = "";
  const { error } = await supabase.auth.signUp({
    email: email.value,
    password: password.value,
    options: { emailRedirectTo: `${window.location.origin}/` },
  });
  isLoading.value = false;
  if (error) errorMsg.value = error.message;
  else sent.value = true;
}

async function sendPasswordReset() {
  if (!email.value) return;
  isLoading.value = true;
  errorMsg.value = "";
  const { error } = await supabase.auth.resetPasswordForEmail(email.value, {
    redirectTo: `${window.location.origin}/`,
  });
  isLoading.value = false;
  if (error) errorMsg.value = error.message;
  else sent.value = true;
}

async function signInWithGoogle() {
  const { error } = await supabase.auth.signInWithOAuth({
    provider: "google",
    options: { redirectTo: `${window.location.origin}/` },
  });
  if (error) errorMsg.value = error.message;
}

// Dev-only state debugger
const isDev = import.meta.dev;
const DEBUG_STATES = ["default", "focused", "loading", "error", "sent", "password", "register", "forgot"];
function applyDebugState(state) {
  const modes = ["password", "register", "forgot"];
  if (modes.includes(state)) {
    switchMode(state);
    email.value = "test@example.com";
    return;
  }
  switchMode("magic");
  email.value = state === "default" ? "" : "test@example.com";
  sent.value = state === "sent";
  isLoading.value = state === "loading";
  errorMsg.value = state === "error" ? "Unable to send email. Please try again." : "";
  emailFocused.value = state === "focused";
}
</script>

<style scoped>
/* Grain texture */
.bg-grain {
  background-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 256 256' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='noise'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.9' numOctaves='4' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23noise)'/%3E%3C/svg%3E");
  background-size: 200px;
}

/* Error message slide-in */
.error-enter-active,
.error-leave-active {
  transition: opacity 0.2s ease, max-height 0.2s ease;
  max-height: 40px;
  overflow: hidden;
}
.error-enter-from,
.error-leave-to {
  opacity: 0;
  max-height: 0;
}

/* Swap transition (form/success + mode changes) */
.swap-leave-active {
  transition: opacity 0.2s ease;
}
.swap-leave-to {
  opacity: 0;
}
.swap-enter-active {
  transition: opacity 0.35s ease;
}
.swap-enter-from {
  opacity: 0;
}

/* Success icon entrance */
.icon-bloom {
  animation: iconBloom 0.4s cubic-bezier(0.34, 1.56, 0.64, 1) 0.1s both;
}
@keyframes iconBloom {
  from {
    opacity: 0;
    transform: scale(0.5);
  }
  to {
    opacity: 1;
    transform: scale(1);
  }
}
</style>
