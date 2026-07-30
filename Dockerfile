# ==========================================
# Etapa 1: Compilación de Spotatui (Rust)
# ==========================================
FROM rust:alpine AS builder

RUN apk add --no-cache \
    musl-dev \
    libssl3 \
    openssl-dev \
    pkgconfig \
    build-base \
    perl \
    alsa-lib-dev \
    pulseaudio-dev \
    eudev-dev

# Desactivamos el enlazado estático forzado de musl
ENV RUSTFLAGS="-C target-feature=-crt-static"

# Instalamos spotatui de forma estándar (el audio ya viene incluido por defecto)
RUN cargo install spotatui

# ==========================================
# Etapa 2: Imagen Final (Alpine + Audio + YouTube + Spotify)
# ==========================================
FROM alpine:latest

# 1. Dependencias de sistema, audio y reproductores
RUN apk add --no-cache \
    libgcc \
    libssl3 \
    ca-certificates \
    bash \
    curl \
    jq \
    fzf \
    ncurses \
    mpv \
    yt-dlp \
    alsa-lib \
    alsa-utils \
    pulseaudio \
    pulseaudio-utils \
    strace

# 2. Instalar ytfzf (interfaz de terminal para buscar en YouTube)
RUN curl -sL https://raw.githubusercontent.com/pystardust/ytfzf/master/ytfzf -o /usr/local/bin/ytfzf && \
    chmod +x /usr/local/bin/ytfzf

# 3. Copiar Spotatui desde la etapa de compilación
COPY --from=builder /usr/local/cargo/bin/spotatui /usr/local/bin/spotatui

# 4. Configurar usuario no-root alineado con el UID 1000 de WSL
RUN addgroup -g 1000 -S music && \
    adduser -u 1000 -S music -G music && \
    addgroup music audio

# Creamos las carpetas dentro del home de music
RUN mkdir -p /home/music/.config/spotatui \
             /home/music/.config/ytfzf \
             /home/music/.cache \
             /home/music/.local/state/spotatui_logs && \
    chown -R music:music /home/music && \
    chmod -R 755 /home/music

USER music
WORKDIR /home/music

# Configurar ytfzf para que solo reproduzca AUDIO por defecto
RUN echo "is_audio_only=1" > /home/music/.config/ytfzf/conf.sh

ENTRYPOINT ["/bin/bash"]