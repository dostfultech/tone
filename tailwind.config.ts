import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./app/**/*.{js,ts,jsx,tsx,mdx}",
    "./components/**/*.{js,ts,jsx,tsx,mdx}",
    "./lib/**/*.{js,ts,jsx,tsx,mdx}"
  ],
  theme: {
    extend: {
      colors: {
        ink: "#08071a",
        stage: "#f6f9ff",
        copper: "#7c8cff",
        ocean: "#5f8df7",
        moss: "#a7ff3f",
        ember: "#ff6f91"
      },
      boxShadow: {
        soft: "0 22px 70px rgba(95, 141, 247, 0.16)"
      }
    }
  },
  plugins: []
};

export default config;
