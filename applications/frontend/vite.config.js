import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

export default defineConfig({
  plugins: [react()],
  build: {
    outDir: "dist",
  },
  server: {
    port: 5173,
    // Em dev, redireciona chamadas /api para o backend local.
    proxy: {
      "/api": "http://localhost:8080",
    },
  },
});
