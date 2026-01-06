<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{ $title }}</title>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@400;500;600&family=Manrope:wght@500;700&display=swap');

        :root {
            --bg: #0c1427;
            --surface: #121c33;
            --surface-soft: #0f1729;
            --border: #1f2c44;
            --text: #e9efff;
            --muted: #a8bad8;
            --accent: #6ee7d3;
            --accent-2: #7fb7ff;
            --warning: #f5d06f;
            --shadow: 0 24px 50px rgba(4, 10, 24, 0.55);
        }

        * { box-sizing: border-box; }

        body {
            margin: 0;
            min-height: 100vh;
            font-family: 'Space Grotesk', 'Manrope', sans-serif;
            background: radial-gradient(circle at 15% 20%, rgba(126, 214, 255, 0.12), transparent 35%),
                        radial-gradient(circle at 80% 10%, rgba(111, 231, 211, 0.12), transparent 32%),
                        linear-gradient(135deg, #0a0f1f 0%, #0b1729 45%, #0b1224 100%);
            color: var(--text);
            padding: 0 20px 60px;
        }

        .page {
            max-width: 960px;
            margin: 0 auto;
            padding-top: 36px;
            animation: fadeIn 420ms ease-out;
        }

        header {
            background: linear-gradient(135deg, rgba(111, 231, 211, 0.16), rgba(127, 183, 255, 0.06)), var(--surface);
            border: 1px solid var(--border);
            border-radius: 18px;
            padding: 26px 28px;
            box-shadow: var(--shadow);
        }

        .eyebrow {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 6px 12px;
            background: rgba(255, 255, 255, 0.06);
            border: 1px solid var(--border);
            border-radius: 999px;
            color: var(--muted);
            font-size: 13px;
            letter-spacing: 0.2px;
        }

        h1 {
            margin: 12px 0 10px;
            font-size: clamp(26px, 4vw, 34px);
            letter-spacing: 0.1px;
        }

        .lede {
            margin: 0;
            max-width: 720px;
            color: var(--muted);
            line-height: 1.6;
        }

        .meta {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
            margin-top: 14px;
        }

        .meta span {
            background: rgba(255, 255, 255, 0.04);
            border: 1px solid var(--border);
            padding: 8px 12px;
            border-radius: 10px;
            font-size: 13px;
            color: var(--muted);
        }

        main {
            margin-top: 28px;
            display: grid;
            gap: 16px;
        }

        .card {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: 18px;
            padding: 22px 24px;
            box-shadow: var(--shadow);
        }

        .card.subtle {
            background: var(--surface-soft);
        }

        .card-head {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            gap: 12px;
            margin-bottom: 12px;
        }

        .card-head h2 {
            margin: 6px 0 4px;
            font-size: 20px;
        }

        .hint {
            color: var(--muted);
            font-size: 13px;
            text-align: right;
        }

        .env-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
            gap: 12px;
        }

        .env {
            padding: 14px 14px 12px;
            border: 1px solid var(--border);
            border-radius: 14px;
            background: rgba(255, 255, 255, 0.03);
        }

        .key {
            font-size: 13px;
            letter-spacing: 0.5px;
            text-transform: uppercase;
            color: var(--accent-2);
            margin-bottom: 6px;
        }

        .value {
            font-size: 16px;
            font-weight: 600;
            word-break: break-word;
        }

        .value.not-set {
            color: var(--warning);
        }

        .note {
            color: var(--muted);
            line-height: 1.5;
            margin: 6px 0 0;
        }

        .pill-list {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
            margin-top: 10px;
        }

        .pill {
            padding: 8px 12px;
            border-radius: 999px;
            border: 1px solid var(--border);
            background: rgba(255, 255, 255, 0.04);
            color: var(--text);
            font-size: 13px;
        }

        code {
            background: rgba(255, 255, 255, 0.06);
            padding: 4px 6px;
            border-radius: 6px;
            color: var(--text);
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(6px); }
            to { opacity: 1; transform: translateY(0); }
        }

        @media (max-width: 720px) {
            header, .card {
                padding: 18px 16px;
            }

            .card-head {
                flex-direction: column;
            }
        }
    </style>
</head>
<body>
    <div class="page">
        <header>
            <div class="eyebrow">Laravel demo • Public envs only</div>
            <h1>{{ $title }}</h1>
            <p class="lede">
                This page surfaces the safe, public-facing environment variables your Laravel app can share.
                Secrets stay server-side so you can demo configuration without exposing sensitive values.
            </p>
            <div class="meta">
                <span>UI driven by `{{ implode(', ', array_column($envs, 'key')) }}`</span>
                <span>JSON endpoint: <code>{{ $apiEndpoint }}</code></span>
            </div>
        </header>

        <main>
            <section class="card">
                <div class="card-head">
                    <div>
                        <div class="eyebrow">Public variables</div>
                        <h2>Visible to the browser</h2>
                    </div>
                    <div class="hint">Unset values automatically render as “Not set”.</div>
                </div>
                <div class="env-grid">
                    @foreach ($envs as $env)
                        <div class="env">
                            <div class="key">{{ $env['key'] }}</div>
                            <div class="value {{ $env['value'] === 'Not set' ? 'not-set' : '' }}">
                                {{ $env['value'] }}
                            </div>
                        </div>
                    @endforeach
                </div>
            </section>

            <section class="card subtle">
                <div class="card-head">
                    <div>
                        <div class="eyebrow">Private variables</div>
                        <h2>Kept on the server</h2>
                    </div>
                </div>
                <p class="note">
                    Database and secret keys are loaded from the environment but never sent to the browser or JSON endpoint.
                    They live only in your server process.
                </p>
                <div class="pill-list">
                    <span class="pill">DATABASE_URL</span>
                    <span class="pill">API_SECRET_KEY</span>
                </div>
            </section>
        </main>
    </div>
</body>
</html>
