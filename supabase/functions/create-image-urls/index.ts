import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "npm:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Content-Type": "application/json",
};

const BUCKET = "parrot-images";
// This is the same public project key used by the browser client; it is not a secret.
const EXPECTED_PUBLIC_KEY = "sb_publishable_87OiyND52hQkmb9rfTzslw_keDirei4";
const ALLOWED_PREFIXES = ["products/", "services/", "portfolio/", "brand/"];
const TTL_SECONDS = 60 * 60;

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), { status, headers: corsHeaders });
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return json({ error: "Method not allowed" }, 405);
  if (req.headers.get("apikey") !== EXPECTED_PUBLIC_KEY) return json({ error: "Unauthorized" }, 401);

  try {
    const payload = await req.json().catch(() => null);
    const paths = payload && Array.isArray(payload.paths) ? payload.paths : null;
    if (!paths || paths.length < 1 || paths.length > 100) {
      return json({ error: "Envie entre 1 e 100 caminhos de imagem." }, 400);
    }

    const uniquePaths = [...new Set(paths)];
    if (uniquePaths.some((path) =>
      typeof path !== "string" ||
      path.length > 500 ||
      path.startsWith("/") ||
      path.includes("\\") ||
      path.split("/").some((part: string) => part === "." || part === "..") ||
      !ALLOWED_PREFIXES.some((prefix) => path.startsWith(prefix))
    )) {
      return json({ error: "Um ou mais caminhos de imagem não são permitidos." }, 400);
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
    if (!supabaseUrl || !serviceRoleKey) {
      console.error("Missing Supabase server environment variables.");
      return json({ error: "Serviço de imagens temporariamente indisponível." }, 503);
    }

    const adminClient = createClient(supabaseUrl, serviceRoleKey, {
      auth: { persistSession: false, autoRefreshToken: false },
    });
    const { data, error } = await adminClient.storage.from(BUCKET).createSignedUrls(uniquePaths, TTL_SECONDS);
    if (error) {
      console.error("Could not sign image paths:", error.message);
      return json({ error: "Não foi possível preparar as imagens." }, 500);
    }

    const urls: Record<string, string> = {};
    for (const item of data ?? []) {
      if (item.path && item.signedUrl && !item.error) urls[item.path] = item.signedUrl;
    }

    return json({ urls, expiresAt: Date.now() + TTL_SECONDS * 1000 });
  } catch (error) {
    console.error("Image signing request failed:", error);
    return json({ error: "Pedido de imagem inválido." }, 400);
  }
});
