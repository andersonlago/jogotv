"""
Script para enviar (sideload) a aplicacao diretamente para a Roku TV via rede local.
Uso:
    python deploy.py --ip 192.168.X.X --password SUA_SENHA
"""

import argparse
import io
import mimetypes
import os
import sys
import urllib.request
from package import OUTPUT_ZIP, create_package

def encode_multipart_formdata(fields, files):
    boundary = "----RokuUploaderBoundary123456789"
    body = io.BytesIO()

    for key, value in fields.items():
        body.write(f"--{boundary}\r\n".encode("utf-8"))
        body.write(f'Content-Disposition: form-data; name="{key}"\r\n\r\n'.encode("utf-8"))
        body.write(f"{value}\r\n".encode("utf-8"))

    for key, (filename, file_bytes) in files.items():
        mime_type = mimetypes.guess_type(filename)[0] or "application/octet-stream"
        body.write(f"--{boundary}\r\n".encode("utf-8"))
        body.write(f'Content-Disposition: form-data; name="{key}"; filename="{filename}"\r\n'.encode("utf-8"))
        body.write(f"Content-Type: {mime_type}\r\n\r\n".encode("utf-8"))
        body.write(file_bytes)
        body.write(b"\r\n")

    body.write(f"--{boundary}--\r\n".encode("utf-8"))
    content_type = f"multipart/form-data; boundary={boundary}"
    return content_type, body.getvalue()

def deploy_to_roku(ip, password):
    create_package()

    url = f"http://{ip}/plugin_install"
    print(f"\n[*] Conectando a Roku TV em {url}...")

    # Configuracao de autenticacao Digest (padrao da Roku)
    password_mgr = urllib.request.HTTPPasswordMgrWithDefaultRealm()
    password_mgr.add_password(None, url, "rokudev", password)
    handler = urllib.request.HTTPDigestAuthHandler(password_mgr)
    opener = urllib.request.build_opener(handler)

    with open(OUTPUT_ZIP, "rb") as f:
        zip_bytes = f.read()

    fields = {
        "mysubmit": "Install",
        "archive": ""
    }
    files = {
        "archive": (OUTPUT_ZIP, zip_bytes)
    }

    content_type, body = encode_multipart_formdata(fields, files)

    req = urllib.request.Request(url, data=body, method="POST")
    req.add_header("Content-Type", content_type)

    try:
        with opener.open(req, timeout=30) as response:
            html = response.read().decode("utf-8", errors="ignore")
            if "Identical to previous build" in html:
                print("[!] Aviso: O pacote instalado e identico ao anterior.")
            elif "Install Success" in html or "Application Installed" in html:
                print("[OK] SUCESSO: Aplicativo instalado e iniciado na Roku TV!")
            else:
                print("[OK] Requisicao concluida. Verifique a tela da sua TV.")
    except urllib.error.HTTPError as e:
        err_body = e.read().decode("utf-8", errors="ignore")
        if e.code == 401:
            print("[ERRO] Erro 401: Senha de desenvolvedor incorreta!")
        else:
            print(f"[ERRO] Erro HTTP {e.code}: {e.reason}")
            if err_body:
                print(f"[Detalhes do Erro da TV]: {err_body[:500]}")
    except Exception as e:
        print(f"[ERRO] Falha de conexao: {e}")
        print("Dica: Certifique-se de que a Roku TV esta ligada, na mesma rede Wi-Fi e com o Modo Desenvolvedor ativo.")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Instalador automatico para Roku TV")
    parser.add_argument("--ip", help="Endereco IP da sua Roku TV (ex: 192.168.1.100)")
    parser.add_argument("--password", help="Senha do Modo Desenvolvedor configurada na TV")
    args = parser.parse_args()

    if not args.ip or not args.password:
        print("Uso: python deploy.py --ip <IP_DA_TV> --password <SENHA>")
        print("Exemplo: python deploy.py --ip 192.168.0.50 --password 1234")
        sys.exit(1)

    deploy_to_roku(args.ip, args.password)
