<template>
  <main class="chat-main">
    <!-- Date navigation header -->
    <header class="chat-header">
      <div class="date-nav">
        <button class="date-btn" @click="goToPrevDay" aria-label="Previous day">
          ‹
        </button>
        <button class="date-label" @click="jumpToToday">
          {{ formattedDate }}
        </button>
        <button
          class="date-btn"
          @click="goToNextDay"
          :disabled="isToday"
          aria-label="Next day"
        >
          ›
        </button>
      </div>

      <div class="header-right">
        <input
          v-if="showDatePicker"
          type="date"
          class="date-picker-input"
          :max="todayISO"
          :value="selectedDateISO"
          @change="onDatePickerChange"
          @blur="showDatePicker = false"
          ref="datePickerRef"
        />
        <button
          class="icon-btn"
          @click="toggleDatePicker"
          aria-label="Jump to date"
        >
          <svg
            width="16"
            height="16"
            viewBox="0 0 16 16"
            fill="none"
            xmlns="http://www.w3.org/2000/svg"
          >
            <rect
              x="1"
              y="2.5"
              width="14"
              height="12.5"
              rx="2"
              stroke="currentColor"
              stroke-width="1.2"
            />
            <path
              d="M5 1V4M11 1V4M1 6.5H15"
              stroke="currentColor"
              stroke-width="1.2"
              stroke-linecap="round"
            />
          </svg>
        </button>
      </div>
    </header>

    <!-- Messages -->
    <div class="messages-container" ref="messagesContainer">
      <div class="messages-inner">
        <!-- Day separator -->
        <div v-if="groupedMessages.length > 0" class="day-marker">
          <span>{{ formattedDate }}</span>
        </div>

        <!-- Empty state -->
        <div v-if="groupedMessages.length === 0" class="empty-state">
          <p class="empty-greeting">{{ greeting }}, {{ userName }}.</p>
          <p class="empty-sub">What's on your mind?</p>
        </div>

        <!-- Message list -->
        <template v-for="msg in groupedMessages" :key="msg.id">
          <div
            :class="[
              'message',
              msg.role === 'user' ? 'message-user' : 'message-maia',
            ]"
          >
            <div v-if="msg.role === 'assistant'" class="maia-label">maia</div>
            <div class="message-bubble" v-html="renderMessage(msg.content)" />
            <div class="message-time">{{ formatTime(msg.created_at) }}</div>
          </div>
        </template>

        <!-- Typing indicator -->
        <div v-if="isTyping" class="message message-maia">
          <div class="maia-label">maia</div>
          <div class="message-bubble typing-bubble">
            <span class="dot" /><span class="dot" /><span class="dot" />
          </div>
        </div>
      </div>
    </div>

    <!-- Input area -->
    <footer class="input-area">
      <div class="input-wrapper">
        <textarea
          ref="inputRef"
          v-model="inputText"
          class="chat-input"
          placeholder="Talk to Maia…"
          rows="1"
          @keydown.enter.exact.prevent="sendMessage"
          @keydown.enter.shift.exact="newline"
          @input="autoResize"
        />
        <button
          class="send-btn"
          @click="sendMessage"
          :disabled="!inputText.trim() || isTyping"
          aria-label="Send message"
        >
          <svg
            width="16"
            height="16"
            viewBox="0 0 16 16"
            fill="none"
            xmlns="http://www.w3.org/2000/svg"
          >
            <path
              d="M8 13V3M8 3L4 7M8 3L12 7"
              stroke="currentColor"
              stroke-width="1.5"
              stroke-linecap="round"
              stroke-linejoin="round"
            />
          </svg>
        </button>
      </div>
      <p class="input-hint">Enter to send · Shift+Enter for new line</p>
    </footer>
  </main>
</template>

<script setup lang="ts">
const supabase = useSupabaseClient();
const user = useSupabaseUser();

// ── Date navigation ──────────────────────────────────────────
const today = new Date();
today.setHours(0, 0, 0, 0);

const selectedDate = ref(new Date(today));
const showDatePicker = ref(false);
const datePickerRef = ref<HTMLInputElement | null>(null);

const todayISO = computed(() => today.toISOString().split("T")[0]);

const selectedDateISO = computed(
  () => selectedDate.value.toISOString().split("T")[0],
);

const isToday = computed(
  () => selectedDate.value.getTime() === today.getTime(),
);

const formattedDate = computed(() => {
  const d = selectedDate.value;
  if (d.getTime() === today.getTime()) return "Today";
  const yesterday = new Date(today);
  yesterday.setDate(today.getDate() - 1);
  if (d.getTime() === yesterday.getTime()) return "Yesterday";
  return d.toLocaleDateString("en-US", {
    weekday: "long",
    month: "long",
    day: "numeric",
  });
});

function goToPrevDay() {
  const d = new Date(selectedDate.value);
  d.setDate(d.getDate() - 1);
  selectedDate.value = d;
  fetchMessages();
}

function goToNextDay() {
  if (isToday.value) return;
  const d = new Date(selectedDate.value);
  d.setDate(d.getDate() + 1);
  selectedDate.value = d;
  fetchMessages();
}

function jumpToToday() {
  selectedDate.value = new Date(today);
  fetchMessages();
}

function toggleDatePicker() {
  showDatePicker.value = !showDatePicker.value;
  if (showDatePicker.value) {
    nextTick(() => datePickerRef.value?.showPicker?.());
  }
}

function onDatePickerChange(e: Event) {
  const val = (e.target as HTMLInputElement).value;
  if (val) {
    const [y, m, d] = val.split("-").map(Number);
    selectedDate.value = new Date(y, m - 1, d);
    fetchMessages();
  }
  showDatePicker.value = false;
}

// ── Greeting ─────────────────────────────────────────────────
const userName = computed(() => user.value?.email?.split("@")[0] ?? "there");

const greeting = computed(() => {
  const h = new Date().getHours();
  if (h < 12) return "Good morning";
  if (h < 18) return "Good afternoon";
  return "Good evening";
});

// ── Messages ─────────────────────────────────────────────────
interface Message {
  id: string;
  role: "user" | "assistant";
  content: string;
  created_at: string;
}

const allMessages = ref<Message[]>([]);
const isTyping = ref(false);
const inputText = ref("");
const messagesContainer = ref<HTMLElement | null>(null);
const inputRef = ref<HTMLTextAreaElement | null>(null);

const groupedMessages = computed(() => {
  const start = new Date(selectedDate.value);
  const end = new Date(selectedDate.value);
  end.setDate(end.getDate() + 1);
  return allMessages.value.filter((m) => {
    const t = new Date(m.created_at);
    return t >= start && t < end;
  });
});

async function fetchMessages() {
  if (!user.value) return;
  const start = new Date(selectedDate.value).toISOString();
  const end = new Date(
    new Date(selectedDate.value).setDate(selectedDate.value.getDate() + 1),
  ).toISOString();

  const { data } = await supabase
    .from("messages")
    .select("*")
    .eq("user_id", user.value.id)
    .gte("created_at", start)
    .lt("created_at", end)
    .order("created_at", { ascending: true });

  if (data) allMessages.value = data as Message[];
  await nextTick();
  scrollToBottom();
}

async function sendMessage() {
  const text = inputText.value.trim();
  if (!text || isTyping.value || !user.value) return;

  inputText.value = "";
  resetInputHeight();

  // Optimistic user message
  const userMsg: Message = {
    id: crypto.randomUUID(),
    role: "user",
    content: text,
    created_at: new Date().toISOString(),
  };
  allMessages.value.push(userMsg);
  await nextTick();
  scrollToBottom();

  // Persist user message
  await supabase.from("messages").insert({
    user_id: user.value.id,
    role: "user",
    content: text,
  });

  // Call Maia (Anthropic) via server route
  isTyping.value = true;
  await nextTick();
  scrollToBottom();

  try {
    const history = allMessages.value
      .filter((m) => m.id !== userMsg.id)
      .slice(-20)
      .map((m) => ({ role: m.role, content: m.content }));

    const res = await $fetch<{ content: string }>("/api/chat", {
      method: "POST",
      body: { message: text, history },
    });

    const assistantMsg: Message = {
      id: crypto.randomUUID(),
      role: "assistant",
      content: res.content,
      created_at: new Date().toISOString(),
    };

    allMessages.value.push(assistantMsg);

    await supabase.from("messages").insert({
      user_id: user.value.id,
      role: "assistant",
      content: res.content,
    });
  } catch (err) {
    console.error("Chat error:", err);
    allMessages.value.push({
      id: crypto.randomUUID(),
      role: "assistant",
      content: "Sorry, something went wrong. Please try again.",
      created_at: new Date().toISOString(),
    });
  } finally {
    isTyping.value = false;
    await nextTick();
    scrollToBottom();
  }
}

function renderMessage(content: string): string {
  // Basic markdown: bold, italic, code, line breaks
  return content
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/\*\*(.*?)\*\*/g, "<strong>$1</strong>")
    .replace(/\*(.*?)\*/g, "<em>$1</em>")
    .replace(/`(.*?)`/g, "<code>$1</code>")
    .replace(/\n/g, "<br/>");
}

function formatTime(iso: string): string {
  return new Date(iso).toLocaleTimeString("en-US", {
    hour: "numeric",
    minute: "2-digit",
  });
}

function scrollToBottom() {
  if (messagesContainer.value) {
    messagesContainer.value.scrollTop = messagesContainer.value.scrollHeight;
  }
}

// ── Input resize ─────────────────────────────────────────────
function autoResize(e: Event) {
  const el = e.target as HTMLTextAreaElement;
  el.style.height = "auto";
  el.style.height = Math.min(el.scrollHeight, 160) + "px";
}

function resetInputHeight() {
  if (inputRef.value) {
    inputRef.value.style.height = "auto";
  }
}

function newline() {
  inputText.value += "\n";
  nextTick(() => {
    if (inputRef.value) {
      inputRef.value.style.height = "auto";
      inputRef.value.style.height =
        Math.min(inputRef.value.scrollHeight, 160) + "px";
    }
  });
}

// ── Auth ─────────────────────────────────────────────────────
async function handleSignOut() {
  await supabase.auth.signOut();
  navigateTo("/auth");
}

// ── Lifecycle ────────────────────────────────────────────────
onMounted(() => {
  fetchMessages();
});

// Realtime subscription for today
onMounted(() => {
  if (!user.value) return;
  const channel = supabase
    .channel("messages")
    .on(
      "postgres_changes",
      {
        event: "INSERT",
        schema: "public",
        table: "messages",
        filter: `user_id=eq.${user.value.id}`,
      },
      (payload) => {
        const msg = payload.new as Message;
        // Only add if not already in list (avoid duplicates from optimistic update)
        if (!allMessages.value.find((m) => m.id === msg.id)) {
          allMessages.value.push(msg);
          nextTick(scrollToBottom);
        }
      },
    )
    .subscribe();

  onUnmounted(() => {
    supabase.removeChannel(channel);
  });
});
</script>

<style scoped>
/* ── Chat main ────────────────────────────────────────────── */
.chat-main {
  @apply flex flex-col flex-1 min-w-0 h-full;
}

/* ── Header ───────────────────────────────────────────────── */
.chat-header {
  @apply flex items-center justify-between px-6 py-4
         border-b border-dim/20 bg-void shrink-0;
}

.date-nav {
  @apply flex items-center gap-2;
}

.date-btn {
  @apply w-7 h-7 flex items-center justify-center rounded-md text-dim text-lg
         hover:text-ink hover:bg-surface transition-colors
         disabled:opacity-30 disabled:cursor-not-allowed;
}

.date-label {
  @apply text-sm font-medium text-ink px-3 py-1 rounded-md
         hover:bg-surface transition-colors cursor-pointer;
}

.header-right {
  @apply flex items-center gap-2;
}

.date-picker-input {
  @apply bg-surface border border-dim/30 rounded-lg px-3 py-1.5
         text-sm text-ink outline-none focus:border-gold/60;
}

.icon-btn {
  @apply w-8 h-8 flex items-center justify-center rounded-lg text-dim
         hover:text-ink hover:bg-surface transition-colors;
}

/* ── Messages ─────────────────────────────────────────────── */
.messages-container {
  @apply flex-1 overflow-y-auto px-6 py-4;
  scroll-behavior: smooth;
}

.messages-inner {
  @apply max-w-2xl mx-auto flex flex-col gap-4;
}

.day-marker {
  @apply flex items-center justify-center my-4;
}

.day-marker span {
  @apply text-xs text-dim bg-void px-3 py-1 rounded-full border border-dim/20;
}

.empty-state {
  @apply flex flex-col items-center justify-center py-32 gap-2 text-center;
}

.empty-greeting {
  @apply text-2xl font-light text-ink tracking-wide;
}

.empty-sub {
  @apply text-sm text-dim;
}

/* ── Message bubbles ──────────────────────────────────────── */
.message {
  @apply flex flex-col gap-1;
}

.message-user {
  @apply items-end;
}

.message-maia {
  @apply items-start;
}

.maia-label {
  @apply text-xs text-gold tracking-widest px-1 mb-0.5;
}

.message-bubble {
  @apply px-4 py-3 rounded-2xl text-sm leading-relaxed max-w-lg;
}

.message-user .message-bubble {
  @apply bg-gold/10 text-ink border border-gold/20 rounded-br-sm;
}

.message-maia .message-bubble {
  @apply bg-surface text-ink border border-dim/20 rounded-bl-sm;
}

.message-bubble :deep(code) {
  @apply font-mono text-xs bg-dim/10 px-1.5 py-0.5 rounded;
}

.message-time {
  @apply text-xs text-dim/60 px-1;
}

/* ── Typing indicator ─────────────────────────────────────── */
.typing-bubble {
  @apply flex items-center gap-1.5 py-4 px-5;
}

.dot {
  @apply w-1.5 h-1.5 rounded-full bg-dim/60 inline-block;
  animation: bounce 1.2s ease-in-out infinite;
}
.dot:nth-child(2) {
  animation-delay: 0.2s;
}
.dot:nth-child(3) {
  animation-delay: 0.4s;
}

@keyframes bounce {
  0%,
  60%,
  100% {
    transform: translateY(0);
  }
  30% {
    transform: translateY(-5px);
  }
}

/* ── Input ────────────────────────────────────────────────── */
.input-area {
  @apply shrink-0 px-6 py-4 border-t border-dim/20 bg-void;
}

.input-wrapper {
  @apply max-w-2xl mx-auto flex items-end gap-3
         bg-surface border border-dim/30 rounded-2xl px-4 py-3
         focus-within:border-gold/40 transition-colors;
}

.chat-input {
  @apply flex-1 bg-transparent text-sm text-ink resize-none outline-none
         placeholder-dim/50 leading-relaxed;
  min-height: 24px;
  max-height: 160px;
}

.send-btn {
  @apply w-8 h-8 flex items-center justify-center rounded-xl
         bg-gold/90 text-void hover:bg-gold transition-colors
         disabled:opacity-40 disabled:cursor-not-allowed shrink-0;
}

.input-hint {
  @apply text-xs text-dim/40 text-center mt-2 max-w-2xl mx-auto;
}
</style>
