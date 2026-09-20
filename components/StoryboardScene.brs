' BrightScript - Storyboard/Comic Generator for Roku TV
' Componente StoryboardScene

sub Init()
    m.background = m.top.findNode("background")
    m.backgroundGroup = m.top.findNode("backgroundGroup")
    m.effectsLayer = m.top.findNode("effectsLayer")
    m.characterLayer = m.top.findNode("characterLayer")
    m.dialogueLayer = m.top.findNode("dialogueLayer")
    m.speechBubble = m.top.findNode("speechBubble")
    m.speechText = m.top.findNode("speechText")
    m.sceneElementsLayer = m.top.findNode("sceneElementsLayer")
    m.controlsOverlay = m.top.findNode("controlsOverlay")
    m.skipHint = m.top.findNode("skipHint")
    
    m.currentSceneIndex = 0
    m.scenes = []
    m.isPlaying = false
    
    m.top.observeField("storyData", "onStoryDataChanged")
end sub

sub onStoryDataChanged()
    if m.top.storyData <> invalid then
        RenderCapitulo(m.top.storyData)
    end if
end sub

sub RenderCapitulo(capituloData as Object)
    if capituloData = invalid or capituloData.cenas = invalid then return
    m.scenes = capituloData.cenas
    m.currentSceneIndex = 0
    m.isPlaying = true
    
    if m.scenes.Count() > 0 then
        RenderScene(m.scenes[m.currentSceneIndex])
    end if
end sub

sub RenderScene(cena as Object)
    if cena = invalid then return
    
    ' Limpar camada anterior
    ClearLayers()
    
    ' Renderizar fundo
    if cena.fundo <> invalid then
        RenderFundo(cena.fundo)
    end if
    
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
    duracao = 5
    if cena.duracao_segundos <> invalid then
        duracao = cena.duracao_segundos
    end if
    
    m.sceneTimer = CreateObject("roSGNode", "Timer")
    m.sceneTimer.duration = duracao
    m.sceneTimer.repeat = false
    m.sceneTimer.observeField("fire", "onSceneTimer")
    m.sceneTimer.control = "start"
end sub

sub RenderFundo(fundoData as Object)
    if fundoData = invalid or m.background = invalid then return
    
    if fundoData.tipo = "gradiente" and fundoData.cores <> invalid then
        cores = fundoData.cores
        if cores.Count() > 0 then
            alturaCada = 720 / cores.Count()
            for i = 0 to cores.Count() - 1
                rect = CreateObject("roSGNode", "Rectangle")
                rect.width = 1280
                rect.height = alturaCada
                rect.color = cores[i]
                rect.translation = [0, i * alturaCada]
                if m.backgroundGroup <> invalid then
                    m.backgroundGroup.appendChild(rect)
                end if
            end for
        end if
    else if fundoData.tipo = "imagem_referencia" then
        if fundoData.cor_base <> invalid then
            m.background.color = fundoData.cor_base
        end if
        if fundoData.detalhes = "floresta_sombria" then
            GerarPadraoFloresta()
        end if
    end if
end sub

sub GerarPadraoFloresta()
    if m.characterLayer = invalid then return
    numArvores = 12
    for i = 0 to numArvores - 1
        x = Rnd(1200)
        altura = 180 + Rnd(250)
        
        tronco = CreateObject("roSGNode", "Rectangle")
        tronco.width = 20 + Rnd(10)
        tronco.height = altura
        tronco.color = "#3d2817"
        tronco.translation = [x, 720 - altura]
        m.characterLayer.appendChild(tronco)
        
        copa = CreateObject("roSGNode", "Rectangle")
        copa.width = 70
        copa.height = 70
        copa.color = "#1a472a"
        copa.translation = [x - 25, 720 - altura - 35]
        m.characterLayer.appendChild(copa)
    end for
end sub

sub RenderElemento(elemento as Object)
    if elemento = invalid or m.sceneElementsLayer = invalid then return
    
    if elemento.tipo = "texto" then
        label = CreateObject("roSGNode", "Label")
        label.text = elemento.conteudo
        label.color = "#FFD700"
        label.font = "font:LargeBoldSystemFont"
        label.width = 800
        if elemento.posicao <> invalid then
            label.translation = [elemento.posicao.x, elemento.posicao.y]
        else
            label.translation = [200, 100]
        end if
        m.sceneElementsLayer.appendChild(label)
    else if elemento.tipo = "forma" then
        rect = CreateObject("roSGNode", "Rectangle")
        rect.width = 100
        rect.height = 100
        if elemento.tamanho <> invalid then
            rect.width = elemento.tamanho
            rect.height = elemento.tamanho
        end if
        if elemento.cor <> invalid then rect.color = elemento.cor
        if elemento.opacidade <> invalid then rect.opacity = elemento.opacidade
        if elemento.posicao <> invalid then
            rect.translation = [elemento.posicao.x, elemento.posicao.y]
        end if
        m.sceneElementsLayer.appendChild(rect)
    end if
end sub

sub RenderPersonagem(personagemData as Object)
    if personagemData = invalid or m.characterLayer = invalid then return
    
    grupo = CreateObject("roSGNode", "Group")
    
    if personagemData.sprite <> invalid then
        poster = CreateObject("roSGNode", "Poster")
        poster.uri = "pkg:/images/" + personagemData.sprite
        poster.width = 100
        poster.height = 150
        grupo.appendChild(poster)
    else
        GerarSilhuetaPersonagem(grupo)
    end if
    
    if personagemData.posicao_inicial <> invalid then
        grupo.translation = personagemData.posicao_inicial
    else if personagemData.posicao <> invalid then
        grupo.translation = personagemData.posicao
    else
        grupo.translation = [200, 400]
    end if
    
    if personagemData.id <> invalid then
        grupo.id = personagemData.id
    end if
    
    m.characterLayer.appendChild(grupo)
    
    if personagemData.balao_fala <> invalid then
        falaTexto = ""
        if type(personagemData.balao_fala) = "roString" or type(personagemData.balao_fala) = "String" then
            falaTexto = personagemData.balao_fala
        else if type(personagemData.balao_fala) = "roAssociativeArray" then
            falaTexto = personagemData.balao_fala.texto
        end if
        MostrarBalaoFala({
            texto: falaTexto,
            origem: personagemData.id
        })
    end if
end sub

sub GerarSilhuetaPersonagem(grupo as Object)
    cabeca = CreateObject("roSGNode", "Rectangle")
    cabeca.width = 30
    cabeca.height = 30
    cabeca.color = "#E0E0E0"
    cabeca.translation = [35, 20]
    grupo.appendChild(cabeca)
    
    corpo = CreateObject("roSGNode", "Rectangle")
    corpo.width = 50
    corpo.height = 70
    corpo.color = "#2563EB"
    corpo.translation = [25, 55]
    grupo.appendChild(corpo)
    
    pernaEsq = CreateObject("roSGNode", "Rectangle")
    pernaEsq.width = 18
    pernaEsq.height = 40
    pernaEsq.color = "#1E293B"
    pernaEsq.translation = [28, 125]
    grupo.appendChild(pernaEsq)
    
    pernaDir = CreateObject("roSGNode", "Rectangle")
    pernaDir.width = 18
    pernaDir.height = 40
    pernaDir.color = "#1E293B"
    pernaDir.translation = [52, 125]
    grupo.appendChild(pernaDir)
end sub

sub RenderEfeito(efeitoData as Object)
    if efeitoData = invalid then return
    if efeitoData.tipo = "particulas" then
        qtd = 20
        if efeitoData.quantidade <> invalid then qtd = efeitoData.quantidade
        CriarVagalumes(qtd)
    end if
end sub

sub CriarVagalumes(quantidade as Integer)
    if m.effectsLayer = invalid then return
    for i = 0 to quantidade - 1
        vagaLume = CreateObject("roSGNode", "Rectangle")
        vagaLume.width = 5
        vagaLume.height = 5
        vagaLume.color = "#FACC15"
        vagaLume.opacity = 0.7
        vagaLume.translation = [Rnd(1240), Rnd(680)]
        m.effectsLayer.appendChild(vagaLume)
    end for
end sub

sub MostrarBalaoFala(balaoData as Object)
    if m.speechBubble = invalid or m.speechText = invalid or balaoData = invalid then return
    
    texto = ""
    if type(balaoData) = "roString" or type(balaoData) = "String" then
        texto = balaoData
    else if balaoData.texto <> invalid then
        texto = balaoData.texto
    end if
    
    m.speechBubble.visible = true
    m.speechText.text = texto
    m.speechBubble.translation = [340, 520]
end sub

sub onSceneTimer(event as Object)
    m.currentSceneIndex++
    if m.scenes <> invalid and m.currentSceneIndex < m.scenes.Count() then
        RenderScene(m.scenes[m.currentSceneIndex])
    else
        m.isPlaying = false
        MostrarControles()
    end if
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    handled = false
    if press then
        if key = "OK" or key = "right" then
            if m.isPlaying then
                if m.sceneTimer <> invalid then
                    m.sceneTimer.control = "stop"
                end if
                onSceneTimer(invalid)
                handled = true
            end if
        else if key = "back" then
            if m.isPlaying then
                m.isPlaying = false
                if m.sceneTimer <> invalid then
                    m.sceneTimer.control = "stop"
                end if
                MostrarControles()
                handled = true
            end if
        end if
    end if
    return handled
end function

sub ClearLayers()
    if m.characterLayer <> invalid then
        while m.characterLayer.getChildCount() > 0
            m.characterLayer.removeChildIndex(0)
        end while
    end if
    
    if m.effectsLayer <> invalid then
        while m.effectsLayer.getChildCount() > 0
            m.effectsLayer.removeChildIndex(0)
        end while
    end if
    
    if m.sceneElementsLayer <> invalid then
        while m.sceneElementsLayer.getChildCount() > 0
            m.sceneElementsLayer.removeChildIndex(0)
        end while
    end if
    
    if m.backgroundGroup <> invalid then
        while m.backgroundGroup.getChildCount() > 0
            m.backgroundGroup.removeChildIndex(0)
        end while
    end if
    
    if m.speechBubble <> invalid then
        m.speechBubble.visible = false
    end if
end sub

sub MostrarControles()
    if m.controlsOverlay <> invalid then
        m.controlsOverlay.opacity = 1
    end if
    if m.skipHint <> invalid then
        m.skipHint.text = "Fim do capítulo - Pressione Voltar para retornar"
    end if
end sub
