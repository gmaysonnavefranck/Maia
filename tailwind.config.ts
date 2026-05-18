/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./components/**/*.{js,vue,ts}",
    "./layouts/**/*.vue",
    "./pages/**/*.vue",
    "./plugins/**/*.{js,ts}",
    "./app.vue",
    "./error.vue",
  ],
  theme: {
    extend: {
      colors: {
        // Base surfaces
        void: "#0d0c0b", // deepest background
        surface: "#141310", // card / panel background
        raised: "#1c1a17", // elevated elements
        border: "#2a2722", // subtle borders
        muted: "#3d3830", // dividers, disabled

        // Text
        ink: "#f0ead8", // primary text (warm white)
        dim: "#9a8f7e", // secondary text
        ghost: "#5a5248", // placeholder, very muted

        // Brand accent — amber gold
        gold: "#c9a84c",
        "gold-light": "#e2c47a",
        "gold-dim": "#7a6128",

        // Semantic
        sage: "#6b8f71", // success / positive
        rose: "#b36464", // error / caution
        slate: "#6b7fa3", // info / neutral
      },

      fontFamily: {
        display: ['"Cormorant Garamond"', "Georgia", "serif"],
        body: ['"DM Sans"', "sans-serif"],
        mono: ['"JetBrains Mono"', "monospace"],
      },

      fontSize: {
        "2xs": ["0.65rem", { lineHeight: "1rem" }],
      },

      borderRadius: {
        sm: "4px",
        DEFAULT: "8px",
        lg: "14px",
        xl: "20px",
      },

      boxShadow: {
        glow: "0 0 24px -4px rgba(201,168,76,0.18)",
        panel: "0 2px 24px rgba(0,0,0,0.45)",
        float: "0 8px 40px rgba(0,0,0,0.6)",
      },

      animation: {
        "fade-up": "fadeUp 0.5s ease both",
        "fade-in": "fadeIn 0.4s ease both",
        shimmer: "shimmer 2s linear infinite",
        "pulse-gold": "pulseGold 3s ease-in-out infinite",
      },

      keyframes: {
        fadeUp: {
          "0%": { opacity: "0", transform: "translateY(12px)" },
          "100%": { opacity: "1", transform: "translateY(0)" },
        },
        fadeIn: {
          "0%": { opacity: "0" },
          "100%": { opacity: "1" },
        },
        shimmer: {
          "0%": { backgroundPosition: "-400px 0" },
          "100%": { backgroundPosition: "400px 0" },
        },
        pulseGold: {
          "0%, 100%": { opacity: "0.4" },
          "50%": { opacity: "0.9" },
        },
      },
    },
  },
  plugins: [],
};
