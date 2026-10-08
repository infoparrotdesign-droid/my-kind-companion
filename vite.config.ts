// @lovable.dev/vite-tanstack-config already includes the following — do NOT add them manually
// or the app will break with duplicate plugins:
//   - TanStack devtools (dev-only, first), tanstackStart, viteReact, tailwindcss, tsConfigPaths,
//     nitro (build-only using cloudflare as a default target), VITE_* env injection, @ path alias,
//     React/TanStack dedupe, error logger plugins, and sandbox detection (port/host/strictPort).
// You can pass additional config via defineConfig({ vite: { ... }, etc... }) if needed.
import { defineConfig } from "@lovable.dev/vite-tanstack-config";

// Public (publishable) backend values. Baked in as a fallback so published builds
// work even when the .env file is not present in the build environment.
// Canonical Parrot Supabase project. The public client must not silently drift
// to an old Lovable/preview environment when runtime variables are stale.
const SUPABASE_URL = "https://agpxxmyypbnxnajdwmws.supabase.co";
const SUPABASE_PUBLISHABLE_KEY = "sb_publishable_87OiyND52hQkmb9rfTzslw_keDirei4";
const SUPABASE_PROJECT_ID = "agpxxmyypbnxnajdwmws";

export default defineConfig({
  tanstackStart: {
    // Redirect TanStack Start's bundled server entry to src/server.ts (our SSR error wrapper).
    // nitro/vite builds from this
    server: { entry: "server" },
  },
  vite: {
    define: {
      "import.meta.env.VITE_SUPABASE_URL": JSON.stringify(SUPABASE_URL),
      "import.meta.env.VITE_SUPABASE_PUBLISHABLE_KEY": JSON.stringify(SUPABASE_PUBLISHABLE_KEY),
      "import.meta.env.VITE_SUPABASE_PROJECT_ID": JSON.stringify(SUPABASE_PROJECT_ID),
    },
  },
});
