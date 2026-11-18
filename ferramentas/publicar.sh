#!/bin/bash
# Atualiza o link da Teresa: https://reismendes-dotcom.github.io/bussola/
# Uso: BUSSOLA_PW='...' ferramentas/publicar.sh <pasta-com-os-ficheiros-da-bussola>
#   A pasta tem index.html, conteudo*.js, vida.js, ceu.js (os mesmos ficheiros do artefacto Claude).
#   A palavra-passe NUNCA fica guardada: só entra pela variável BUSSOLA_PW.
# Requer: npm i -g staticrypt@3.5.4
set -e
SRC="$(cd "$1" && pwd)"; REPO="$(cd "$(dirname "$0")/.." && pwd)"; TMP="$(mktemp -d)"
[ -n "$BUSSOLA_PW" ] || { echo "Falta BUSSOLA_PW"; exit 1; }
cd "$SRC" && python3 - "$TMP/bundle.html" <<'PY'
import re,sys
s=open('index.html').read()
s=re.sub(r'<script src="([^"]+)"></script>',lambda m:'<script>\n'+open(m.group(1)).read().replace('</script','<\\/script')+'\n</script>',s)
s=s.replace('<head>','<head>\n<meta name="apple-mobile-web-app-capable" content="yes">\n<meta name="apple-mobile-web-app-title" content="Bússola">\n<meta name="mobile-web-app-capable" content="yes">\n<link rel="apple-touch-icon" href="icon.png">\n<link rel="icon" href="icon.png">',1)
open(sys.argv[1],'w').write(s)
PY
cd "$TMP" && staticrypt bundle.html -p "$BUSSOLA_PW" --short --remember 3650 -d out --template-title "Bússola da Família Mendes" --template-instructions "Escreve a palavra-passe da família." --template-placeholder "Palavra-passe" --template-button "Abrir" --template-remember "Lembrar neste aparelho" --template-error "Palavra-passe errada." --template-color-primary "#0e6b70" --template-color-secondary "#f4f5f7"
sed "s|<input id=\"staticrypt-remember\" type=\"checkbox\" name=\"remember\" />|<input id=\"staticrypt-remember\" type=\"checkbox\" name=\"remember\" checked />|" out/bundle.html > "$REPO/index.html"
cd "$REPO" && git add -A && git -c user.name="reismendes-dotcom" -c user.email="reismendes-dotcom@users.noreply.github.com" commit -qm "Atualização da Bússola" && git push -q
echo "Publicado."
