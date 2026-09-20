' Ponto de entrada do canal Roku
' Kurions — Saga Origens & A Lenda de Aether
sub Main()
    ' Cria a tela SceneGraph
    screen = CreateObject("roSGScreen")
    m.port = CreateObject("roMessagePort")
    screen.SetMessagePort(m.port)
    
    ' Verificar se deve mostrar storyboard ou jogo principal
    showStoryboard = false  ' Mudar para true para testar storyboard
    
    if showStoryboard then
        ' Mostrar demonstração do storyboard
        scene = screen.CreateScene("StoryboardScene")
        screen.Show()
        
        ' Carregar e renderizar capítulo de exemplo
        storyData = LoadStoryData()
        RenderCapituloDemo(scene, storyData.capitulo_1)
    else
        ' Cria e exibe a cena principal do jogo
        scene = screen.CreateScene("MainScene")
        screen.Show()
    end if
    
    ' Loop de eventos da aplicação para manter a cena ativa
    while(true)
        msg = wait(0, m.port)
        msgType = type(msg)
        if msgType = "roSGScreenEvent"
            if msg.isScreenClosed() then return
        end if
    end while
end sub

' ============================================
' FUNÇÃO PRINCIPAL DE RENDERIZAÇÃO DO STORYBOARD
' ============================================

sub RenderCapituloDemo(scene as Object, capituloData as Object)
    scenes = capituloData.cenas
    currentSceneIndex = 0
    
    ' Renderizar primeira cena
    RenderCena(scene, scenes[currentSceneIndex])
    
    ' Loop principal para navegação entre cenas
    port = CreateObject("roMessagePort")
    scene.SetMessagePort(port)
    
    while currentSceneIndex < scenes.Count()
        msg = wait(100, port)
        
        ' Verificar se é timer de cena
        if type(msg) = "roSGNodeEvent" then
            eventField = msg.GetField()
            
            if eventField = "fire" then
                ' Timer disparou - avançar para próxima cena
                currentSceneIndex++
                
                if currentSceneIndex < scenes.Count() then
                    RenderCena(scene, scenes[currentSceneIndex])
                else
                    ' Capítulo terminado
                    MostrarTelaFinal(scene)
                    exit while
                end if
            end if
        end if
    end while
end sub

sub RenderCena(scene as Object, cena as Object)
    ' Limpar camadas anteriores
    ClearLayers(scene)
    
    ' Renderizar fundo
    RenderFundo(scene, cena.fundo)
    
    ' Renderizar elementos da cena
    if cena.elementos <> invalid then
        for each elemento in cena.elementos
            RenderElemento(scene, elemento)
        end for
    end if
    
    ' Renderizar personagens
    if cena.personagens <> invalid then
        for each personagem in cena.personagens
            RenderPersonagem(scene, personagem)
        end for
    end if
    
    ' Renderizar efeitos
    if cena.efeitos <> invalid then
        for each efeito in cena.efeitos
            RenderEfeito(scene, efeito)
        end for
    end if
    
    ' Mostrar balão de fala se existir
    if cena.balao_fala <> invalid then
        MostrarBalaoFala(scene, cena.balao_fala)
    end if
    
    ' Configurar timer para próxima cena automática
    sceneTimer = scene.findNode("sceneTimer")
    if sceneTimer = invalid then
        sceneTimer = CreateObject("roSGNode", "Timer")
        sceneTimer.id = "sceneTimer"
        scene.appendChild(sceneTimer)
    end if
    
    sceneTimer.duration = cena.duracao_segundos
    sceneTimer.repeat = false
    sceneTimer.control = "start"
end sub

sub RenderFundo(scene as Object, fundoData as Object)
    background = scene.findNode("background")
    backgroundGroup = scene.findNode("backgroundGroup")
    
    if fundoData.tipo = "gradiente" then
        ' Criar gradiente com múltiplos retângulos
        cores = fundoData.cores
        alturaCada = 720 / cores.Count()
        
        for i = 0 to cores.Count() - 1
            rect = CreateObject("roSGNode", "Rectangle")
            rect.width = 1280
            rect.height = alturaCada
            rect.color = cores[i]
            rect.translation = [0, i * alturaCada]
            backgroundGroup.appendChild(rect)
        end for
        
        ' Animar gradiente se especificado
        if fundoData.animacao <> invalid then
            IniciarAnimacaoFundo(scene, fundoData.animacao)
        end if
        
    else if fundoData.tipo = "imagem_referencia" then
        ' Usar cor base + padrões gerados proceduralmente
        background.color = fundoData.cor_base
        
        ' Gerar padrão específico
        if fundoData.detalhes = "floresta_sombria" then
            GerarPadraoFloresta(scene)
        else if fundoData.detalhes = "caverna" then
            GerarPadraoCaverna(scene)
        end if
    end if
end sub

sub GerarPadraoFloresta(scene as Object)
    characterLayer = scene.findNode("characterLayer")
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
        characterLayer.appendChild(tronco)
        
        ' Copa da árvore (triângulo)
        copa = CreateObject("roSGNode", "Polygon")
        copa.points = "[[0,0],[40,-60],[80,0]]"
        copa.color = "#1a472a"
        copa.translation = [x - 30, 720 - altura - 10]
        characterLayer.appendChild(copa)
    end for
end sub

sub GerarPadraoCaverna(scene as Object)
    effectsLayer = scene.findNode("effectsLayer")
    numEstalactites = 20
    
    for i = 0 to numEstalactites - 1
        x = Rnd(1280)
        comprimento = 30 + Rnd(70)
        
        ' Estalactite (triângulo invertido)
        estalactite = CreateObject("roSGNode", "Polygon")
        estalactite.points = "[[0,0],[20,40],[40,0]]"
        estalactite.color = "#4a4a4a"
        estalactite.translation = [x, 0]
        effectsLayer.appendChild(estalactite)
    end for
end sub

sub RenderElemento(scene as Object, elemento as Object)
    sceneElementsLayer = scene.findNode("sceneElementsLayer")
    
    if elemento.tipo = "texto" then
        label = CreateObject("roSGNode", "Label")
        label.text = elemento.conteudo
        label.font = "font:LargeBoldSystemFont"
        label.color = "#FFFFFF"
        label.translation = [elemento.posicao.x, elemento.posicao.y]
        label.horizAlign = "center"
        
        if elemento.estilo = "titulo_epico" then
            label.font = "font:LargestBoldSystemFont"
            label.color = "#FFD700"
        end if
        
        sceneElementsLayer.appendChild(label)
        
        ' Aplicar efeito de digitar se especificado
        if elemento.efeito = "digitar" then
            AnimarTextoDigitar(scene, label, elemento.conteudo)
        end if
        
    else if elemento.tipo = "forma" then
        if elemento.forma = "circulo" then
            circulo = CreateObject("roSGNode", "Circle")
            circulo.radius = elemento.tamanho / 2
            circulo.color = elemento.cor
            circulo.opacity = elemento.opacidade
            circulo.translation = [elemento.posicao.x, elemento.posicao.y]
            sceneElementsLayer.appendChild(circulo)
            
            if elemento.animacao = "pulsar_lento" then
                AnimarPulsar(scene, circulo)
            end if
        end if
    end if
end sub

sub RenderPersonagem(scene as Object, personagemData as Object)
    characterLayer = scene.findNode("characterLayer")
    grupoPersonagem = CreateObject("roSGNode", "Group")
    grupoPersonagem.id = personagemData.id
    
    ' Carregar sprite ou gerar silhueta
    if personagemData.sprite <> invalid and personagemData.sprite <> "" then
        poster = CreateObject("roSGNode", "Poster")
        poster.uri = "pkg:/images/" + personagemData.sprite
        poster.width = 100
        poster.height = 150
        grupoPersonagem.appendChild(poster)
    else
        ' Gerar silhueta proceduralmente
        GerarSilhuetaPersonagem(grupoPersonagem)
    end if
    
    grupoPersonagem.translation = personagemData.posicao_inicial
    characterLayer.appendChild(grupoPersonagem)
    
    ' Armazenar dados para animação
    grupoPersonagem.m_finalPos = personagemData.posicao_final
    grupoPersonagem.m_animacao = personagemData.animacao
    
    ' Iniciar animação se houver movimento
    if personagemData.posicao_final <> invalid then
        AnimarPersonagem(scene, grupoPersonagem)
    end if
    
    ' Mostrar balão de fala do personagem
    if personagemData.balao_fala <> invalid then
        MostrarBalaoFala(scene, {
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

sub AnimarPersonagem(scene as Object, personagem as Object)
    animTimer = CreateObject("roSGNode", "Timer")
    animTimer.duration = 0.03
    animTimer.repeat = true
    animTimer.id = "animTimer_" + personagem.id
    scene.appendChild(animTimer)
    
    ' Armazenar estado da animação
    personagem.m_animProgresso = 0
    personagem.m_animTimer = animTimer
    
    animTimer.control = "start"
end sub

sub RenderEfeito(scene as Object, efeitoData as Object)
    effectsLayer = scene.findNode("effectsLayer")
    
    if efeitoData.tipo = "particulas" then
        if efeitoData.estilo = "vagalumes" then
            CriarVagalumes(scene, efeitoData.quantidade)
        else if efeitoData.estilo = "poeira_magica" then
            CriarPoeiraMagica(scene, efeitoData.quantidade)
        end if
    else if efeitoData.tipo = "chuva" then
        CriarChuva(scene)
    else if efeitoData.tipo = "neve" then
        CriarNeve(scene)
    end if
end sub

sub CriarVagalumes(scene as Object, quantidade as Integer)
    effectsLayer = scene.findNode("effectsLayer")
    
    for i = 0 to quantidade - 1
        vagaLume = CreateObject("roSGNode", "Circle")
        vagaLume.radius = 3 + Rnd(2)
        vagaLume.color = "#FFFF00"
        vagaLume.opacity = 0.3 + Rnd(0.5)
        
        x = Rnd(1280)
        y = Rnd(720)
        vagaLume.translation = [x, y]
        vagaLume.id = "vagalume_" + i.ToStr()
        
        effectsLayer.appendChild(vagaLume)
        
        ' Animar piscar
        timerPiscar = CreateObject("roSGNode", "Timer")
        timerPiscar.duration = 0.5 + Rnd(1)
        timerPiscar.repeat = true
        timerPiscar.id = "piscar_" + i.ToStr()
        timerPiscar.observeField("fire", "onPiscarVagalume")
        timerPiscar.control = "start"
        scene.appendChild(timerPiscar)
        
        vagaLume.m_timer = timerPiscar
    end for
end sub

sub onPiscarVagalume(event as Object)
    ' Implementação simplificada - em produção usaria m.top
    ' para acessar os nós corretamente
end sub

sub MostrarBalaoFala(scene as Object, balaoData as Object)
    dialogueLayer = scene.findNode("dialogueLayer")
    bubble = scene.findNode("speechBubble")
    texto = scene.findNode("speechText")
    
    bubble.visible = true
    texto.text = balaoData.texto
    
    ' Posicionar baseado na origem
    if balaoData.origem <> invalid then
        characterLayer = scene.findNode("characterLayer")
        personagem = characterLayer.findNode(balaoData.origem)
        
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
    AnimarTextoDigitar(scene, texto, balaoData.texto)
end sub

sub AnimarTextoDigitar(scene as Object, label as Object, textoCompleto as String)
    textoTimer = CreateObject("roSGNode", "Timer")
    textoTimer.duration = 0.05
    textoTimer.repeat = true
    textoTimer.id = "textoTimer"
    scene.appendChild(textoTimer)
    
    label.m_textoCompleto = textoCompleto
    label.m_textoAtual = ""
    label.m_indiceTexto = 0
    
    textoTimer.control = "start"
end sub

sub IniciarAnimacaoFundo(scene as Object, tipoAnimacao as String)
    if tipoAnimacao = "respirar" then
        bgAnimTimer = CreateObject("roSGNode", "Timer")
        bgAnimTimer.duration = 2
        bgAnimTimer.repeat = true
        bgAnimTimer.id = "bgAnimTimer"
        scene.appendChild(bgAnimTimer)
        
        background = scene.findNode("background")
        background.m_opacity = 0.8
        background.m_bgAnimTimer = bgAnimTimer
        
        bgAnimTimer.control = "start"
    end if
end sub

sub ClearLayers(scene as Object)
    characterLayer = scene.findNode("characterLayer")
    effectsLayer = scene.findNode("effectsLayer")
    sceneElementsLayer = scene.findNode("sceneElementsLayer")
    backgroundGroup = scene.findNode("backgroundGroup")
    bubble = scene.findNode("speechBubble")
    
    ' Remover filhos das camadas
    while characterLayer.getChildCount() > 0
        characterLayer.removeChildIndex(0)
    end while
    
    while effectsLayer.getChildCount() > 0
        effectsLayer.removeChildIndex(0)
    end while
    
    while sceneElementsLayer.getChildCount() > 0
        sceneElementsLayer.removeChildIndex(0)
    end while
    
    while backgroundGroup.getChildCount() > 0
        backgroundGroup.removeChildIndex(0)
    end while
    
    bubble.visible = false
end sub

sub MostrarTelaFinal(scene as Object)
    ClearLayers(scene)
    
    controlsOverlay = scene.findNode("controlsOverlay")
    skipHint = scene.findNode("skipHint")
    
    controlsOverlay.opacity = 1
    skipHint.text = "Fim do capítulo - Pressione OK para continuar"
    skipHint.font = "font:LargeBoldSystemFont"
    skipHint.color = "#FFD700"
    skipHint.translation = [640, 360]
end sub

' ============================================
' DADOS DE EXEMPLO PARA STORYBOARD
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
                            posicao: { x: 640, y: 100 },
                            estilo: "titulo_epico",
                            efeito: "digitar"
                        },
                        {
                            tipo: "forma",
                            forma: "circulo",
                            cor: "#FFD700",
                            opacidade: 0.1,
                            tamanho: 400,
                            posicao: { x: 640, y: 360 },
                            animacao: "pulsar_lento"
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
                        cores: ["#4b0000", "#000000"]
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
