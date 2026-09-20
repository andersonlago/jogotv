# 💎 KURIONS — SAGA ORIGENS & A LENDA DE AETHER (Roku TV)

Aplicação completa desenvolvida exclusivamente para **Roku TV** utilizando **Roku SceneGraph (RSG)** e **BrightScript**. Combina uma experiência de série animada interativa e um jogo de aventura e RPG em masmorras estilo Zelda 2D com **40 fases completas**!

Classificação Indicativa: **Recomendado para 10 anos**  
Gênero: **Aventura, Fantasia & RPG**  
Resolução: **Full HD (1080p) e 4K**  
Repositório: **https://github.com/andersonlago/jogotv.git**

---

## 🌟 1. Visão Geral da Aplicação

- **Série Animada Interativa**: Assista aos episódios da protagonista **Koli** e seu fiel companheiro **Pagonix**, navegando com controle remoto em uma interface imersiva.
- **Jogo de Aventura RPG — "A Lenda de Aether" (40 Fases)**:
  - Jogue diretamente pelo controle remoto da Roku TV.
  - 8 Capítulos / Biomas de Aether (5 fases por capítulo):
    1. *O Bosque das Origens & Ruínas Rúnicas* (Mini-chefe: Guardião Corrompido da Floresta)
    2. *As Minas de Quartzo & Vale dos Cristais* (Mini-chefe: Golem Titânico de Cristal)
    3. *A Frota Aérea & O Grande Dirigível* (Mini-chefe: Capitão da Dark Team)
    4. *As Ilhas Flutuantes de Zéfiro* (Mini-chefe: Serpente dos Ventos)
    5. *As Forjas de Magma & Criptas Vulcânicas* (Mini-chefe: Colosso de Magma)
    6. *O Abismo das Águas Ancestrais* (Mini-chefe: Leviatã Abissal)
    7. *A Fortaleza Celestial da Dark Team* (Mini-chefe: General Supremo)
    8. *O Vórtice Cósmico & Santuário Supremo* (Grande Batalha Final contra o Vórtice Sombrio Primordial e convocação de Chalicrfax!)
  - **Mecânicas**: Combate com feixe de luz do Colar, Escudo protetor de cristal de Pagonix, quebra-cabeças de interruptores, resgate de Kurions bebês, armadilhas de espinhos e Lojinha de Upgrades de Aether.
  - **Checkpoints**: Salvamento persistente da maior fase alcançada no registro da TV (`roRegistrySection`).

---

## 🎮 2. Navegação no Controle Remoto Roku

### Navegação Geral & Player de Vídeo
| Botão do Controle | Ação |
| :--- | :--- |
| **▲ / ▼ (Cima / Baixo)** | Navega entre as opções do menu lateral |
| **◀ / ▶ (Esquerda / Direita)** | Alterna entre cards de episódios, personagens e Kurions |
| **OK / Play** | Seleciona item / Reproduz vídeo |
| **BACK** | Retorna ao menu ou fecha o vídeo salvando progresso |
| **◀◀ / ▶▶** | Retrocede ou avança 15 segundos no vídeo |

### Controles no Jogo ("A Lenda de Aether")
| Botão do Controle | Ação no Jogo |
| :--- | :--- |
| **▲ ▼ ◀ ▶ (D-Pad)** | Movimenta Koli pela masmorra. Pagonix a segue |
| **OK** | Dispara o **Feixe de Luz do Colar do Começo** (ataque e interação à distância) |
| **↺ (Replay) ou Play** | Ativa o **Casco Protetor de Cristal** do Pagonix (invulnerabilidade temporária e repulsão) |
| **✱ (Opções / Info)** | Abre a **Lojinha de Aether do Grande Dirigível** (+Vida Máxima, Alcance Nível 2 e Poções) |
| **>> (FastForward)** | Avança para a próxima fase (atalho rápido de teste) |
| **<< (Rewind)** | Volta para a fase anterior |
| **BACK** | Pausa o jogo e retorna à barra de navegação da série |

---

## 📁 3. Estrutura do Projeto

```text
roku/
├── manifest                     # Metadados oficiais do canal Roku
├── source/
│   ├── main.brs                 # Inicialização SceneGraph e loop de eventos
│   ├── Storage.brs              # Persistência com roRegistrySection (vídeo e jogo)
│   ├── DataManager.brs          # Abstração de dados e JSON
│   └── API.brs                  # API client
├── components/
│   ├── MainScene.xml            # Interface visual SceneGraph, HUD, nós de vídeo e grade
│   └── MainScene.brs            # Lógica do app, controle remoto e engine das 40 fases
├── data/
│   ├── episodes.json            # Catálogo de episódios
│   ├── characters.json          # Fichas dos personagens
│   ├── kurions.json             # Fichas dos Kurions e habilidades
│   ├── lore.json                # História e segredos do Dirigível
│   └── subtitles/               # Legendas VTT em português
├── images/
│   ├── icon_fhd.png             # Ícone oficial do canal na TV (540x405)
│   ├── splash_fhd.png           # Splash screen Full HD (1920x1080)
│   ├── game/                    # Sprites de personagens, monstros e tiles do jogo
│   ├── characters/              # Cards ilustrados dos personagens
│   ├── kurions/                 # Ilustrações temáticas de Kurions
│   ├── episodes/                # Thumbnails Full HD dos episódios
│   └── lore/                    # Arte do Colar e Dirigível
├── package.py                   # Script para gerar pacote ZIP
├── deploy.py                    # Script de instalação automática na Roku TV
├── instalar_na_tv.bat           # Executável de 1 clique para Windows
└── README.md
```

---

## 🚀 4. Como Executar e Atualizar na Roku TV

### Instalação Automática (Windows)
Basta dar duplo clique em `instalar_na_tv.bat` ou executar no terminal:
```bash
python deploy.py --ip 192.168.0.109 --password rokutv
```

### Instalação Manual pelo Navegador Web
1. Acesse o IP da TV no navegador: `http://192.168.0.109`
2. Usuário: `rokudev` | Senha: `rokutv`
3. Selecione o pacote gerado por `python package.py` e clique em **Install**.
