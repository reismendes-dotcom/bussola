// Atualiza o link da Teresa SEM palavra-passe e SEM mudar o sal (o "lembrar" dos telemóveis continua válido).
// Uso: BUSSOLA_CHAVE=<chave derivada> node ferramentas/atualizar.js <pasta-com-os-ficheiros-da-bussola>
// Requer: npm i -g staticrypt@3.5.4
const fs=require("fs"),path=require("path"),{execSync}=require("child_process");
const SR=path.join(execSync("npm root -g").toString().trim(),"staticrypt/lib");
const cryptoEngine=require(SR+"/cryptoEngine.js"),codec=require(SR+"/codec.js").init(cryptoEngine);
(async()=>{
  const src=process.argv[2],key=process.env.BUSSOLA_CHAVE,repo=path.join(__dirname,"..");
  if(!src||!key){console.error("Uso: BUSSOLA_CHAVE=... node atualizar.js <pasta>");process.exit(1)}
  let s=fs.readFileSync(path.join(src,"index.html"),"utf8");
  s=s.replace(/<script src="([^"]+)"><\/script>/g,(m,f)=>"<script>\n"+fs.readFileSync(path.join(src,f),"utf8").replace(/<\/script/g,"<\\/script")+"\n</script>");
  s=s.replace("<head>",'<head>\n<meta name="apple-mobile-web-app-capable" content="yes">\n<meta name="apple-mobile-web-app-title" content="Bússola">\n<meta name="mobile-web-app-capable" content="yes">\n<link rel="apple-touch-icon" href="icon.png">\n<link rel="icon" href="icon.png">');
  const pagina=fs.readFileSync(path.join(repo,"index.html"),"utf8");
  const m=pagina.match(/staticryptConfig = (\{.*?\});/s);if(!m)throw "config não encontrada";
  const cfg=JSON.parse(m[1]);
  const teste=await codec.decode(cfg.staticryptEncryptedMsgUniqueVariableName,key,cfg.staticryptSaltUniqueVariableName);
  if(!teste.success)throw "A chave não abre a página atual: nada foi alterado.";
  cfg.staticryptEncryptedMsgUniqueVariableName=await codec.encodeWithHashedPassword(s,key);
  fs.writeFileSync(path.join(repo,"index.html"),pagina.replace(m[1],()=>JSON.stringify(cfg)));
  const ok=await codec.decode(cfg.staticryptEncryptedMsgUniqueVariableName,key,cfg.staticryptSaltUniqueVariableName);
  console.log(ok.success?"Página encriptada e verificada.":"ERRO na verificação");if(!ok.success)process.exit(2);
})().catch(e=>{console.error(String(e));process.exit(1)});
