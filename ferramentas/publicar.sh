#!/bin/bash
# Atualiza o link da Teresa: https://reismendes-dotcom.github.io/bussola/  (automático, sem palavra-passe)
# Uso: BUSSOLA_CHAVE='<chave derivada>' ferramentas/publicar.sh <pasta-com-os-ficheiros-da-bussola>
set -e
REPO="$(cd "$(dirname "$0")/.." && pwd)"
node "$REPO/ferramentas/atualizar.js" "$1"
cd "$REPO" && git add -A && git -c user.name="reismendes-dotcom" -c user.email="reismendes-dotcom@users.noreply.github.com" commit -qm "Atualização da Bússola" && git push -q
echo "Publicado."
