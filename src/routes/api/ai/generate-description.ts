import { createFileRoute } from "@tanstack/react-router";
import { createClient } from "@supabase/supabase-js";

const ADMIN_EMAIL = "info.parrotdesign@gmail.com";
const SUPABASE_URL = "https://agpxxmyypbnxnajdwmws.supabase.co";
const SUPABASE_PUBLISHABLE_KEY = "sb_publishable_87OiyND52hQkmb9rfTzslw_keDirei4";

type DescriptionRequest = {
  kind?: "product" | "service";
  name?: string;
  category?: string;
  details?: string;
};

function json(body: unknown, status = 200) {
  return Response.json(body, {
    status,
    headers: { "Cache-Control": "no-store" },
  });
}

function extractText(content: unknown): string {
  if (typeof content === "string") return content;
  if (Array.isArray(content)) {
    return content
      .map((part) =>
        typeof part === "string"
          ? part
          : part && typeof part === "object" && "text" in part
            ? String((part as { text?: unknown }).text ?? "")
            : "",
      )
      .join("");
  }
  return "";
}

export const Route = createFileRoute("/api/ai/generate-description")({
  server: {
    handlers: {
      POST: async ({ request }) => {
        try {
          const authorization = request.headers.get("authorization") ?? "";
          const accessToken = authorization.replace(/^Bearer\s+/i, "").trim();
          if (!accessToken) return json({ error: "Sessão administrativa necessária." }, 401);

          const supabaseUrl = process.env['VITE_SUPABASE_URL'] || SUPABASE_URL;
          const supabaseKey =
            process.env['VITE_SUPABASE_PUBLISHABLE_KEY'] || SUPABASE_PUBLISHABLE_KEY;
          const supabase = createClient(supabaseUrl, supabaseKey, {
            auth: { persistSession: false, autoRefreshToken: false },
          });
          const { data: userData, error: userError } = await supabase.auth.getUser(accessToken);
          if (userError || userData.user?.email?.toLowerCase() !== ADMIN_EMAIL) {
            return json({ error: "Apenas o administrador autorizado pode usar a geração por IA." }, 403);
          }

          const body = (await request.json()) as DescriptionRequest;
          const kind = body.kind === "service" ? "serviço" : "produto";
          const name = String(body.name ?? "").trim().slice(0, 180);
          const category = String(body.category ?? "").trim().slice(0, 120);
          const details = String(body.details ?? "").trim().slice(0, 4000);

          if (!name) return json({ error: "Informe o nome do produto ou serviço." }, 400);
          if (!details && !category) {
            return json({ error: "Forneça alguns detalhes para a IA trabalhar." }, 400);
          }

          const apiKey = process.env['LOVABLE_API_KEY'];
          if (!apiKey) {
            return json(
              {
                error:
                  "O AI Gateway não está configurado no ambiente do servidor. Adicione a variável secreta LOVABLE_API_KEY no projeto.",
              },
              503,
            );
          }

          const prompt = [
            "Escreva uma descrição comercial curta, clara e apelativa em português usado em Moçambique.",
            "O texto será mostrado no catálogo de uma empresa de design gráfico e soluções criativas.",
            "Não invente características, materiais, medidas, preços, prazos, garantias ou benefícios que não estejam nos dados fornecidos.",
            "Evite exageros, clichés e linguagem genérica de IA. Priorize clareza, confiança e utilidade para o cliente.",
            "Entregue apenas a descrição final, sem título, aspas, bullets ou explicações.",
            "",
            "Tipo: " + kind,
            "Nome: " + name,
            category ? "Categoria/área: " + category : "",
            details ? "Detalhes fornecidos pelo administrador: " + details : "",
          ]
            .filter(Boolean)
            .join("\n");

          const gatewayResponse = await fetch(
            "https://ai.gateway.lovable.dev/v1/chat/completions",
            {
              method: "POST",
              headers: {
                Authorization: "Bearer " + apiKey,
                "Lovable-API-Key": apiKey,
                "Content-Type": "application/json",
              },
              body: JSON.stringify({
                model: "google/gemini-3.7-flash",
                messages: [
                  {
                    role: "system",
                    content:
                      "Você é um redator comercial especializado em catálogos profissionais. Escreva em português de Moçambique.",
                  },
                  { role: "user", content: prompt },
                ],
                temperature: 0.7,
                max_tokens: 220,
              }),
            },
          );

          if (!gatewayResponse.ok) {
            const errorText = await gatewayResponse.text();
            console.error("Lovable AI Gateway error:", gatewayResponse.status, errorText);
            return json(
              {
                error:
                  gatewayResponse.status === 402
                    ? "O AI Gateway não tem créditos disponíveis neste momento."
                    : "Não foi possível gerar a descrição com IA. Tente novamente.",
              },
              gatewayResponse.status === 429 ? 429 : 502,
            );
          }

          const result = (await gatewayResponse.json()) as {
            choices?: Array<{ message?: { content?: unknown } }>;
          };
          const description = extractText(result.choices?.[0]?.message?.content)
            .replace(/^["“”]+|["“”]+$/g, "")
            .trim();

          if (!description) {
            return json({ error: "A IA não devolveu uma descrição válida." }, 502);
          }

          return json({ description });
        } catch (error) {
          console.error("AI description generation failed:", error);
          return json(
            { error: error instanceof Error ? error.message : "Não foi possível gerar a descrição." },
            500,
          );
        }
      },
    },
  },
});
