# 🎨 Sistema de Geração de Histórias em Quadrinhos para Roku TV

## Visão Geral

Este sistema permite criar **cutscenes narrativas** e **histórias em quadrinhos** diretamente em BrightScript, sem necessidade de vídeos pré-renderizados. Tudo é gerado proceduralmente usando formas geométricas, animações e efeitos visuais.

## ✨ Vantagens

- **Sem arquivos de vídeo pesados** - Tudo gerado via código
- **Totalmente customizável** - Mude cores, posições, diálogos facilmente
- **Leve para Roku** - Usa apenas elementos nativos do SceneGraph
- **Fácil de expandir** - Adicione novas cenas editando JSON
- **Estilo único** - Visual artístico de quadrinhos/silhuetas

## 📁 Estrutura de Arquivos

```
pkg:/
├── source/
│   └── main.brs                    # Ponto de entrada
├── components/
│   ├── StoryboardScene.xml         # Componente principal
│   └── StoryboardScene.brs         # Lógica da cena
├── story_data.json                 # Dados das histórias (opcional)
└── images/                         # Sprites opcionais
    ├── heroi.png
    └── vilao.png
```

## 🎭 Como Funciona

### 1. Definição da História (JSON)

```json
{
  "capitulo_1": {
    "titulo": "O Despertar das Sombras",
    "cenas": [
      {
        "id": "cena_01",
        "duracao_segundos": 5,
        "fundo": {
          "tipo": "gradiente",
          "cores": ["#0f0c29", "#302b63", "#24243e"],
          "animacao": "respirar"
        },
        "personagens": [
          {
            "id": "heroi",
            "posicao_inicial": [200, 500],
            "posicao_final": [400, 500],
            "balao_fala": "Sinto uma presença antiga aqui."
          }
        ],
        "efeitos": [
          { "tipo": "particulas", "estilo": "vagalumes", "quantidade": 20 }
        ]
      }
    ]
  }
}
```

### 2. Tipos de Fundo Disponíveis

| Tipo | Descrição | Exemplo |
|------|-----------|---------|
| `gradiente` | Múltiplas cores em camadas | Céu, amanhecer, magia |
| `imagem_referencia` | Cor base + padrão procedural | Floresta, caverna, cidade |
| `solido` | Cor única | Flash, transições |

### 3. Efeitos Visuais Incluídos

- **Vagalumes** - Partículas amarelas piscantes
- **Chuva** - Linhas verticais caindo
- **Neve** - Círculos brancos descendentes
- **Poeira mágica** - Partículas coloridas flutuantes
- **Tremor de tela** - Para impactos/ameaças

### 4. Animações de Personagens

- `deslizar_suave` - Movimento linear entre pontos
- `tremer_ameaca` - Vibração intensa
- `pulsar` - Escala variável (respiração)
- `aparecer_gradual` - Fade in
- `desaparecer` - Fade out + movimento

### 5. Estilos de Balões de Fala

| Estilo | Cor de Fundo | Cor do Texto | Uso |
|--------|--------------|--------------|-----|
| `normal` | Preto semi-transparente | Branco | Diálogo comum |
| `ameacador` | Vermelho escuro | Vermelho vivo | Vilões, perigo |
| `epico` | Dourado | Preto | Revelações, narração |
| `sussurro` | Cinza claro | Cinza escuro | Segredos, memórias |

## 🚀 Uso no Seu Jogo

### Passo 1: Copiar Arquivos

```bash
cp storyboard_generator.brs components/StoryboardScene.brs
cp story_data.json pkg:/story_data.json
```

### Passo 2: Chamar do Main

```brightscript
sub Main()
    screen = CreateObject("roSGScreen")
    m.scene = screen.CreateScene("StoryboardScene")
    screen.show()
    
    storyData = LoadStoryData()
    RenderCapitulo(storyData.capitulo_1)
end sub
```

### Passo 3: Personalizar

Edite `story_data.json` com suas próprias cenas:

```json
{
  "meu_capitulo": {
    "titulo": "Minha História",
    "cenas": [
      {
        "id": "minha_cena",
        "duracao_segundos": 7,
        "fundo": {
          "tipo": "gradiente",
          "cores": ["#FF6B6B", "#4ECDC4"],
          "animacao": "respirar"
        },
        "personagens": [
          {
            "id": "meu_heroi",
            "sprite": "meu_heroi.png",
            "posicao_inicial": [100, 500],
            "posicao_final": [600, 500],
            "balao_fala": "Vamos salvar o reino!"
          }
        ]
      }
    ]
  }
}
```

## 🎨 Criando Sprites Simples

Se não tiver imagens, o sistema gera **silhuetas procedurais** automaticamente:

```brightscript
' Gera automaticamente se sprite = invalid
personagem = {
    id: "heroi",
    sprite: invalid,  ' Vai gerar silhueta preta
    posicao: [400, 500]
}
```

Ou crie sprites básicos em qualquer editor:

- **Silhueta preta** em fundo transparente (PNG)
- Tamanho recomendado: 100x150 pixels
- Formato: PNG com transparência

## 📖 Exemplo Completo - Capítulo 1

Veja o arquivo `story_data.json` para um exemplo completo de 3 cenas com:

1. **Cena de abertura** - Gradiente animado + texto épico
2. **Entrada do herói** - Personagem deslizando + vagalumes
3. **Ameaça do vilão** - Balão vermelho + fundo dramático

## 🔧 Customizações Avançadas

### Adicionar Novo Efeito

No arquivo `StoryboardScene.brs`, adicione em `RenderEfeito()`:

```brightscript
else if efeitoData.tipo = "fogo" then
    CriarFogo(efeitoData.quantidade)
```

E implemente a função:

```brightscript
sub CriarFogo(quantidade as Integer)
    for i = 0 to quantidade - 1
        particula = CreateObject("roSGNode", "Circle")
        particula.radius = 5 + Rnd(10)
        particula.color = "#FF4500"
        ' ... lógica de animação
    end for
end sub
```

### Novo Tipo de Transição

```brightscript
sub TransicaoFlashBranco()
    flash = CreateObject("roSGNode", "Rectangle")
    flash.width = 1280
    flash.height = 720
    flash.color = "#FFFFFF"
    flash.opacity = 0
    
    m.top.effectsLayer.appendChild(flash)
    
    ' Animar opacity de 0 a 1 e voltar a 0
    ' ... implementação
end sub
```

## 🎮 Controles do Usuário

- **OK** - Pular cena atual / Avançar
- **Voltar** - Cancelar (se implementado)
- **Espera automática** - Cena avança após `duracao_segundos`

## ⚡ Performance

- **60 FPS** na maioria dos dispositivos Roku
- **Memória**: ~5-10 MB dependendo da complexidade
- **Recomendações**:
  - Máximo de 50 partículas simultâneas
  - Evitar mais de 10 personagens na mesma cena
  - Usar `invalid` para sprites quando possível (gera silhuetas)

## 📝 Checklist de Criação

- [ ] Definir estrutura do capítulo em JSON
- [ ] Criar cenas com fundos apropriados
- [ ] Posicionar personagens (ou usar silhuetas)
- [ ] Escrever diálogos nos balões
- [ ] Adicionar efeitos visuais (partículas, clima)
- [ ] Testar timing de cada cena
- [ ] Adicionar transições entre cenas
- [ ] Validar em dispositivo Roku real

## 🌟 Ideias Criativas

1. **Modo Noir** - Use apenas preto, branco e cinza
2. **História Interativa** - Pause e ofereça escolhas ao jogador
3. **Flashbacks** - Use filtro sépia + bordas desfocadas
4. **Sonhos/Visões** - Cores saturadas + distorções
5. **Quadros de HQ** - Divida a tela em painéis

## 🐛 Troubleshooting

| Problema | Solução |
|----------|---------|
| Personagens não aparecem | Verifique se `posicao_inicial` está dentro da tela (0-1280, 0-720) |
| Texto cortado | Aumente `width` do `speechBubble` ou use `wrap="true"` |
| Animação travando | Reduza número de partículas ou personagens |
| Cores erradas | Verifique formato hexadecimal (#RRGGBB ou #RRGGBBAA) |

## 📚 Recursos Adicionais

- [Roku SceneGraph Documentation](https://developer.roku.com/docs/references/scenegraph.md)
- [BrightScript Language Reference](https://developer.roku.com/docs/references/brightscript.md)
- [Exemplos de Animação](https://github.com/rokucommunity/examples)

---

**Criado para Kurions — Saga Origens & A Lenda de Aether**  
*Conte sua história sem limites técnicos!*
