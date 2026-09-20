' BrightScript - Storyboard/Comic Generator for Roku TV
' Gera histórias em formato de quadrinhos/cutscenes usando apenas código BrightScript
' Sem necessidade de vídeos pré-renderizados

' ============================================
' STORYBOARD ENGINE - Sistema de Narrativa Visual
' ============================================

sub Main()
    screen = CreateObject("roSGScreen")
    m.scene = screen.CreateScene("StoryboardScene")
    screen.show()
    
    ' Carregar dados da história
    storyData = LoadStoryData()
    
    ' Renderizar capítulo 1
    RenderCapitulo(storyData.capitulo_1)
end sub

' ============================================
' COMPONENTE: StoryboardScene
' ============================================
' Arquivo: components/StoryboardScene.xml

<?xml version="1.0" encoding="utf-8" ?>
<component name="StoryboardScene" extends="Scene">
    <interface>
        <field id="currentScene" type="node" />
        <field id="storyData" type="assocarray" />
        <field id="isPlaying" type="boolean" value="false" />
    </interface>
    
    <children>
        <!-- Fundo Dinâmico -->
        <Rectangle id="background" width="1280" height="720" color="#000000">
            <Timer id="bgAnimationTimer" repeat="true" duration="0.05" />
        </Rectangle>
        
        <!-- Camada de Partículas/Efeitos -->
        <Group id="effectsLayer" />
        
        <!-- Personagens -->
        <Group id="characterLayer" />
        
        <!-- Balões de Fala e Texto -->
        <Group id="dialogueLayer">
            <Rectangle id="speechBubble" width="600" height="120" color="#00000099" opacity="0.9">
                <Label id="speechText" width="560" height="80" 
                       text="" 
                       font="font:LargeBoldSystemFont" 
                       color="#FFFFFF" 
                       horizAlign="center" 
                       vertAlign="center"
                       wrap="true" />
            </Rectangle>
        </Group>
        
        <!-- Elementos de Cena (formas, textos decorativos) -->
        <Group id="sceneElementsLayer" />
        
        <!-- Controles de Navegação -->
        <Rectangle id="controlsOverlay" width="1280" height="720" opacity="0">
            <Label id="skipHint" text="Pressione OK para pular" 
                   font="font:SmallSystemFont" 
                   color="#CCCCCC" 
                   translation="[1100, 680]" />
        </Rectangle>
    </children>
    
    <script type="text/brightscript" uri="pkg:/components/StoryboardScene.brs" />
</component>

' ============================================
' SCRIPT: StoryboardScene.brs
' ============================================

sub Init()
    m.top.background = m.scene.findNode("background")
    m.top.effectsLayer = m.scene.findNode("effectsLayer")
    m.top.characterLayer = m.scene.findNode("characterLayer")
    m.top.dialogueLayer = m.scene.findNode("dialogueLayer")
    m.top.speechBubble = m.scene.findNode("speechBubble")
    m.top.speechText = m.scene.findNode("speechText")
    m.top.sceneElementsLayer = m.scene.findNode("sceneElementsLayer")
    m.top.controlsOverlay = m.scene.findNode("controlsOverlay")
    
    m.currentSceneIndex = 0
    m.scenes = []
    m.isPlaying = false
    
    ' Configurar timer de animação de fundo
    m.bgTimer = m.scene.findNode("bgAnimationTimer")
    m.bgTimer.observeField("fire", "onBackgroundAnimation")
    
    ' Observar controles remotos
    m.scene.observeField("wasBackButtonPressed", "onBackPressed")
end sub

sub RenderCapitulo(capituloData as Object)
    m.top.storyData = capituloData
    m.scenes = capituloData.cenas
    m.currentSceneIndex = 0
    m.isPlaying = true
    
    RenderScene(m.scenes[m.currentSceneIndex])
end sub

sub RenderScene(cena as Object)
    ' Limpar camada anterior
    ClearLayers()
    
    ' Renderizar fundo
    RenderFundo(cena.fundo)
    
    ' Renderizar elementos da cena
    if cena.elementos <> invalid then
        for each elemento in cena.elementos
            RenderElemento(elemento)
        end for
    end if
    
    ' Renderizar personagens
    if cena.personagens <> invalid then
        for each personagem in cena.personagens
            RenderPersonagem(personagem)
        end for
    end if
    
    ' Renderizar efeitos
    if cena.efeitos <> invalid then
        for each efeito in cena.efeitos
            RenderEfeito(efeito)
        end for
    end if
    
    ' Mostrar balão de fala se existir
    if cena.balao_fala <> invalid then
        MostrarBalaoFala(cena.balao_fala)
    end if
    
    ' Agendar próxima cena
    m.sceneTimer = CreateObject("roSGNode", "Timer")
    m.sceneTimer.duration = cena.duracao_segundos
    m.sceneTimer.repeat = false
    m.sceneTimer.observeField("fire", "onSceneTimer")
    m.sceneTimer.control = "start"
end sub

sub RenderFundo(fundoData as Object)
    bg = m.top.background
    
    if fundoData.tipo = "gradiente" then
        ' Simular gradiente com múltiplos retângulos
        cores = fundoData.cores
        alturaCada = 720 / cores.Count()
        
        for i = 0 to cores.Count() - 1
            rect = CreateObject("roSGNode", "Rectangle")
            rect.width = 1280
            rect.height = alturaCada
            rect.color = cores[i]
            rect.translation = [0, i * alturaCada]
            m.top.backgroundGroup.appendChild(rect)
        end for
        
        ' Animar gradiente se especificado
        if fundoData.animacao <> invalid then
            IniciarAnimacaoFundo(fundoData.animacao)
        end if
        
    else if fundoData.tipo = "imagem_referencia" then
        ' Usar cor base + padrões gerados proceduralmente
        bg.color = fundoData.cor_base
        
        ' Gerar padrão de floresta sombria proceduralmente
        if fundoData.detalhes = "floresta_sombria" then
            GerarPadraoFloresta()
        end if
    end if
end sub

sub GerarPadraoFloresta()
    ' Criar árvores estilizadas usando formas geométricas
    numArvores = 15
    
    for i = 0 to numArvores - 1
        x = Rnd(1280)
        altura = 200 + Rnd(300)
        
        ' Tronco
        tronco = CreateObject("roSGNode", "Rectangle")
        tronco.width = 20 + Rnd(10)
        tronco.height = altura
        tronco.color = "#3d2817"
        tronco.translation = [x, 720 - altura]
        m.top.characterLayer.appendChild(tronco)
        
        ' Copa da árvore (triângulo simulado com polígono)
        copa = CreateObject("roSGNode", "Polygon")
        copa.points = "[[0,0],[40,-60],[80,0]]"
        copa.color = "#1a472a"
        copa.translation = [x - 30, 720 - altura - 10]
        m.top.characterLayer.appendChild(copa)
    end for
end sub

sub RenderPersonagem(personagemData as Object)
    grupoPersonagem = CreateObject("roSGNode", "Group")
    
    ' Carregar ou gerar sprite do personagem
    if personagemData.sprite <> invalid then
        poster = CreateObject("roSGNode", "Poster")
        poster.uri = "pkg:/images/" + personagemData.sprite
        poster.width = 100
        poster.height = 150
        grupoPersonagem.appendChild(poster)
    else
        ' Gerar silhouette proceduralmente
        GerarSilhuetaPersonagem(grupoPersonagem)
    end if
    
    grupoPersonagem.translation = personagemData.posicao_inicial
    
    ' Armazenar dados para animação
    grupoPersonagem.id = personagemData.id
    grupoPersonagem.m_finalPos = personagemData.posicao_final
    grupoPersonagem.m_animacao = personagemData.animacao
    
    m.top.characterLayer.appendChild(grupoPersonagem)
    
    ' Iniciar animação se houver movimento
    if personagemData.posicao_final <> invalid then
        AnimarPersonagem(grupoPersonagem)
    end if
    
    ' Mostrar balão de fala do personagem
    if personagemData.balao_fala <> invalid then
        MostrarBalaoFala({
            texto: personagemData.balao_fala,
            origem: personagemData.id,
            estilo: "normal"
        })
    end if
end sub

sub GerarSilhuetaPersonagem(grupo as Object)
    ' Cabeça
    cabeca = CreateObject("roSGNode", "Circle")
    cabeca.radius = 25
    cabeca.color = "#000000"
    cabeca.translation = [50, 25]
    grupo.appendChild(cabeca)
    
    ' Corpo
    corpo = CreateObject("roSGNode", "Rectangle")
    corpo.width = 60
    corpo.height = 80
    corpo.color = "#000000"
    corpo.translation = [20, 60]
    grupo.appendChild(corpo)
    
    ' Pernas
    pernaEsq = CreateObject("roSGNode", "Rectangle")
    pernaEsq.width = 20
    pernaEsq.height = 45
    pernaEsq.color = "#000000"
    pernaEsq.translation = [25, 150]
    grupo.appendChild(pernaEsq)
    
    pernaDir = CreateObject("roSGNode", "Rectangle")
    pernaDir.width = 20
    pernaDir.height = 45
    pernaDir.color = "#000000"
    pernaDir.translation = [55, 150]
    grupo.appendChild(pernaDir)
end sub

sub AnimarPersonagem(personagem as Object)
    m.animTimer = CreateObject("roSGNode", "Timer")
    m.animTimer.duration = 0.03
    m.animTimer.repeat = true
    m.animTimer.observeField("fire", "onCharacterAnimation")
    m.animTimer.control = "start"
    
    m.personagemAnimando = personagem
    m.animProgresso = 0
end sub

sub onCharacterAnimation(event as Object)
    if m.personagemAnimando = invalid then return
    
    m.animProgresso += 0.02
    
    posInicial = m.personagemAnimando.translation
    posFinal = m.personagemAnimando.m_finalPos
    
    novaX = posInicial[0] + (posFinal[0] - posInicial[0]) * m.animProgresso
    novaY = posInicial[1] + (posFinal[1] - posInicial[1]) * m.animProgresso
    
    m.personagemAnimando.translation = [novaX, novaY]
    
    if m.animProgresso >= 1 then
        m.animTimer.control = "stop"
        m.animTimer = invalid
    end if
end sub

sub RenderEfeito(efeitoData as Object)
    if efeitoData.tipo = "particulas" then
        if efeitoData.estilo = "vagalumes" then
            CriarVagalumes(efeitoData.quantidade)
        end if
    else if efeitoData.tipo = "chuva" then
        CriarChuva()
    else if efeitoData.tipo = "neve" then
        CriarNeve()
    end if
end sub

sub CriarVagalumes(quantidade as Integer)
    for i = 0 to quantidade - 1
        vagaLume = CreateObject("roSGNode", "Circle")
        vagaLume.radius = 3 + Rnd(2)
        vagaLume.color = "#FFFF00"
        vagaLume.opacity = 0.3 + Rnd(0.5)
        
        x = Rnd(1280)
        y = Rnd(720)
        vagaLume.translation = [x, y]
        
        ' Animar piscar
        timerPiscar = CreateObject("roSGNode", "Timer")
        timerPiscar.duration = 0.5 + Rnd(1)
        timerPiscar.repeat = true
        timerPiscar.id = "piscar_" + i.ToStr()
        timerPiscar.observeField("fire", "onPiscarVagalume")
        timerPiscar.control = "start"
        
        vagaLume.id = "vagalume_" + i.ToStr()
        vagaLume.m_timer = timerPiscar
        
        m.top.effectsLayer.appendChild(vagaLume)
    end for
end sub

sub onPiscarVagalume(event as Object)
    timerId = event.GetRoSGNode().id
    vagaLumeId = "vagalume_" + timerId.Split("_")[1]
    vagaLume = m.top.effectsLayer.findNode(vagaLumeId)
    
    if vagaLume <> invalid then
        novaOpacidade = 0.3 + Rnd(0.5)
        vagaLume.opacity = novaOpacidade
    end if
end sub

sub MostrarBalaoFala(balaoData as Object)
    bubble = m.top.speechBubble
    texto = m.top.speechText
    
    bubble.visible = true
    texto.text = balaoData.texto
    
    ' Posicionar baseado na origem
    if balaoData.origem <> invalid then
        personagem = m.top.characterLayer.findNode(balaoData.origem)
        if personagem <> invalid then
            posPersonagem = personagem.translation
            bubble.translation = [posPersonagem[0] - 300, posPersonagem[1] - 150]
        end if
    end if
    
    ' Estilo do balão
    if balaoData.estilo = "ameacador" then
        bubble.color = "#4b000099"
        texto.color = "#FF0000"
        texto.font = "font:LargeBoldSystemFont"
    else if balaoData.estilo = "epico" then
        bubble.color = "#FFD70099"
        texto.color = "#000000"
    end if
    
    ' Efeito de digitar
    AnimarTextoDigitar(texto, balaoData.texto)
end sub

sub AnimarTextoDigitar(label as Object, textoCompleto as String)
    m.textoCompleto = textoCompleto
    m.textoAtual = ""
    m.indiceTexto = 0
    
    m.textoTimer = CreateObject("roSGNode", "Timer")
    m.textoTimer.duration = 0.05
    m.textoTimer.repeat = true
    m.textoTimer.observeField("fire", "onDigitarTexto")
    m.textoTimer.control = "start"
end sub

sub onDigitarTexto(event as Object)
    if m.indiceTexto >= Len(m.textoCompleto) then
        m.textoTimer.control = "stop"
        return
    end if
    
    m.indiceTexto++
    m.textoAtual = Left(m.textoCompleto, m.indiceTexto)
    m.top.speechText.text = m.textoAtual
end sub

sub onSceneTimer(event as Object)
    m.currentSceneIndex++
    
    if m.currentSceneIndex < m.scenes.Count() then
        RenderScene(m.scenes[m.currentSceneIndex])
    else
        ' Capítulo terminado
        m.isPlaying = false
        MostrarControles()
    end if
end sub

sub onBackPressed(event as Object)
    if m.isPlaying then
        ' Pular para próxima cena ou terminar capítulo
        if m.sceneTimer <> invalid then
            m.sceneTimer.control = "stop"
        end
        onSceneTimer(invalid)
    end if
end sub

sub ClearLayers()
    ' Remover todos os filhos das camadas
    while m.top.characterLayer.getChildCount() > 0
        m.top.characterLayer.removeChildIndex(0)
    end while
    
    while m.top.effectsLayer.getChildCount() > 0
        m.top.effectsLayer.removeChildIndex(0)
    end while
    
    while m.top.sceneElementsLayer.getChildCount() > 0
        m.top.sceneElementsLayer.removeChildIndex(0)
    end while
    
    m.top.speechBubble.visible = false
end sub

sub MostrarControles()
    m.top.controlsOverlay.opacity = 1
    m.top.skipHint.text = "Pressione OK para continuar"
end sub

' ============================================
' FUNÇÕES AUXILIARES DE GERAÇÃO PROCEDURAL
' ============================================

function GerarCorVariacao(corBase as String, variacao as Integer) as String
    ' Gera variações de uma cor para criar profundidade
    ' Implementação simplificada
    return corBase
end function

sub IniciarAnimacaoFundo(tipoAnimacao as String)
    if tipoAnimacao = "respirar" then
        m.bgAnimTimer = CreateObject("roSGNode", "Timer")
        m.bgAnimTimer.duration = 2
        m.bgAnimTimer.repeat = true
        m.bgAnimTimer.observeField("fire", "onBackgroundBreath")
        m.bgAnimTimer.control = "start"
        m.bgOpacity = 0.8
    end if
end sub

sub onBackgroundBreath(event as Object)
    m.bgOpacity = 0.6 + (m.bgOpacity - 0.6) * -1
    m.top.background.opacity = m.bgOpacity
end sub

' ============================================
' DADOS DE EXEMPLO PARA TESTE
' ============================================

function LoadStoryData() as Object
    return {
        capitulo_1: {
            titulo: "O Despertar das Sombras",
            cenas: [
                {
                    id: "cena_01",
                    duracao_segundos: 5,
                    fundo: {
                        tipo: "gradiente",
                        cores: ["#0f0c29", "#302b63", "#24243e"],
                        animacao: "respirar"
                    },
                    elementos: [
                        {
                            tipo: "texto",
                            conteudo: "Há milênios, Aether dormia...",
                            posicao: { x: 300, y: 100 },
                            estilo: "titulo_epico"
                        }
                    ]
                },
                {
                    id: "cena_02",
                    duracao_segundos: 6,
                    fundo: {
                        tipo: "imagem_referencia",
                        cor_base: "#2c3e50",
                        detalhes: "floresta_sombria"
                    },
                    personagens: [
                        {
                            id: "heroi",
                            sprite: invalid,
                            posicao_inicial: [200, 500],
                            posicao_final: [400, 500],
                            animacao: "deslizar_suave",
                            balao_fala: "Sinto uma presença antiga aqui."
                        }
                    ],
                    efeitos: [
                        { tipo: "particulas", estilo: "vagalumes", quantidade: 20 }
                    ]
                },
                {
                    id: "cena_03",
                    duracao_segundos: 8,
                    fundo: {
                        tipo: "gradiente",
                        cores: ["#4b0000", "#000000"],
                        transicao: "flash_vermelho"
                    },
                    personagens: [
                        {
                            id: "vilao",
                            sprite: invalid,
                            posicao: [640, 200],
                            tamanho: 150,
                            animacao: "tremer_ameaca"
                        }
                    ],
                    balao_fala: {
                        texto: "Eles nunca deveriam ter acordado.",
                        origem: "vilao",
                        estilo: "ameacador"
                    }
                }
            ]
        }
    }
end function
