import { createClient } from "@supabase/supabase-js";

const supabaseUrl = import.meta.env["VITE_SUPABASE_URL"] as string | undefined;
const supabaseKey = (import.meta.env["VITE_SUPABASE_PUBLISHABLE_KEY"] ?? import.meta.env["VITE_SUPABASE_ANON_KEY"]) as string | undefined;

export const isBackendConfigured = Boolean(supabaseUrl && supabaseKey);
if (!isBackendConfigured) console.warn("Backend not configured: online catalog, login and uploads are disabled.");

// Fallback values keep the site rendering; requests simply fail until the backend is connected.
export const supabase = createClient(supabaseUrl || "https://not-configured.invalid", supabaseKey || "not-configured");
export const ADMIN_EMAIL = "info.parrotdesign@gmail.com";
export const IMAGE_BUCKET = "parrot-images";
