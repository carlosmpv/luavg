#!/usr/bin/env bash

# Uso: ./watch.sh caminho/para/script.lua

set -euo pipefail

if [ $# -lt 1 ]; then
    echo "Uso: $0 <arquivo.lua>" >&2
    exit 1
fi

ARQUIVO="$1"

if [ ! -f "$ARQUIVO" ]; then
    echo "Erro: arquivo '$ARQUIVO' não encontrado." >&2
    exit 1
fi

if ! command -v fswatch >/dev/null 2>&1; then
    echo "Erro: 'fswatch' não está instalado." >&2
    exit 1
fi

if ! command -v lua >/dev/null 2>&1; then
    echo "Erro: 'lua' não está instalado." >&2
    exit 1
fi

echo "Observando '$ARQUIVO' (Ctrl+C para sair)..."

# Roda uma vez no início (opcional — remova se não quiser)
luajit "$ARQUIVO"

fswatch -o "$ARQUIVO" | while read -r _; do
    echo "--- Executando $ARQUIVO ---"
    luajit "$ARQUIVO"
done