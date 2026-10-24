import { defineConfig } from 'vite';

// GitHub Pages serves this repository below /CR/. Keep local development and
// Android builds relative, while making the hosted bundle's asset URLs stable.
const repositoryName = process.env.GITHUB_REPOSITORY?.split('/')[1];
const androidBuild = process.env.BUILD_TARGET === 'android';
const pagesBase = !androidBuild && process.env.GITHUB_ACTIONS === 'true' && repositoryName
  ? `/${repositoryName}/`
  : './';

export default defineConfig({
  base: pagesBase,
  build: {
    outDir: androidBuild ? 'android/app/src/main/assets/game' : 'dist',
    emptyOutDir: true,
    target: 'es2022',
    sourcemap: false,
    rollupOptions: {
      output: { manualChunks: undefined },
    },
  },
  server: { host: '0.0.0.0' },
});
