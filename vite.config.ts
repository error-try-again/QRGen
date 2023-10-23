import type { InlineConfig } from 'vitest';
import type { UserConfig } from 'vite';
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import { checker } from 'vite-plugin-checker';

interface VitestTestingConfig extends UserConfig {
  test: InlineConfig;
}

export default defineConfig({
  plugins: [react(), checker({ typescript: true })],
  test: {
    environment: 'jsdom',
    globals: true,
    transformMode: {
      web: [/\.[jt]sx?$/]
    },
    // setupFiles: './setup-vitest.ts',
    testMatch: ['./src/__tests__/tests/**/*.test.tsx'],
    include: ['**/*.test.tsx']
  },
  root: '.',
  build: {
    target: 'ES2022'
  }
} as VitestTestingConfig);
