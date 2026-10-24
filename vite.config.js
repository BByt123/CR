import { defineConfig } from 'vite';

export default defineConfig({
  base: './',
  build: {
    outDir: process.env.BUILD_TARGET === 'android' ? 'android/app/src/main/assets/game' : 'dist',
    emptyOutDir: true,
    target: 'es2022',
    sourcemap: false,
    rollupOptions: {
      output: { manualChunks: undefined },
    },
  },
  server: { host: '0.0.0.0' },
});
