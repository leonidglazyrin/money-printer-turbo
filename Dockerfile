# Dockerfile for the Hugging Face Docker Space (port 7860).
# Secrets (PEXELS_API_KEY, KIMI_API_KEY) are injected into config.toml
# by entrypoint.sh from the Space's Repository secrets.
FROM python:3.11-slim-bullseye

WORKDIR /MoneyPrinterTurbo

RUN chmod 777 /MoneyPrinterTurbo

ENV PYTHONPATH="/MoneyPrinterTurbo"

RUN apt-get update && \
    apt-get install -y --no-install-recommends git ffmpeg && \
    rm -rf /var/lib/apt/lists/*

COPY requirements.txt ./
RUN pip install --no-cache-dir --retries 3 --timeout 60 -r requirements.txt

COPY . .

RUN chmod +x entrypoint.sh

EXPOSE 7860

CMD ["./entrypoint.sh"]
