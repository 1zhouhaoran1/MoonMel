/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx,html}",
  ],
  darkMode: 'class',
  theme: {
    extend: {
      colors: {
        studio: {
          950: '#0b0f14',
          900: '#11161f',
          850: '#161d28',
          800: '#1d2634',
          700: '#2b384a',
          600: '#40526a',
          400: '#7f93ad',
          200: '#cbd5e1',
          100: '#f1f5f9',
        },
        accent: {
          gold: '#d4a373',
          amber: '#e29578',
          warm: '#f3c68f',
          copper: '#c97a56'
        }
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', '-apple-system', 'sans-serif'],
        mono: ['JetBrains Mono', 'Fira Code', 'monospace'],
      }
    },
  },
  plugins: [],
}
