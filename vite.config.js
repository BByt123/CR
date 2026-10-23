import { defineConfig } from 'vite';

export default defineConfig({
  base: './',
  build: {
    outDir: 'android/app/src/main/assets/game',
    emptyOutDir: true,
    target: 'es2022',
    sourcemap: false,
    rollupOptions: {
      output: { manualChunks: undefined },
    },
  },
  server: { host: '0.0.0.0' },
});
