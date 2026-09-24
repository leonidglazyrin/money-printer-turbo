#!/bin/sh
# Entrypoint for the Hugging Face Docker Space.
# Injects the Space secrets (PEXELS_API_KEY, KIMI_API_KEY) into config.toml
# on every container start, then launches the Streamlit WebUI on port 7860.
set -e

cd /MoneyPrinterTurbo

if [ ! -f config.toml ]; then
  cp config.example.toml config.toml
fi

python3 - <<'EOF'
import os
import re

path = "config.toml"
with open(path, "r", encoding="utf-8") as f:
    text = f.read()

def set_toml(key, value):
    global text
    pattern = re.compile(rf"^{re.escape(key)}\s*=.*$", re.M)
    replacement = f"{key} = {value}"
    if pattern.search(text):
        text = pattern.sub(replacement, text)
    else:
        text += f"\n{replacement}\n"

pexels = os.environ.get("PEXELS_API_KEY", "").strip()
if pexels:
    set_toml("pexels_api_keys", f'["{pexels}"]')

kimi = os.environ.get("KIMI_API_KEY", "").strip()
if kimi:
    set_toml("moonshot_api_key", f'"{kimi}"')
    set_toml("llm_provider", '"moonshot"')

with open(path, "w", encoding="utf-8") as f:
    f.write(text)

print("config.toml prepared (keys injected from environment)")
EOF

exec streamlit run ./webui/Main.py \
  --server.address=0.0.0.0 \
  --server.port=7860 \
  --server.enableCORS=True \
  --browser.gatherUsageStats=False \
  --client.toolbarMode=minimal \
  --logger.hideWelcomeMessage=True \
  --server.showEmailPrompt=False
