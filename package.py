"""
Script para empacotar a aplicacao Roku em um arquivo .zip pronto para instalacao (sideload).
"""

import os
import zipfile

OUTPUT_ZIP = "kurions_saga_origens.zip"

ITEMS_TO_INCLUDE = [
    "manifest",
    "source",
    "components",
    "images",
    "data"
]

def create_package():
    if os.path.exists(OUTPUT_ZIP):
        os.remove(OUTPUT_ZIP)

    print(f"[*] Criando pacote {OUTPUT_ZIP}...")
    with zipfile.ZipFile(OUTPUT_ZIP, "w", zipfile.ZIP_DEFLATED) as zf:
        for item in ITEMS_TO_INCLUDE:
            if os.path.isfile(item):
                zf.write(item, arcname=item)
                print(f"  + {item}")
            elif os.path.isdir(item):
                for root, _, files in os.walk(item):
                    for file in files:
                        full_path = os.path.join(root, file)
                        arcname = os.path.relpath(full_path, start=".")
                        zf.write(full_path, arcname=arcname)
                        print(f"  + {arcname}")

    size_kb = os.path.getsize(OUTPUT_ZIP) / 1024
    print(f"\n[OK] Pacote gerado com sucesso: {OUTPUT_ZIP} ({size_kb:.1f} KB)")
    print("Agora voce pode instalar esse arquivo .zip diretamente na sua Roku TV!")

if __name__ == "__main__":
    create_package()
