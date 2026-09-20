' Lógica Principal da Aplicação Kurions — Saga Origens
' Desenvolvido para Roku OS com SceneGraph e BrightScript

sub init()
    ' 1. Inicializa módulos de dados, armazenamento e API
    m.storage = GetStorage()
    m.dataManager = GetDataManager()
    m.api = GetAPIClient()

    m.episodes = m.api.getEpisodes()
    m.characters = m.api.getCharacters()
    m.kurions = m.api.getKurions()
    m.lore = m.api.getLore()

    ' 2. Captura referências dos nós da interface
    captureNodeReferences()

    ' 3. Estado de Navegação
    m.focusArea = "sidebar" ' "sidebar", "content", "video", "video_end"
    m.selectedMenuIndex = 0
    m.focusedEpisodeIndex = 0
    m.epSubFocus = "card" ' "card", "btn_play", "btn_restart"
    m.focusedKurionIndex = 0
    m.focusedCharIndex = 0
    m.videoEndButtonIndex = 0 ' 0: proximo, 1: repetir

    ' Estados de Lore (História)
    m.loreActiveTab = 0 ' 0: Colar, 1: Dirigível
    m.loreSubFocus = "tab" ' "tab", "colar_btn", "room"
    m.activeRoomIndex = 0

    ' 4. Configura observadores do Player de Vídeo
    m.videoPlayer.observeField("position", "onVideoPositionChanged")
    m.videoPlayer.observeField("state", "onVideoStateChanged")
    m.videoPlayer.observeField("duration", "onVideoDurationChanged")

    m.videoOverlayTimer.observeField("fire", "hideVideoOverlay")
    m.videoProgressTimer.observeField("fire", "saveCurrentVideoProgress")

    ' Inicia animação contínua de pulso luminoso do Colar
    if m.colarPulseAnim <> invalid
        m.colarPulseAnim.control = "start"
    end if

    ' Inicializa timer da tela de abertura (Intro cinematográfica)
    m.introTimer.observeField("fire", "onIntroTimerFired")
    m.introFadeOutAnim.observeField("state", "onIntroFadeStateChanged")
    m.introTimer.control = "start"

    ' Observadores de timers do jogo
    if m.gameGlowTimer <> invalid then m.gameGlowTimer.observeField("fire", "onGameGlowTimerFired")
    if m.gameEnemyTimer <> invalid then m.gameEnemyTimer.observeField("fire", "onGameEnemyTimerFired")
    if m.gameAttackTimer <> invalid then m.gameAttackTimer.observeField("fire", "onGameAttackTimerFired")
    if m.gameInvulnerableTimer <> invalid then m.gameInvulnerableTimer.observeField("fire", "onGameInvulnerableTimerFired")
    if m.gameShieldTimer <> invalid then m.gameShieldTimer.observeField("fire", "onGameShieldTimerFired")
    if m.gameShieldCooldownTimer <> invalid then m.gameShieldCooldownTimer.observeField("fire", "onGameShieldCooldownTimerFired")

    ' Inicializa o mini-jogo estilo Zelda
    initGameSystem()

    ' 5. Inicializa telas e dados
    updateContinueWatching()
    updateEpisodeDetails()
    updateKurionDetails()
    updateCharacterDetails()
    updateLoreDetails()
    updateDeviceInfo()
    refreshMenuSelectionVisuals()

    ' 6. Foco inicial na cena
    m.top.setFocus(true)
end sub

sub captureNodeReferences()
    ' Sidebar / Menu
    m.menuFocusHighlight = m.top.findNode("menuFocusHighlight")
    m.menuFocusBar = m.top.findNode("menuFocusBar")
    m.menuItems = [
        m.top.findNode("menuItem_0"),
        m.top.findNode("menuItem_1"),
        m.top.findNode("menuItem_2"),
        m.top.findNode("menuItem_3"),
        m.top.findNode("menuItem_4"),
        m.top.findNode("menuItem_5"),
        m.top.findNode("menuItem_6")
    ]

    ' Telas Centrais
    m.viewHome = m.top.findNode("viewHome")
    m.viewEpisodes = m.top.findNode("viewEpisodes")
    m.viewGame = m.top.findNode("viewGame")
    m.viewLore = m.top.findNode("viewLore")
    m.viewKurions = m.top.findNode("viewKurions")
    m.viewCharacters = m.top.findNode("viewCharacters")
    m.viewSettings = m.top.findNode("viewSettings")
    m.views = [m.viewHome, m.viewEpisodes, m.viewGame, m.viewLore, m.viewKurions, m.viewCharacters, m.viewSettings]

    ' Home Nodes
    m.homeEpTitle = m.top.findNode("homeEpTitle")
    m.homeEpSynopsis = m.top.findNode("homeEpSynopsis")
    m.homeProgressText = m.top.findNode("homeProgressText")
    m.homeProgressFill = m.top.findNode("homeProgressFill")
    m.btnWatchNow = m.top.findNode("btnWatchNow")
    m.btnWatchNowLabel = m.top.findNode("btnWatchNowLabel")

    ' Episódios Nodes
    m.focusEpBoxes = [
        m.top.findNode("focusEp_0"),
        m.top.findNode("focusEp_1"),
        m.top.findNode("focusEp_2"),
        m.top.findNode("focusEp_3")
    ]
    m.detEpNumber = m.top.findNode("detEpNumber")
    m.detEpTitle = m.top.findNode("detEpTitle")
    m.detEpMeta = m.top.findNode("detEpMeta")
    m.detEpSynopsis = m.top.findNode("detEpSynopsis")
    m.detEpStatus = m.top.findNode("detEpStatus")
    m.detEpPoster = m.top.findNode("detEpPoster")
    m.btnPlayEpisode = m.top.findNode("btnPlayEpisode")
    m.btnPlayEpisodeLabel = m.top.findNode("btnPlayEpisodeLabel")
    m.btnRestartEpisode = m.top.findNode("btnRestartEpisode")
    m.btnRestartEpisodeLabel = m.top.findNode("btnRestartEpisodeLabel")

    ' Lore & Dirigível Nodes
    m.tabBg_0 = m.top.findNode("tabBg_0")
    m.tabBg_1 = m.top.findNode("tabBg_1")
    m.tabBorder_0 = m.top.findNode("tabBorder_0")
    m.tabBorder_1 = m.top.findNode("tabBorder_1")
    m.loreSectionColar = m.top.findNode("loreSectionColar")
    m.loreSectionDirigivel = m.top.findNode("loreSectionDirigivel")
    m.colarPulseAnim = m.top.findNode("colarPulseAnim")
    m.btnColarPower = m.top.findNode("btnColarPower")
    m.btnColarPowerLabel = m.top.findNode("btnColarPowerLabel")
    m.colarRevelationText = m.top.findNode("colarRevelationText")

    m.roomBoxes = [
        m.top.findNode("roomBox_0"),
        m.top.findNode("roomBox_1"),
        m.top.findNode("roomBox_2"),
        m.top.findNode("roomBox_3"),
        m.top.findNode("roomBox_4")
    ]
    m.activeRoomName = m.top.findNode("activeRoomName")
    m.activeRoomDesc = m.top.findNode("activeRoomDesc")
    m.activeRoomSecret = m.top.findNode("activeRoomSecret")

    ' Kurions Nodes
    m.focusKBoxes = [
        m.top.findNode("focusK_0"),
        m.top.findNode("focusK_1")
    ]
    m.detKPoster = m.top.findNode("detKPoster")
    m.detKName = m.top.findNode("detKName")
    m.detKTypes = m.top.findNode("detKTypes")
    m.detKDesc = m.top.findNode("detKDesc")
    m.detKAbilities = m.top.findNode("detKAbilities")

    ' Personagens Nodes
    m.focusCharBoxes = [
        m.top.findNode("focusChar_0"),
        m.top.findNode("focusChar_1"),
        m.top.findNode("focusChar_2"),
        m.top.findNode("focusChar_3"),
        m.top.findNode("focusChar_4")
    ]
    m.detCharName = m.top.findNode("detCharName")
    m.detCharRole = m.top.findNode("detCharRole")
    m.detCharDesc = m.top.findNode("detCharDesc")
    m.detCharKurions = m.top.findNode("detCharKurions")
    m.detCharEps = m.top.findNode("detCharEps")
    m.detCharPoster = m.top.findNode("detCharPoster")

    ' Settings Nodes & Device Info
    m.devInfoModel = m.top.findNode("devInfoModel")
    m.devInfoVersion = m.top.findNode("devInfoVersion")
    m.devInfoDisplay = m.top.findNode("devInfoDisplay")
    m.devInfoNet = m.top.findNode("devInfoNet")
    m.btnClearData = m.top.findNode("btnClearData")
    m.btnClearDataLabel = m.top.findNode("btnClearDataLabel")
    m.settingsMsg = m.top.findNode("settingsMsg")

    ' Video Nodes
    m.videoContainer = m.top.findNode("videoContainer")
    m.videoPlayer = m.top.findNode("videoPlayer")
    m.videoOverlay = m.top.findNode("videoOverlay")
    m.videoOverlayTimer = m.top.findNode("videoOverlayTimer")
    m.videoProgressTimer = m.top.findNode("videoProgressTimer")
    m.videoTitleLabel = m.top.findNode("videoTitleLabel")
    m.videoSubtitleLabel = m.top.findNode("videoSubtitleLabel")
    m.videoTimeCurrent = m.top.findNode("videoTimeCurrent")
    m.videoTimeTotal = m.top.findNode("videoTimeTotal")
    m.videoTrackFill = m.top.findNode("videoTrackFill")

    m.videoBufferingBox = m.top.findNode("videoBufferingBox")
    m.videoOptionsModal = m.top.findNode("videoOptionsModal")
    m.optEpTitle = m.top.findNode("optEpTitle")
    m.optEpDesc = m.top.findNode("optEpDesc")

    m.endOfVideoModal = m.top.findNode("endOfVideoModal")
    m.endModalEpName = m.top.findNode("endModalEpName")
    m.btnNextEp = m.top.findNode("btnNextEp")
    m.btnNextEpLabel = m.top.findNode("btnNextEpLabel")
    m.btnReplayEp = m.top.findNode("btnReplayEp")
    m.btnReplayEpLabel = m.top.findNode("btnReplayEpLabel")

    ' Intro Nodes
    m.introScreen = m.top.findNode("introScreen")
    m.introTimer = m.top.findNode("introTimer")
    m.introFadeOutAnim = m.top.findNode("introFadeOutAnim")

    ' Game Nodes
    m.gameRoomTitle = m.top.findNode("gameRoomTitle")
    m.gameHpLabel = m.top.findNode("gameHpLabel")
    m.gameGemsLabel = m.top.findNode("gameGemsLabel")
    m.gameShieldLabel = m.top.findNode("gameShieldLabel")
    m.gameKeyLabel = m.top.findNode("gameKeyLabel")
    m.gameGridGroup = m.top.findNode("gameGridGroup")
    m.gamePlayer = m.top.findNode("gamePlayer")
    m.gamePagonix = m.top.findNode("gamePagonix")
    m.gamePagonixShield = m.top.findNode("gamePagonixShield")
    m.gameActionGlow = m.top.findNode("gameActionGlow")
    m.gameAttackBeam = m.top.findNode("gameAttackBeam")
    m.gameMonstersNodes = [
        m.top.findNode("gameMonster_0"),
        m.top.findNode("gameMonster_1"),
        m.top.findNode("gameMonster_2"),
        m.top.findNode("gameMonster_3")
    ]
    m.gameDropsNodes = [
        m.top.findNode("gameDrop_0"),
        m.top.findNode("gameDrop_1"),
        m.top.findNode("gameDrop_2"),
        m.top.findNode("gameDrop_3")
    ]
    m.gameSpeakerAvatar = m.top.findNode("gameSpeakerAvatar")
    m.gameSpeakerName = m.top.findNode("gameSpeakerName")
    m.gameDialogText = m.top.findNode("gameDialogText")
    m.gameControlsHint = m.top.findNode("gameControlsHint")

    m.gameVictoryModal = m.top.findNode("gameVictoryModal")
    m.btnVictoryReplay = m.top.findNode("btnVictoryReplay")
    m.btnVictoryExit = m.top.findNode("btnVictoryExit")

    m.gameOverModal = m.top.findNode("gameOverModal")
    m.btnGameOverRetry = m.top.findNode("btnGameOverRetry")
    m.btnGameOverExit = m.top.findNode("btnGameOverExit")

    m.gameStageClearModal = m.top.findNode("gameStageClearModal")
    m.stageClearTitle = m.top.findNode("stageClearTitle")
    m.stageClearDesc = m.top.findNode("stageClearDesc")
    m.btnStageClearNext = m.top.findNode("btnStageClearNext")

    ' Lojinha do Grande Dirigível
    m.gameShopModal = m.top.findNode("gameShopModal")
    m.shopGemsBalance = m.top.findNode("shopGemsBalance")
    m.shopItemBoxes = [
        m.top.findNode("shopItemBox_0"),
        m.top.findNode("shopItemBox_1"),
        m.top.findNode("shopItemBox_2"),
        m.top.findNode("shopItemBox_3")
    ]
    m.shopItemTitle_0 = m.top.findNode("shopItemTitle_0")
    m.shopItemTitle_1 = m.top.findNode("shopItemTitle_1")
    m.shopItemSub_0 = m.top.findNode("shopItemSub_0")
    m.shopItemSub_1 = m.top.findNode("shopItemSub_1")
    m.shopItemSub_2 = m.top.findNode("shopItemSub_2")
    m.shopItemPrice_0 = m.top.findNode("shopItemPrice_0")
    m.shopItemPrice_1 = m.top.findNode("shopItemPrice_1")
    m.shopItemPrice_2 = m.top.findNode("shopItemPrice_2")
    m.shopFeedbackMsg = m.top.findNode("shopFeedbackMsg")

    m.gameGlowTimer = m.top.findNode("gameGlowTimer")
    m.gameEnemyTimer = m.top.findNode("gameEnemyTimer")
    m.gameAttackTimer = m.top.findNode("gameAttackTimer")
    m.gameInvulnerableTimer = m.top.findNode("gameInvulnerableTimer")
    m.gameShieldTimer = m.top.findNode("gameShieldTimer")
    m.gameShieldCooldownTimer = m.top.findNode("gameShieldCooldownTimer")
end sub

sub onIntroTimerFired()
    if m.introFadeOutAnim <> invalid
        m.introFadeOutAnim.control = "start"
    end if
end sub

sub onIntroFadeStateChanged()
    if m.introFadeOutAnim <> invalid and m.introFadeOutAnim.state = "stopped"
        if m.introScreen <> invalid then m.introScreen.visible = false
    end if
end sub

' =======================================================
' ATUALIZAÇÃO DE CONTEÚDO E STATUS
' =======================================================

sub updateContinueWatching()
    lastEpId = m.storage.getLastEpisode()
    lastEp = m.dataManager.getEpisodeById(lastEpId)
    if lastEp = invalid then lastEp = m.episodes[0]
    m.currentContinueEp = lastEp

    prog = m.storage.getProgress(lastEp.id)
    isDone = m.storage.isCompleted(lastEp.id)

    if isDone
        m.menuItems[0].text = "▶  Continuar — EP. " + lastEp.number.toStr() + " (Assistido)"
        m.homeEpTitle.text = "EP. " + lastEp.number.toStr() + " — " + lastEp.title
        m.homeEpSynopsis.text = lastEp.synopsis
        m.homeProgressText.text = "Episódio concluído! Pronto para rever ou avançar."
        m.homeProgressFill.width = 400
        m.btnWatchNowLabel.text = "▶  REVER EPISÓDIO"
    else if prog.percent > 0
        m.menuItems[0].text = "▶  Continuar — EP. " + lastEp.number.toStr() + " (" + prog.percent.toStr() + "%)"
        m.homeEpTitle.text = "EP. " + lastEp.number.toStr() + " — " + lastEp.title
        m.homeEpSynopsis.text = lastEp.synopsis
        m.homeProgressText.text = "Progresso salvo: " + prog.percent.toStr() + "% (" + formatTime(prog.position) + ")"
        fillWidth = Fix((prog.percent / 100.0) * 400.0)
        m.homeProgressFill.width = fillWidth
        m.btnWatchNowLabel.text = "▶  CONTINUAR DE " + formatTime(prog.position)
    else
        m.menuItems[0].text = "▶  Continuar — EP. " + lastEp.number.toStr()
        m.homeEpTitle.text = "EP. " + lastEp.number.toStr() + " — " + lastEp.title
        m.homeEpSynopsis.text = lastEp.synopsis
        m.homeProgressText.text = "Comece sua aventura em Aether hoje!"
        m.homeProgressFill.width = 0
        m.btnWatchNowLabel.text = "▶  ASSISTIR AGORA"
    end if
end sub

sub updateEpisodeDetails()
    ep = m.episodes[m.focusedEpisodeIndex]
    m.detEpNumber.text = "EPISÓDIO " + ep.number.toStr()
    m.detEpTitle.text = ep.title
    m.detEpMeta.text = "Duração: " + ep.durationFormatted + "  •  Temporada 1  •  Classificação 10 anos"
    m.detEpSynopsis.text = ep.synopsis
    m.detEpPoster.uri = ep.thumbnail

    prog = m.storage.getProgress(ep.id)
    isDone = m.storage.isCompleted(ep.id)

    if ep.isLocked
        m.detEpStatus.text = "Status: 🔒 Em breve no canal Kurions"
        m.btnPlayEpisode.visible = false
        m.btnPlayEpisodeLabel.visible = false
        m.btnRestartEpisode.visible = false
        m.btnRestartEpisodeLabel.visible = false
    else
        m.btnPlayEpisode.visible = true
        m.btnPlayEpisodeLabel.visible = true
        m.btnRestartEpisode.visible = true
        m.btnRestartEpisodeLabel.visible = true

        if isDone
            m.detEpStatus.text = "Status: Concluído ✓"
            m.btnPlayEpisodeLabel.text = "▶  REVER EPISÓDIO"
        else if prog.percent > 0
            m.detEpStatus.text = "Status: Em andamento (" + prog.percent.toStr() + "% assistido)"
            m.btnPlayEpisodeLabel.text = "▶  CONTINUAR DE " + formatTime(prog.position)
        else
            m.detEpStatus.text = "Status: Não assistido"
            m.btnPlayEpisodeLabel.text = "▶  REPRODUZIR"
        end if
    end if

    ' Atualiza destaque dos cards de episódios
    for i = 0 to m.focusEpBoxes.count() - 1
        if i = m.focusedEpisodeIndex and m.focusArea = "content" and m.epSubFocus = "card"
            m.focusEpBoxes[i].color = "0x38BDF8FF"
        else
            m.focusEpBoxes[i].color = "0x00000000"
        end if
    end for

    ' Atualiza destaque dos botões do episódio
    if m.focusArea = "content" and m.epSubFocus = "btn_play"
        m.btnPlayEpisode.color = "0x38BDF8FF"
        m.btnRestartEpisode.color = "0x334155FF"
    else if m.focusArea = "content" and m.epSubFocus = "btn_restart"
        m.btnPlayEpisode.color = "0x22C55EFF"
        m.btnRestartEpisode.color = "0x38BDF8FF"
    else
        m.btnPlayEpisode.color = "0x22C55EFF"
        m.btnRestartEpisode.color = "0x334155FF"
    end if
end sub

sub updateLoreDetails()
    ' Alterna abas
    if m.loreActiveTab = 0
        m.tabBg_0.color = "0x1E3A8AFF"
        m.tabBorder_0.color = "0x38BDF8FF"
        m.tabBg_1.color = "0x0F172ACC"
        m.tabBorder_1.color = "0x334155FF"
        m.loreSectionColar.visible = true
        m.loreSectionDirigivel.visible = false

        ' Destaque do botão do Colar
        if m.focusArea = "content" and m.loreSubFocus = "colar_btn"
            m.btnColarPower.color = "0xFBBF24FF"
        else
            m.btnColarPower.color = "0x22C55EFF"
        end if
    else
        m.tabBg_0.color = "0x0F172ACC"
        m.tabBorder_0.color = "0x334155FF"
        m.tabBg_1.color = "0x1E3A8AFF"
        m.tabBorder_1.color = "0x22C55EFF"
        m.loreSectionColar.visible = false
        m.loreSectionDirigivel.visible = true

        updateRoomDetails()
    end if
end sub

sub updateRoomDetails()
    rooms = m.lore[1].rooms
    if rooms <> invalid and m.activeRoomIndex < rooms.count()
        r = rooms[m.activeRoomIndex]
        m.activeRoomName.text = r.name
        m.activeRoomDesc.text = r.desc
        m.activeRoomSecret.text = r.secret

        for i = 0 to m.roomBoxes.count() - 1
            if i = m.activeRoomIndex and m.focusArea = "content" and m.loreSubFocus = "room"
                m.roomBoxes[i].color = "0x22C55EFF"
            else if i = m.activeRoomIndex
                m.roomBoxes[i].color = "0x1E3A8AFF"
            else
                m.roomBoxes[i].color = "0x1E293BFF"
            end if
        end for
    end if
end sub

sub updateKurionDetails()
    k = m.kurions[m.focusedKurionIndex]
    m.detKPoster.uri = k.image
    m.detKName.text = k.name
    m.detKTypes.text = "Tipos: " + k.types + "   •   Som: '" + k.sound + "'"
    m.detKDesc.text = k.description

    habText = ""
    for each h in k.abilities
        habText = habText + "• " + h + chr(10)
    end for
    m.detKAbilities.text = habText

    for i = 0 to m.focusKBoxes.count() - 1
        if i = m.focusedKurionIndex and m.focusArea = "content"
            m.focusKBoxes[i].color = "0x22C55EFF"
        else
            m.focusKBoxes[i].color = "0x00000000"
        end if
    end for
end sub

sub updateCharacterDetails()
    c = m.characters[m.focusedCharIndex]
    m.detCharName.text = c.name
    m.detCharRole.text = c.role
    m.detCharDesc.text = c.description
    m.detCharKurions.text = "Kurions Conhecidos: " + c.knownKurions
    m.detCharEps.text = "Aparece em: " + c.episodes
    m.detCharPoster.uri = c.image

    for i = 0 to m.focusCharBoxes.count() - 1
        if i = m.focusedCharIndex and m.focusArea = "content"
            m.focusCharBoxes[i].color = "0x38BDF8FF"
        else
            m.focusCharBoxes[i].color = "0x00000000"
        end if
    end for
end sub

sub updateDeviceInfo()
    dev = m.api.getDeviceInfo()
    if dev <> invalid
        if dev.model <> invalid then m.devInfoModel.text = "Modelo: " + dev.model.toStr()
        if dev.version <> invalid then m.devInfoVersion.text = "Sistema: Roku OS " + dev.version.toStr()
        if dev.displayMode <> invalid then m.devInfoDisplay.text = "Resolução: " + dev.displayMode.toStr()
        if dev.isConnected then
            vidStr = ""
            if dev.videoMode <> invalid then vidStr = " (" + dev.videoMode.toStr() + ")"
            m.devInfoNet.text = "Rede: Conectada" + vidStr
            m.devInfoNet.color = "0x22C55EFF"
        else
            m.devInfoNet.text = "Rede: Modo Offline"
            m.devInfoNet.color = "0xEF4444FF"
        end if
    end if
end sub

sub refreshMenuSelectionVisuals()
    m.menuFocusHighlight.translation = [4, 16 + m.selectedMenuIndex * 70]
    m.menuFocusBar.translation = [4, 16 + m.selectedMenuIndex * 70]

    if m.focusArea = "sidebar"
        m.menuFocusHighlight.color = "0x1E3A8AFF"
        m.menuFocusBar.color = "0x38BDF8FF"
    else
        m.menuFocusHighlight.color = "0x0F294288"
        m.menuFocusBar.color = "0x64748BFF"
    end if

    for i = 0 to m.menuItems.count() - 1
        if i = m.selectedMenuIndex
            m.menuItems[i].color = "0xFFFFFFFF"
        else
            m.menuItems[i].color = "0x94A3B8FF"
        end if
    end for

    ' Alterna visibilidade da tela central
    for i = 0 to m.views.count() - 1
        m.views[i].visible = (i = m.selectedMenuIndex)
    end for
end sub

' =======================================================
' REPRODUÇÃO DE VÍDEO NATIVO (SCENEGRAPH VIDEO)
' =======================================================

sub playEpisode(ep as Object, startFromZero as Boolean)
    if ep = invalid or ep.isLocked
        print "[Kurions] Episódio indisponível ou bloqueado."
        return
    end if

    m.currentEpPlaying = ep
    print "[Kurions] Reproduzindo episódio: " + ep.title

    ' Configura metadados do nó de conteúdo
    content = CreateObject("roSGNode", "ContentNode")
    content.url = ep.videoUrl
    content.title = ep.title

    streamFmt = "hls"
    if ep.streamFormat <> invalid and ep.streamFormat <> "" then streamFmt = ep.streamFormat
    content.streamformat = streamFmt

    ' Configura legendas Closed Caption quando disponíveis
    if ep.subtitleTrack <> invalid and ep.subtitleTrack <> ""
        subTracks = []
        subTracks.push({
            Language: "pt",
            Description: "Português [CC]",
            TrackName: ep.subtitleTrack
        })
        content.subtitleTracks = subTracks
    end if

    m.videoPlayer.content = content

    ' Restaura posição de onde parou
    prog = m.storage.getProgress(ep.id)
    if not startFromZero and prog.position > 5 and prog.position < (ep.duration - 15)
        m.videoPlayer.seek = prog.position
    else
        m.videoPlayer.seek = 0
    end if

    ' Atualiza textos do HUD
    m.videoTitleLabel.text = "EP. " + ep.number.toStr() + " — " + ep.title
    m.videoSubtitleLabel.text = "Kurions: Saga Origens  •  Temporada 1"
    m.endModalEpName.text = ep.title

    if m.optEpTitle <> invalid then m.optEpTitle.text = "EP. " + ep.number.toStr() + " — " + ep.title
    if m.optEpDesc <> invalid then m.optEpDesc.text = ep.synopsis

    ' Alterna visibilidade da cena para o player
    m.videoContainer.visible = true
    m.videoPlayer.visible = true
    m.videoOverlay.visible = true
    m.endOfVideoModal.visible = false
    if m.videoOptionsModal <> invalid then m.videoOptionsModal.visible = false

    ' Inicia reprodução
    m.videoPlayer.control = "play"
    m.videoProgressTimer.control = "start"

    m.focusArea = "video"

    ' Inicia timer para recolher o HUD após 4 segundos
    m.videoOverlayTimer.control = "start"
end sub

sub stopVideoAndReturn()
    if m.videoPlayer.visible
        saveCurrentVideoProgress()
        m.videoPlayer.control = "stop"
        m.videoProgressTimer.control = "stop"
        m.videoOverlayTimer.control = "stop"
        m.videoPlayer.visible = false
        m.videoContainer.visible = false
        m.videoOverlay.visible = false
        m.endOfVideoModal.visible = false
        if m.videoBufferingBox <> invalid then m.videoBufferingBox.visible = false
        if m.videoOptionsModal <> invalid then m.videoOptionsModal.visible = false

        ' Atualiza o progresso na interface
        updateContinueWatching()
        updateEpisodeDetails()

        m.focusArea = "content"
    end if
end sub

sub onVideoPositionChanged()
    if m.videoPlayer.visible and m.videoPlayer.position <> invalid
        currentPos = Fix(m.videoPlayer.position)
        totalDur = Fix(m.videoPlayer.duration)
        if totalDur <= 0 and m.currentEpPlaying <> invalid then totalDur = m.currentEpPlaying.duration

        m.videoTimeCurrent.text = formatTime(currentPos)
        if totalDur > 0
            m.videoTimeTotal.text = formatTime(totalDur)
            percent = (currentPos / totalDur)
            if percent > 1.0 then percent = 1.0
            m.videoTrackFill.width = Fix(percent * 1560.0)
        end if
    end if
end sub

sub onVideoDurationChanged()
    totalDur = Fix(m.videoPlayer.duration)
    if totalDur > 0
        m.videoTimeTotal.text = formatTime(totalDur)
    end if
end sub

sub onVideoStateChanged()
    state = m.videoPlayer.state
    print "[Kurions Video State] " + state

    if state = "buffering"
        if m.videoBufferingBox <> invalid then m.videoBufferingBox.visible = true
    else
        if m.videoBufferingBox <> invalid then m.videoBufferingBox.visible = false
    end if

    if state = "finished"
        ' Episódio concluído!
        m.videoProgressTimer.control = "stop"
        m.storage.markCompleted(m.currentEpPlaying.id)
        updateContinueWatching()
        updateEpisodeDetails()

        ' Exibe modal de fim de episódio
        m.videoOverlay.visible = false
        m.endOfVideoModal.visible = true
        m.focusArea = "video_end"
        m.videoEndButtonIndex = 0
        updateVideoEndModalFocus()
    else if state = "error"
        print "[Kurions Video Error] Erro ao reproduzir stream."
        stopVideoAndReturn()
    end if
end sub

sub saveCurrentVideoProgress()
    if m.videoPlayer.visible and m.currentEpPlaying <> invalid
        currentPos = Fix(m.videoPlayer.position)
        totalDur = Fix(m.videoPlayer.duration)
        if totalDur <= 0 then totalDur = m.currentEpPlaying.duration

        if currentPos > 2
            m.storage.saveProgress(m.currentEpPlaying.id, currentPos, totalDur)
        end if
    end if
end sub

sub showVideoOverlayBriefly()
    m.videoOverlay.visible = true
    m.videoOverlayTimer.control = "stop"
    m.videoOverlayTimer.control = "start"
end sub

sub hideVideoOverlay()
    if m.focusArea = "video"
        m.videoOverlay.visible = false
    end if
end sub

sub updateVideoEndModalFocus()
    if m.videoEndButtonIndex = 0
        m.btnNextEp.color = "0x38BDF8FF"
        m.btnReplayEp.color = "0x334155FF"
    else
        m.btnNextEp.color = "0x22C55EFF"
        m.btnReplayEp.color = "0x38BDF8FF"
    end if
end sub

' =======================================================
' NAVEGAÇÃO COM CONTROLE REMOTO (D-PAD, OK, BACK, OPTIONS)
' =======================================================

function onKeyEvent(key as String, press as Boolean) as Boolean
    handled = false
    if not press then return false

    ' 1. Teclas durante a reprodução de Vídeo
    if m.focusArea = "video"
        if key = "back"
            if m.videoOptionsModal <> invalid and m.videoOptionsModal.visible
                m.videoOptionsModal.visible = false
                return true
            end if
            stopVideoAndReturn()
            return true
        else if key = "options" or key = "info"
            ' Tecla * do controle remoto Roku
            if m.videoOptionsModal <> invalid
                m.videoOptionsModal.visible = not m.videoOptionsModal.visible
            end if
            return true
        else if key = "OK" or key = "play"
            if m.videoOptionsModal <> invalid and m.videoOptionsModal.visible
                m.videoOptionsModal.visible = false
                return true
            end if

            if m.videoPlayer.state = "playing"
                m.videoPlayer.control = "pause"
                showVideoOverlayBriefly()
            else if m.videoPlayer.state = "paused"
                m.videoPlayer.control = "resume"
                showVideoOverlayBriefly()
            end if
            return true
        else if key = "replay"
            ' Volta 10 segundos
            newPos = m.videoPlayer.position - 10
            if newPos < 0 then newPos = 0
            m.videoPlayer.seek = newPos
            showVideoOverlayBriefly()
            return true
        else if key = "right" or key = "fastforward"
            newPos = m.videoPlayer.position + 15
            if newPos < m.videoPlayer.duration then m.videoPlayer.seek = newPos
            showVideoOverlayBriefly()
            return true
        else if key = "left" or key = "rewind"
            newPos = m.videoPlayer.position - 15
            if newPos < 0 then newPos = 0
            m.videoPlayer.seek = newPos
            showVideoOverlayBriefly()
            return true
        else if key = "up" or key = "down"
            showVideoOverlayBriefly()
            return true
        end if
        return false
    end if

    ' 2. Teclas no Modal de Fim do Vídeo
    if m.focusArea = "video_end"
        if key = "back"
            stopVideoAndReturn()
            return true
        else if key = "left" or key = "right"
            m.videoEndButtonIndex = (m.videoEndButtonIndex + 1) mod 2
            updateVideoEndModalFocus()
            return true
        else if key = "OK"
            if m.videoEndButtonIndex = 0
                ' Próximo episódio
                nextNum = m.currentEpPlaying.number + 1
                nextEp = invalid
                for each e in m.episodes
                    if e.number = nextNum and not e.isLocked
                        nextEp = e
                        exit for
                    end if
                end for

                if nextEp <> invalid
                    playEpisode(nextEp, true)
                else
                    stopVideoAndReturn()
                end if
            else
                ' Repetir episódio
                playEpisode(m.currentEpPlaying, true)
            end if
            return true
        end if
        return false
    end if

    ' 2.5. Teclas durante o Mini-Jogo Zelda
    if m.focusArea = "game"
        return handleGameKey(key)
    end if

    ' 3. Navegação no Menu Lateral (Sidebar)
    if m.focusArea = "sidebar"
        if key = "up"
            if m.selectedMenuIndex > 0
                m.selectedMenuIndex = m.selectedMenuIndex - 1
                refreshMenuSelectionVisuals()
            end if
            return true
        else if key = "down"
            if m.selectedMenuIndex < m.menuItems.count() - 1
                m.selectedMenuIndex = m.selectedMenuIndex + 1
                refreshMenuSelectionVisuals()
            end if
            return true
        else if key = "right" or key = "OK"
            ' Se for o mini-jogo (índice 2)
            if m.selectedMenuIndex = 2
                m.focusArea = "game"
                refreshMenuSelectionVisuals()
                return true
            end if
            ' Entra na área de conteúdo padrão
            m.focusArea = "content"
            refreshMenuSelectionVisuals()
            updateEpisodeDetails()
            updateKurionDetails()
            updateCharacterDetails()
            updateLoreDetails()
            return true
        end if
        return false
    end if

    ' 4. Navegação na Área de Conteúdo
    if m.focusArea = "content"
        ' Tecla BACK sempre retorna para o Menu Lateral
        if key = "back"
            if m.selectedMenuIndex = 1 and m.epSubFocus <> "card"
                m.epSubFocus = "card"
                updateEpisodeDetails()
                return true
            else if m.selectedMenuIndex = 3 and m.loreSubFocus <> "tab"
                m.loreSubFocus = "tab"
                updateLoreDetails()
                return true
            else
                m.focusArea = "sidebar"
                refreshMenuSelectionVisuals()
                updateEpisodeDetails()
                updateKurionDetails()
                updateCharacterDetails()
                updateLoreDetails()
                return true
            end if
        end if

        ' Interações específicas por tela:
        if m.selectedMenuIndex = 0
            ' Home / Continuar Assistindo
            if key = "OK"
                playEpisode(m.currentContinueEp, false)
                return true
            else if key = "left"
                m.focusArea = "sidebar"
                refreshMenuSelectionVisuals()
                return true
            end if

        else if m.selectedMenuIndex = 1
            ' Tela de Episódios
            if m.epSubFocus = "card"
                if key = "right"
                    if m.focusedEpisodeIndex < m.episodes.count() - 1
                        m.focusedEpisodeIndex = m.focusedEpisodeIndex + 1
                        updateEpisodeDetails()
                    end if
                    return true
                else if key = "left"
                    if m.focusedEpisodeIndex > 0
                        m.focusedEpisodeIndex = m.focusedEpisodeIndex - 1
                        updateEpisodeDetails()
                    else
                        m.focusArea = "sidebar"
                        refreshMenuSelectionVisuals()
                    end if
                    return true
                else if key = "down"
                    ep = m.episodes[m.focusedEpisodeIndex]
                    if not ep.isLocked
                        m.epSubFocus = "btn_play"
                        updateEpisodeDetails()
                    end if
                    return true
                else if key = "OK"
                    ep = m.episodes[m.focusedEpisodeIndex]
                    if not ep.isLocked
                        playEpisode(ep, false)
                    end if
                    return true
                end if
            else if m.epSubFocus = "btn_play"
                if key = "right"
                    m.epSubFocus = "btn_restart"
                    updateEpisodeDetails()
                    return true
                else if key = "up"
                    m.epSubFocus = "card"
                    updateEpisodeDetails()
                    return true
                else if key = "left"
                    m.focusArea = "sidebar"
                    refreshMenuSelectionVisuals()
                    return true
                else if key = "OK"
                    playEpisode(m.episodes[m.focusedEpisodeIndex], false)
                    return true
                end if
            else if m.epSubFocus = "btn_restart"
                if key = "left"
                    m.epSubFocus = "btn_play"
                    updateEpisodeDetails()
                    return true
                else if key = "up"
                    m.epSubFocus = "card"
                    updateEpisodeDetails()
                    return true
                else if key = "OK"
                    playEpisode(m.episodes[m.focusedEpisodeIndex], true)
                    return true
                end if
            end if

        else if m.selectedMenuIndex = 3
            ' Tela de História & Lore
            if m.loreSubFocus = "tab"
                if key = "right" and m.loreActiveTab = 0
                    m.loreActiveTab = 1
                    updateLoreDetails()
                    return true
                else if key = "left" and m.loreActiveTab = 1
                    m.loreActiveTab = 0
                    updateLoreDetails()
                    return true
                else if key = "left" and m.loreActiveTab = 0
                    m.focusArea = "sidebar"
                    refreshMenuSelectionVisuals()
                    return true
                else if key = "down"
                    if m.loreActiveTab = 0
                        m.loreSubFocus = "colar_btn"
                    else
                        m.loreSubFocus = "room"
                    end if
                    updateLoreDetails()
                    return true
                end if
            else if m.loreSubFocus = "colar_btn"
                if key = "up"
                    m.loreSubFocus = "tab"
                    updateLoreDetails()
                    return true
                else if key = "left"
                    m.focusArea = "sidebar"
                    refreshMenuSelectionVisuals()
                    return true
                else if key = "OK"
                    ' Canalizar poder do Colar!
                    m.btnColarPower.color = "0x38BDF8FF"
                    m.colarRevelationText.text = "⚡ O Colar do Começo pulsa intensamente! As correntes de Aether se alinham e revelam as coordenadas secretas onde o Grande Dirigível aguarda Koli e Pagonix."
                    return true
                end if
            else if m.loreSubFocus = "room"
                if key = "right"
                    if m.activeRoomIndex < 4
                        m.activeRoomIndex = m.activeRoomIndex + 1
                        updateRoomDetails()
                    end if
                    return true
                else if key = "left"
                    if m.activeRoomIndex > 0
                        m.activeRoomIndex = m.activeRoomIndex - 1
                        updateRoomDetails()
                    else
                        m.focusArea = "sidebar"
                        refreshMenuSelectionVisuals()
                    end if
                    return true
                else if key = "up"
                    m.loreSubFocus = "tab"
                    updateLoreDetails()
                    return true
                end if
            end if

        else if m.selectedMenuIndex = 4
            ' Tela de Kurions
            if key = "right"
                if m.focusedKurionIndex < m.kurions.count() - 1
                    m.focusedKurionIndex = m.focusedKurionIndex + 1
                    updateKurionDetails()
                end if
                return true
            else if key = "left"
                if m.focusedKurionIndex > 0
                    m.focusedKurionIndex = m.focusedKurionIndex - 1
                    updateKurionDetails()
                else
                    m.focusArea = "sidebar"
                    refreshMenuSelectionVisuals()
                end if
                return true
            end if

        else if m.selectedMenuIndex = 5
            ' Tela de Personagens
            if key = "right"
                if m.focusedCharIndex < m.characters.count() - 1
                    m.focusedCharIndex = m.focusedCharIndex + 1
                    updateCharacterDetails()
                end if
                return true
            else if key = "left"
                if m.focusedCharIndex > 0
                    m.focusedCharIndex = m.focusedCharIndex - 1
                    updateCharacterDetails()
                else
                    m.focusArea = "sidebar"
                    refreshMenuSelectionVisuals()
                end if
                return true
            end if

        else if m.selectedMenuIndex = 6
            ' Configurações
            if key = "left"
                m.focusArea = "sidebar"
                refreshMenuSelectionVisuals()
                return true
            else if key = "OK"
                m.storage.clearAllData()
                m.settingsMsg.text = "Dados e histórico apagados com sucesso!"
                updateContinueWatching()
                updateEpisodeDetails()
                return true
            end if
        end if
    end if

    return handled
end function

' Formatação de segundos em MM:SS ou HH:MM:SS
function formatTime(totalSeconds as Integer) as String
    if totalSeconds <= 0 then return "00:00"

    hours = Fix(totalSeconds / 3600)
    minutes = Fix((totalSeconds mod 3600) / 60)
    seconds = totalSeconds mod 60

    minStr = minutes.toStr()
    if Len(minStr) = 1 then minStr = "0" + minStr

    secStr = seconds.toStr()
    if Len(secStr) = 1 then secStr = "0" + secStr

    if hours > 0
        hourStr = hours.toStr()
        if Len(hourStr) = 1 then hourStr = "0" + hourStr
        return hourStr + ":" + minStr + ":" + secStr
    end if

    return minStr + ":" + secStr
end function

' =======================================================
' SISTEMA DO JOGO: KURIONS — A LENDA DE AETHER (5 FASES)
' =======================================================

sub initGameSystem()
    ' 1. Cria dinamicamente os 120 nós Poster da grade de tiles (15x8)
    m.gameTiles = []
    if m.gameGridGroup <> invalid and m.gameTiles.count() = 0
        for r = 0 to 7
            for c = 0 to 14
                tile = m.gameGridGroup.createChild("Poster")
                tile.width = 80
                tile.height = 70
                tile.translation = [c * 80, r * 70]
                tile.loadSync = true
                m.gameTiles.push(tile)
            end for
        end for
    end if

    ' 2. Metadados e Títulos das 20 Fases
    m.stageNames = [
        "O Bosque das Origens",
        "O Templo Subterrâneo",
        "O Pântano da Névoa Escura",
        "As Galerias da Cripta Esquecida",
        "O Portão Ancestral da Floresta",
        "A Entrada das Minas de Quartzo",
        "O Abismo Ressonante",
        "A Forja dos Cristais Puros",
        "Os Corredores Subterrâneos",
        "A Câmara do Golem Titânico",
        "O Convés Inferior do Dirigível",
        "As Gôndolas Exteriores",
        "A Sala de Máquinas de Aether",
        "A Ponte de Comando Invadida",
        "O Confronto com o Capitão Sombrio",
        "O Mirante dos Ventos Celestes",
        "O Labirinto das Correntes de Ar",
        "O Templo dos Kurions Alados",
        "A Ponte Quebrada de Zéfiro",
        "O Covil da Serpente dos Ventos",
        "A Entrada das Cavernas Ígneas",
        "O Rio de Lava Cristalizada",
        "A Fundição Ancestral de Aether",
        "A Câmara dos Guardiões de Fogo",
        "O Colosso de Magma Corrompido",
        "As Ruínas Submersas de Aether",
        "A Eclusa Central das Correntes",
        "O Santuário dos Corais Sagrados",
        "A Fossa das Sombras Profundas",
        "O Terrível Leviatã Abissal",
        "Os Portões de Ferro Negro",
        "Os Corredores das Prisões",
        "A Sala dos Reatores Sombrios",
        "O Arsenal dos Oficiais de Elite",
        "O General Supremo da Dark Team",
        "A Fenda Dimensional de Aether",
        "A Escadaria das Estrelas Perdidas",
        "O Círculo dos Quatro Elementos",
        "A Antecâmara do Infinito",
        "O Santuário Cósmico — Batalha Final"
    ]

    ' 3. Mapas das 20 Fases (15x8)
    ' W: Parede, .: Chão, D: Portal, C: Baú, T: Tábua, A: Altar, B: Barreira, S: Switch, X: Espinho, K: Gaiola, M: Motor
    m.stageMaps = [
        [
            "WWWWWWWDWWWWWWW",
            "W.............W",
            "W...WW...C....W",
            "W...WW........W",
            "W....T........W",
            "W.............W",
            "W.............W",
            "WWWWWWWWWWWWWWW"
        ],
        [
            "WWWWWWWWWWWWWWW",
            "W.............W",
            "W..S......C...W",
            "W........B....D",
            "W........B....W",
            "W.C...........W",
            "W.............W",
            "WWWWWWWWWWWWWWW"
        ],
        [
            "WWWWWWWWWWWWWWW",
            "W.............W",
            "W...X...K.....W",
            "W...X.....B...D",
            "W...X.....B...W",
            "W..A......C...W",
            "W.............W",
            "WWWWWWWWWWWWWWW"
        ],
        [
            "WWWWWWWWWWWWWWW",
            "W.C..W...W..C.W",
            "W....W...W....W",
            "W..S.W...W.S..W",
            "W....B...B....D",
            "W.............W",
            "W.............W",
            "WWWWWWWWWWWWWWW"
        ],
        [
            "WWWWWWWDWWWWWWW",
            "W.............W",
            "W..A.......A..W",
            "W.............W",
            "W.....B.B.....W",
            "W..S.......S..W",
            "W.............W",
            "WWWWWWWWWWWWWWW"
        ],
        [
            "WWWWWWWWWWWWWWW",
            "W.....X.......W",
            "W.WWW.X.WWWWW.W",
            "W...W...W...W.D",
            "W.C.W.X.W.C.W.W",
            "W...W.X.W...W.W",
            "W.............W",
            "WWWWWWWWWWWWWWW"
        ],
        [
            "WWWWWWWWWWWWWWW",
            "W.S...........W",
            "W.XXXXXXXXXXX.W",
            "W.B...........W",
            "W.B.XXXXXXXXX.W",
            "W.C...........D",
            "W.............W",
            "WWWWWWWWWWWWWWW"
        ],
        [
            "WWWWWWWDWWWWWWW",
            "W.............W",
            "W..A.......K..W",
            "W...WW.B.WW...W",
            "W...WW.B.WW...W",
            "W..S.......C..W",
            "W.............W",
            "WWWWWWWWWWWWWWW"
        ],
        [
            "WWWWWWWWWWWWWWW",
            "W.C...W...W...W",
            "W.X.X.W...W...D",
            "W.S...W.B.W...W",
            "W.W.WWW.B.WWW.W",
            "W.............W",
            "W.............W",
            "WWWWWWWWWWWWWWW"
        ],
        [
            "WWWWWWWDWWWWWWW",
            "W.............W",
            "W..X..A.A..X..W",
            "W.............W",
            "W.............W",
            "W..C.......C..W",
            "W.............W",
            "WWWWWWWWWWWWWWW"
        ],
        [
            "WWWWWWWWWWWWWWW",
            "W..M.......M..W",
            "W.............W",
            "W.............W",
            "W.............D",
            "W.............W",
            "W.............W",
            "WWWWWWWWWWWWWWW"
        ],
        [
            "WWWWWWWWWWWWWWW",
            "W.C.........C.W",
            "W.XXXXXXXXXXX.W",
            "W.............D",
            "W.XXXXXXXXXXX.W",
            "W...K.....S...W",
            "W.............W",
            "WWWWWWWWWWWWWWW"
        ],
        [
            "WWWWWWWWWWWWWWW",
            "W..M...M...M..W",
            "W.............W",
            "W..WWWW.WWWW..W",
            "W..S...B...C..D",
            "W......B......W",
            "W.............W",
            "WWWWWWWWWWWWWWW"
        ],
        [
            "WWWWWWWDWWWWWWW",
            "W.............W",
            "W..K.......C..W",
            "W....XXXXX....W",
            "W....XXXXX....W",
            "W..A.......S..W",
            "W.............W",
            "WWWWWWWWWWWWWWW"
        ],
        [
            "WWWWWWWDWWWWWWW",
            "W.............W",
            "W..A.......A..W",
            "W.....B.B.....W",
            "W.............W",
            "W..S.......S..W",
            "W.............W",
            "WWWWWWWWWWWWWWW"
        ],
        [
            "WWWWWWWWWWWWWWW",
            "W.C.........C.W",
            "W..X...X...X..W",
            "W.............D",
            "W..X...X...X..W",
            "W.............W",
            "W.............W",
            "WWWWWWWWWWWWWWW"
        ],
        [
            "WWWWWWWDWWWWWWW",
            "W.............W",
            "W.WW..B.B..WW.W",
            "W.S...B.B...S.W",
            "W.WW..B.B..WW.W",
            "W.C.........C.W",
            "W.............W",
            "WWWWWWWWWWWWWWW"
        ],
        [
            "WWWWWWWWWWWWWWW",
            "W..A...K...A..W",
            "W.............W",
            "W.XXXXXXXXXXX.W",
            "W.............D",
            "W..C.......C..W",
            "W.............W",
            "WWWWWWWWWWWWWWW"
        ],
        [
            "WWWWWWWDWWWWWWW",
            "W.C.........C.W",
            "W..X..A.A..X..W",
            "W.............W",
            "W..S..B.B..S..W",
            "W.............W",
            "W.............W",
            "WWWWWWWWWWWWWWW"
        ],
        [
            "WWWWWWWDWWWWWWW",
            "W.............W",
            "W..A.......A..W",
            "W....WW.WW....W",
            "W....WW.WW....W",
            "W..S.......S..W",
            "W.............W",
            "WWWWWWWWWWWWWWW"
        ],
        [
            "WWWWWWWWWWWWWWW",
            "W.C...W.W...C.W",
            "W..X..W.W..X..W",
            "W.............D",
            "W..X..W.W..X..W",
            "W.....W.W.....W",
            "W.............W",
            "WWWWWWWWWWWWWWW"
        ],
        [
            "WWWWWWWDWWWWWWW",
            "W.............W",
            "W.XXXXXXXXXXX.W",
            "W.S.........B.W",
            "W.XXXXXXXXX.B.W",
            "W.C...........W",
            "W.............W",
            "WWWWWWWWWWWWWWW"
        ],
        [
            "WWWWWWWWWWWWWWW",
            "W..M...M...M..W",
            "W.WWWW...WWWW.W",
            "W.............D",
            "W.WWWW...WWWW.W",
            "W..C.......C..W",
            "W.............W",
            "WWWWWWWWWWWWWWW"
        ],
        [
            "WWWWWWWDWWWWWWW",
            "W.............W",
            "W..A...K...A..W",
            "W...XXXXXXX...W",
            "W...XXXXXXX...W",
            "W..S.......S..W",
            "W.............W",
            "WWWWWWWWWWWWWWW"
        ],
        [
            "WWWWWWWDWWWWWWW",
            "W.............W",
            "W..A.......A..W",
            "W...X.B.B.X...W",
            "W.............W",
            "W..C.......C..W",
            "W.............W",
            "WWWWWWWWWWWWWWW"
        ],
        [
            "WWWWWWWWWWWWWWW",
            "W.C.........C.W",
            "W...WW...WW...W",
            "W...WW...WW...D",
            "W.............W",
            "W...WW...WW...W",
            "W.............W",
            "WWWWWWWWWWWWWWW"
        ],
        [
            "WWWWWWWDWWWWWWW",
            "W.............W",
            "W..S.......S..W",
            "W....W.B.W....W",
            "W....W.B.W....W",
            "W..C.......C..W",
            "W.............W",
            "WWWWWWWWWWWWWWW"
        ],
        [
            "WWWWWWWWWWWWWWW",
            "W..A.......A..W",
            "W.............W",
            "W.XXXXXXXXXXX.W",
            "W.............D",
            "W..K.......C..W",
            "W.............W",
            "WWWWWWWWWWWWWWW"
        ],
        [
            "WWWWWWWDWWWWWWW",
            "W.............W",
            "W.WW.WW.WW.WW.W",
            "W.............W",
            "W.WW.WW.WW.WW.W",
            "W.C.........C.W",
            "W.............W",
            "WWWWWWWWWWWWWWW"
        ],
        [
            "WWWWWWWDWWWWWWW",
            "W.............W",
            "W..A.......A..W",
            "W.............W",
            "W.....B.B.....W",
            "W..S.......S..W",
            "W.............W",
            "WWWWWWWWWWWWWWW"
        ],
        [
            "WWWWWWWWWWWWWWW",
            "W.C...W.W...C.W",
            "W.S...W.W...S.W",
            "W.....B.B.....D",
            "W.W.WWWWWWW.W.W",
            "W.............W",
            "W.............W",
            "WWWWWWWWWWWWWWW"
        ],
        [
            "WWWWWWWDWWWWWWW",
            "W.............W",
            "W.K.W.K.W.K.W.W",
            "W...W...W...W.W",
            "W.X.W.X.W.X.W.W",
            "W.............W",
            "W.............W",
            "WWWWWWWWWWWWWWW"
        ],
        [
            "WWWWWWWWWWWWWWW",
            "W..M...M...M..W",
            "W.W.W.W.W.W.W.W",
            "W.............D",
            "W.W.W.W.W.W.W.W",
            "W..S.......C..W",
            "W.............W",
            "WWWWWWWWWWWWWWW"
        ],
        [
            "WWWWWWWDWWWWWWW",
            "W.............W",
            "W.C.........C.W",
            "W...XXXXXXX...W",
            "W...XXXXXXX...W",
            "W..S.......S..W",
            "W.............W",
            "WWWWWWWWWWWWWWW"
        ],
        [
            "WWWWWWWDWWWWWWW",
            "W.............W",
            "W..A.......A..W",
            "W....WW.WW....W",
            "W....BB.BB....W",
            "W..S.......S..W",
            "W.............W",
            "WWWWWWWWWWWWWWW"
        ],
        [
            "WWWWWWWWWWWWWWW",
            "W.C.........C.W",
            "W..X...X...X..W",
            "W.............D",
            "W..X...X...X..W",
            "W.C.........C.W",
            "W.............W",
            "WWWWWWWWWWWWWWW"
        ],
        [
            "WWWWWWWDWWWWWWW",
            "W.............W",
            "W.WW..B.B..WW.W",
            "W.S...B.B...S.W",
            "W.WW..B.B..WW.W",
            "W.C.........C.W",
            "W.............W",
            "WWWWWWWWWWWWWWW"
        ],
        [
            "WWWWWWWWWWWWWWW",
            "W..A...A...A..W",
            "W.............W",
            "W.XXXXXXXXXXX.W",
            "W.............D",
            "W..K...A...C..W",
            "W.............W",
            "WWWWWWWWWWWWWWW"
        ],
        [
            "WWWWWWWDWWWWWWW",
            "W.C.........C.W",
            "W..X..A.A..X..W",
            "W.............W",
            "W..S..B.B..S..W",
            "W.............W",
            "W.............W",
            "WWWWWWWWWWWWWWW"
        ],
        [
            "WWWWWWWDWWWWWWW",
            "W.............W",
            "W..A.......A..W",
            "W.............W",
            "W.............W",
            "W..A.......A..W",
            "W.............W",
            "WWWWWWWWWWWWWWW"
        ]
    ]

    ' 4. Estado Global do Jogo
    m.gameCurrentStage = 1
    m.gameScore = 0
    m.shardsCount = 0
    m.kurionsRescued = 0

    ' Carrega dados salvos da persistência (Gemas, Vida Máxima, Alcance, Poções e Checkpoint de Fase)
    gData = m.storage.getGameData()
    m.gameGems = gData.gems
    m.maxHp = gData.maxHp
    if m.maxHp < 3 then m.maxHp = 3
    m.beamRange = gData.beamRange
    if m.beamRange < 1 then m.beamRange = 1
    m.potionsCount = gData.potions
    m.highestStage = gData.highestStage
    if m.highestStage < 1 then m.highestStage = 1

    m.shieldActive = false
    m.shieldCooldown = false
    m.gameShopModalOpen = false
    m.shopFocusIndex = 0

    ' Inicia o loop de movimentação de monstros
    if m.gameEnemyTimer <> invalid then m.gameEnemyTimer.control = "start"

    startStage = m.highestStage
    if startStage > 40 then startStage = 40
    loadGameStage(startStage)
end sub

sub loadGameStage(stageNum as Integer)
    m.gameCurrentStage = stageNum
    m.hp = m.maxHp
    m.isInvulnerable = false
    m.playerDir = "up"
    m.hasKey = false
    m.stageClear = false

    ' Atualiza checkpoint salvo
    if stageNum > m.highestStage
        m.highestStage = stageNum
        m.storage.saveGameData(m.gameGems, m.maxHp, m.beamRange, m.potionsCount, m.highestStage)
    end if

    ' Fecha modais
    if m.gameOverModal <> invalid then m.gameOverModal.visible = false
    if m.gameStageClearModal <> invalid then m.gameStageClearModal.visible = false
    if m.gameVictoryModal <> invalid then m.gameVictoryModal.visible = false
    if m.gameShopModal <> invalid then m.gameShopModal.visible = false
    m.gameOverModalOpen = false
    m.gameStageClearModalOpen = false
    m.gameVictoryModalOpen = false
    m.gameShopModalOpen = false

    ' Reseta escudo de Pagonix
    m.shieldActive = false
    if m.gamePagonixShield <> invalid then m.gamePagonixShield.visible = false

    ' Reseta drops na tela
    m.drops = []
    renderDrops()

    ' Estados por fase
    m.stageChestOpened = false
    m.stageSwitchActivated = false
    m.stageAltarActivated = false
    m.stageBarrierCleared = false
    m.stageKurionRescued = false
    m.stageMotorsCount = 0
    m.stageAltarsCount = 0
    m.stageBossDefeated = false

    ' Configura Monstros e Mapa da Fase
    m.monsters = []
    m.currMap = m.stageMaps[stageNum - 1]

    if stageNum = 1
        m.playerX = 3: m.playerY = 5: m.pagonixX = 2: m.pagonixY = 5
        m.monsters.push({ id: 0, type: "shadow", x: 8, y: 3, dirX: 1, minX: 6, maxX: 11, alive: true, hp: 1, image: "pkg:/images/game/monster_shadow.png" })
        setGameDialog("KOLI & PAGONIX", "pkg:/images/characters/koli.png", "Koli: 'O Bosque das Origens foi invadido pela Dark Team! Purifique o espectro com o Colar (OK) e alcance o portal norte!'")

    else if stageNum = 2
        m.playerX = 2: m.playerY = 6: m.pagonixX = 1: m.pagonixY = 6
        m.monsters.push({ id: 0, type: "grunt", x: 6, y: 3, dirX: 1, minX: 4, maxX: 8, alive: true, hp: 1, image: "pkg:/images/game/monster_grunt.png" })
        m.monsters.push({ id: 1, type: "grunt", x: 11, y: 4, dirX: -1, minX: 10, maxX: 13, alive: true, hp: 1, image: "pkg:/images/game/monster_grunt.png" })
        setGameDialog("PAGONIX", "pkg:/images/kurions/pagonix.png", "Pagonix: 'PAGO! Soldados patrulham a cripta! Pise no interruptor (S) para abaixar a barreira!'")

    else if stageNum = 3
        m.playerX = 1: m.playerY = 3: m.pagonixX = 1: m.pagonixY = 4
        m.monsters.push({ id: 0, type: "golem", x: 8, y: 4, dirX: 1, minX: 6, maxX: 9, alive: true, hp: 2, image: "pkg:/images/game/monster_golem.png" })
        m.monsters.push({ id: 1, type: "grunt", x: 12, y: 2, dirX: -1, minX: 11, maxX: 13, alive: true, hp: 1, image: "pkg:/images/game/monster_grunt.png" })
        setGameDialog("KOLI", "pkg:/images/characters/koli.png", "Koli: 'Um Kurion bebê está preso na gaiola! Cuidado com os espinhos e liberte-o com o Colar (OK)!'")

    else if stageNum = 4
        m.playerX = 2: m.playerY = 6: m.pagonixX = 1: m.pagonixY = 6
        m.monsters.push({ id: 0, type: "grunt", x: 3, y: 2, dirX: 1, minX: 2, maxX: 4, alive: true, hp: 1, image: "pkg:/images/game/monster_grunt.png" })
        m.monsters.push({ id: 1, type: "grunt", x: 11, y: 2, dirX: -1, minX: 10, maxX: 12, alive: true, hp: 1, image: "pkg:/images/game/monster_grunt.png" })
        m.monsters.push({ id: 2, type: "shadow", x: 7, y: 5, dirX: 1, minX: 5, maxX: 9, alive: true, hp: 1, image: "pkg:/images/game/monster_shadow.png" })
        setGameDialog("KOLI & PAGONIX", "pkg:/images/characters/koli.png", "Koli: 'As galerias têm dois interruptores ancestrais! Precisamos acionar ambos para abrir passagem!'")

    else if stageNum = 5
        m.playerX = 7: m.playerY = 6: m.pagonixX = 7: m.pagonixY = 7
        m.monsters.push({ id: 0, type: "shadow", x: 7, y: 3, dirX: 1, minX: 6, maxX: 8, alive: true, hp: 3, image: "pkg:/images/game/monster_shadow.png" })
        m.monsters.push({ id: 1, type: "shadow", x: 3, y: 3, dirX: 1, minX: 2, maxX: 4, alive: true, hp: 1, image: "pkg:/images/game/monster_shadow.png" })
        setGameDialog("GUARDIÃO CORROMPIDO", "pkg:/images/game/monster_shadow.png", "GUARDIÃO: 'Nenhum mortal passará pelo Portão!' — Pagonix: 'Use o Escudo de Cristal (↺) para repelir o Guardião!'")

    else if stageNum = 6
        m.playerX = 1: m.playerY = 6: m.pagonixX = 1: m.pagonixY = 5
        m.monsters.push({ id: 0, type: "grunt", x: 5, y: 3, dirX: 1, minX: 4, maxX: 6, alive: true, hp: 1, image: "pkg:/images/game/monster_grunt.png" })
        m.monsters.push({ id: 1, type: "grunt", x: 11, y: 3, dirX: -1, minX: 10, maxX: 12, alive: true, hp: 1, image: "pkg:/images/game/monster_grunt.png" })
        setGameDialog("KOLI", "pkg:/images/characters/koli.png", "Koli: 'Bem-vindos às Minas de Quartzo! Os caminhos são estreitos e os soldados montaram emboscadas!'")

    else if stageNum = 7
        m.playerX = 1: m.playerY = 6: m.pagonixX = 1: m.pagonixY = 5
        m.monsters.push({ id: 0, type: "golem", x: 6, y: 3, dirX: 1, minX: 5, maxX: 8, alive: true, hp: 2, image: "pkg:/images/game/monster_golem.png" })
        m.monsters.push({ id: 1, type: "shadow", x: 10, y: 4, dirX: -1, minX: 9, maxX: 12, alive: true, hp: 1, image: "pkg:/images/game/monster_shadow.png" })
        setGameDialog("PAGONIX", "pkg:/images/kurions/pagonix.png", "Pagonix: 'PAGO! Pise no interruptor a noroeste para criar a ponte sobre os espinhos de cristal!'")

    else if stageNum = 8
        m.playerX = 7: m.playerY = 6: m.pagonixX = 7: m.pagonixY = 7
        m.monsters.push({ id: 0, type: "grunt", x: 4, y: 4, dirX: 1, minX: 3, maxX: 5, alive: true, hp: 1, image: "pkg:/images/game/monster_grunt.png" })
        m.monsters.push({ id: 1, type: "shadow", x: 10, y: 4, dirX: -1, minX: 9, maxX: 11, alive: true, hp: 1, image: "pkg:/images/game/monster_shadow.png" })
        setGameDialog("KOLI", "pkg:/images/characters/koli.png", "Koli: 'A Forja dos Cristais Puros! Resgate o Kurion no canto e acenda o altar para purificar a forja!'")

    else if stageNum = 9
        m.playerX = 2: m.playerY = 6: m.pagonixX = 1: m.pagonixY = 6
        m.monsters.push({ id: 0, type: "grunt", x: 4, y: 4, dirX: 1, minX: 3, maxX: 5, alive: true, hp: 2, image: "pkg:/images/game/monster_grunt.png" })
        m.monsters.push({ id: 1, type: "grunt", x: 10, y: 3, dirX: -1, minX: 9, maxX: 12, alive: true, hp: 2, image: "pkg:/images/game/monster_grunt.png" })
        m.monsters.push({ id: 2, type: "shadow", x: 7, y: 5, dirX: 1, minX: 6, maxX: 8, alive: true, hp: 1, image: "pkg:/images/game/monster_shadow.png" })
        setGameDialog("SOLDADO DARK TEAM", "pkg:/images/game/monster_grunt.png", "SOLDADO: 'Parem a garota do Colar! Não a deixem alcançar a câmara do Golem!'")

    else if stageNum = 10
        m.playerX = 7: m.playerY = 6: m.pagonixX = 7: m.pagonixY = 7
        m.monsters.push({ id: 0, type: "golem", x: 7, y: 3, dirX: 1, minX: 6, maxX: 8, alive: true, hp: 3, image: "pkg:/images/game/monster_golem.png" })
        m.monsters.push({ id: 1, type: "grunt", x: 3, y: 4, dirX: 1, minX: 2, maxX: 4, alive: true, hp: 1, image: "pkg:/images/game/monster_grunt.png" })
        setGameDialog("KOLI & PAGONIX", "pkg:/images/characters/koli.png", "Koli: 'O Golem Titânico despertou! Mire o feixe de luz e use o Casco de Cristal (↺) para resistir aos impactos!'")

    else if stageNum = 11
        m.playerX = 2: m.playerY = 5: m.pagonixX = 1: m.pagonixY = 5
        m.monsters.push({ id: 0, type: "shadow", x: 5, y: 3, dirX: 1, minX: 4, maxX: 7, alive: true, hp: 1, image: "pkg:/images/game/monster_shadow.png" })
        m.monsters.push({ id: 1, type: "shadow", x: 10, y: 3, dirX: -1, minX: 8, maxX: 12, alive: true, hp: 1, image: "pkg:/images/game/monster_shadow.png" })
        setGameDialog("KOLI", "pkg:/images/characters/koli.png", "Koli: 'Alcançamos o Grande Dirigível! Reative os motores com o Colar (OK) para mantermos altitude!'")

    else if stageNum = 12
        m.playerX = 1: m.playerY = 6: m.pagonixX = 1: m.pagonixY = 5
        m.monsters.push({ id: 0, type: "golem", x: 7, y: 3, dirX: 1, minX: 5, maxX: 9, alive: true, hp: 2, image: "pkg:/images/game/monster_golem.png" })
        m.monsters.push({ id: 1, type: "shadow", x: 4, y: 5, dirX: -1, minX: 3, maxX: 6, alive: true, hp: 1, image: "pkg:/images/game/monster_shadow.png" })
        setGameDialog("PAGONIX", "pkg:/images/kurions/pagonix.png", "Pagonix: 'PAGO! Cuidado ao caminhar pelas gôndolas exteriores, o vento está forte!'")

    else if stageNum = 13
        m.playerX = 2: m.playerY = 6: m.pagonixX = 1: m.pagonixY = 6
        m.monsters.push({ id: 0, type: "grunt", x: 6, y: 4, dirX: 1, minX: 5, maxX: 8, alive: true, hp: 2, image: "pkg:/images/game/monster_grunt.png" })
        m.monsters.push({ id: 1, type: "shadow", x: 10, y: 4, dirX: -1, minX: 9, maxX: 12, alive: true, hp: 1, image: "pkg:/images/game/monster_shadow.png" })
        setGameDialog("KOLI", "pkg:/images/characters/koli.png", "Koli: 'A Sala de Máquinas central! Religue os 3 motores de sustentação antes que o dirigível caia!'")

    else if stageNum = 14
        m.playerX = 7: m.playerY = 6: m.pagonixX = 7: m.pagonixY = 7
        m.monsters.push({ id: 0, type: "grunt", x: 4, y: 3, dirX: 1, minX: 3, maxX: 5, alive: true, hp: 2, image: "pkg:/images/game/monster_grunt.png" })
        m.monsters.push({ id: 1, type: "grunt", x: 10, y: 3, dirX: -1, minX: 9, maxX: 12, alive: true, hp: 2, image: "pkg:/images/game/monster_grunt.png" })
        m.monsters.push({ id: 2, type: "golem", x: 7, y: 2, dirX: 1, minX: 6, maxX: 8, alive: true, hp: 2, image: "pkg:/images/game/monster_golem.png" })
        setGameDialog("KOLI & PAGONIX", "pkg:/images/characters/koli.png", "Koli: 'A Ponte de Comando foi tomada! Liberte o Kurion piloto e purifique os guardas de elite!'")

    else if stageNum = 15
        m.playerX = 7: m.playerY = 6: m.pagonixX = 7: m.pagonixY = 7
        m.monsters.push({ id: 0, type: "grunt", x: 7, y: 3, dirX: 1, minX: 6, maxX: 8, alive: true, hp: 3, image: "pkg:/images/game/monster_grunt.png" })
        m.monsters.push({ id: 1, type: "shadow", x: 3, y: 3, dirX: 1, minX: 2, maxX: 4, alive: true, hp: 1, image: "pkg:/images/game/monster_shadow.png" })
        m.monsters.push({ id: 2, type: "shadow", x: 11, y: 3, dirX: -1, minX: 10, maxX: 12, alive: true, hp: 1, image: "pkg:/images/game/monster_shadow.png" })
        setGameDialog("CAPITÃO SOMBRIO", "pkg:/images/game/monster_grunt.png", "CAPITÃO: 'Você não impedirá a chegada do Vórtice Sombrio!' — Koli: 'Nós expulsaremos a Dark Team dos céus!'")

    else if stageNum = 16
        m.playerX = 2: m.playerY = 5: m.pagonixX = 1: m.pagonixY = 5
        m.monsters.push({ id: 0, type: "shadow", x: 5, y: 3, dirX: 1, minX: 4, maxX: 7, alive: true, hp: 2, image: "pkg:/images/game/monster_shadow.png" })
        m.monsters.push({ id: 1, type: "shadow", x: 10, y: 3, dirX: -1, minX: 8, maxX: 12, alive: true, hp: 2, image: "pkg:/images/game/monster_shadow.png" })
        setGameDialog("KOLI", "pkg:/images/characters/koli.png", "Koli: 'O Mirante dos Ventos de Zéfiro! As correntes de ar são velozes e atraíram espectros aéreos!'")

    else if stageNum = 17
        m.playerX = 7: m.playerY = 6: m.pagonixX = 7: m.pagonixY = 7
        m.monsters.push({ id: 0, type: "grunt", x: 4, y: 4, dirX: 1, minX: 3, maxX: 5, alive: true, hp: 2, image: "pkg:/images/game/monster_grunt.png" })
        m.monsters.push({ id: 1, type: "grunt", x: 10, y: 4, dirX: -1, minX: 9, maxX: 11, alive: true, hp: 2, image: "pkg:/images/game/monster_grunt.png" })
        m.monsters.push({ id: 2, type: "shadow", x: 7, y: 2, dirX: 1, minX: 6, maxX: 8, alive: true, hp: 1, image: "pkg:/images/game/monster_shadow.png" })
        setGameDialog("PAGONIX", "pkg:/images/kurions/pagonix.png", "Pagonix: 'PAGO! O Labirinto das Correntes de Ar! Pise nos interruptores laterais para abrir a ponte celestial!'")

    else if stageNum = 18
        m.playerX = 1: m.playerY = 6: m.pagonixX = 1: m.pagonixY = 5
        m.monsters.push({ id: 0, type: "golem", x: 5, y: 3, dirX: 1, minX: 4, maxX: 7, alive: true, hp: 2, image: "pkg:/images/game/monster_golem.png" })
        m.monsters.push({ id: 1, type: "golem", x: 9, y: 3, dirX: -1, minX: 8, maxX: 11, alive: true, hp: 2, image: "pkg:/images/game/monster_golem.png" })
        setGameDialog("KOLI", "pkg:/images/characters/koli.png", "Koli: 'O Templo dos Kurions Alados! Liberte o Kurion voador enjaulado antes de seguir adiante!'")

    else if stageNum = 19
        m.playerX = 7: m.playerY = 6: m.pagonixX = 7: m.pagonixY = 7
        m.monsters.push({ id: 0, type: "golem", x: 4, y: 3, dirX: 1, minX: 3, maxX: 5, alive: true, hp: 2, image: "pkg:/images/game/monster_golem.png" })
        m.monsters.push({ id: 1, type: "grunt", x: 10, y: 3, dirX: -1, minX: 9, maxX: 12, alive: true, hp: 2, image: "pkg:/images/game/monster_grunt.png" })
        m.monsters.push({ id: 2, type: "shadow", x: 7, y: 5, dirX: 1, minX: 6, maxX: 8, alive: true, hp: 2, image: "pkg:/images/game/monster_shadow.png" })
        setGameDialog("KOLI & PAGONIX", "pkg:/images/characters/koli.png", "Koli: 'A Ponte Quebrada de Zéfiro! Acione os altares de luz para ativar a ponte e atravessar o abismo!'")

    else if stageNum = 20
        m.playerX = 7: m.playerY = 6: m.pagonixX = 7: m.pagonixY = 7
        m.monsters.push({ id: 0, type: "boss", x: 7, y: 2, dirX: 1, minX: 6, maxX: 8, alive: true, hp: 3, image: "pkg:/images/game/monster_boss.png" })
        m.monsters.push({ id: 1, type: "shadow", x: 4, y: 4, dirX: 1, minX: 3, maxX: 5, alive: true, hp: 2, image: "pkg:/images/game/monster_shadow.png" })
        m.monsters.push({ id: 2, type: "shadow", x: 10, y: 4, dirX: -1, minX: 9, maxX: 11, alive: true, hp: 2, image: "pkg:/images/game/monster_shadow.png" })
        setGameDialog("SERPENTE DOS VENTOS", "pkg:/images/game/monster_boss.png", "SERPENTE: 'Ninguém perturba o santuário dos ventos!' — Pagonix: 'Use o Casco de Cristal para se proteger dos furacões!'")

    else if stageNum = 21
        m.playerX = 2: m.playerY = 6: m.pagonixX = 1: m.pagonixY = 6
        m.monsters.push({ id: 0, type: "grunt", x: 6, y: 3, dirX: 1, minX: 4, maxX: 8, alive: true, hp: 2, image: "pkg:/images/game/monster_grunt.png" })
        m.monsters.push({ id: 1, type: "shadow", x: 11, y: 4, dirX: -1, minX: 9, maxX: 12, alive: true, hp: 2, image: "pkg:/images/game/monster_shadow.png" })
        setGameDialog("KOLI", "pkg:/images/characters/koli.png", "Koli: 'As Cavernas Ígneas! A temperatura está altíssima e soldados patrulham os corredores de magma!'")

    else if stageNum = 22
        m.playerX = 7: m.playerY = 6: m.pagonixX = 7: m.pagonixY = 7
        m.monsters.push({ id: 0, type: "golem", x: 5, y: 3, dirX: 1, minX: 3, maxX: 7, alive: true, hp: 2, image: "pkg:/images/game/monster_golem.png" })
        m.monsters.push({ id: 1, type: "grunt", x: 11, y: 4, dirX: -1, minX: 9, maxX: 12, alive: true, hp: 2, image: "pkg:/images/game/monster_grunt.png" })
        setGameDialog("PAGONIX", "pkg:/images/kurions/pagonix.png", "Pagonix: 'PAGO! Pise no interruptor para transpor a barreira e evitar os espinhos incandescentes!'")

    else if stageNum = 23
        m.playerX = 2: m.playerY = 6: m.pagonixX = 1: m.pagonixY = 6
        m.monsters.push({ id: 0, type: "grunt", x: 5, y: 3, dirX: 1, minX: 4, maxX: 7, alive: true, hp: 2, image: "pkg:/images/game/monster_grunt.png" })
        m.monsters.push({ id: 1, type: "shadow", x: 10, y: 3, dirX: -1, minX: 8, maxX: 12, alive: true, hp: 2, image: "pkg:/images/game/monster_shadow.png" })
        setGameDialog("KOLI", "pkg:/images/characters/koli.png", "Koli: 'A Fundição Ancestral de Aether! Reative as 3 caldeiras de cristal puro com o Colar!'")

    else if stageNum = 24
        m.playerX = 7: m.playerY = 6: m.pagonixX = 7: m.pagonixY = 7
        m.monsters.push({ id: 0, type: "golem", x: 4, y: 3, dirX: 1, minX: 3, maxX: 6, alive: true, hp: 2, image: "pkg:/images/game/monster_golem.png" })
        m.monsters.push({ id: 1, type: "grunt", x: 10, y: 3, dirX: -1, minX: 8, maxX: 11, alive: true, hp: 2, image: "pkg:/images/game/monster_grunt.png" })
        setGameDialog("KOLI & PAGONIX", "pkg:/images/characters/koli.png", "Koli: 'Um Kurion de Fogo está preso na gaiola! Cuidado com os espinhos e liberte-o!'")

    else if stageNum = 25
        m.playerX = 7: m.playerY = 6: m.pagonixX = 7: m.pagonixY = 7
        m.monsters.push({ id: 0, type: "golem", x: 7, y: 2, dirX: 1, minX: 6, maxX: 8, alive: true, hp: 4, image: "pkg:/images/game/monster_golem.png" })
        m.monsters.push({ id: 1, type: "shadow", x: 4, y: 4, dirX: 1, minX: 3, maxX: 5, alive: true, hp: 2, image: "pkg:/images/game/monster_shadow.png" })
        m.monsters.push({ id: 2, type: "shadow", x: 10, y: 4, dirX: -1, minX: 9, maxX: 11, alive: true, hp: 2, image: "pkg:/images/game/monster_shadow.png" })
        setGameDialog("COLOSSO DE MAGMA", "pkg:/images/game/monster_golem.png", "COLOSSO: 'Vocês queimarão nas chamas das sombras!' — Pagonix: 'Use o Escudo de Cristal (↺) para desviar das explosões!'")

    else if stageNum = 26
        m.playerX = 2: m.playerY = 6: m.pagonixX = 1: m.pagonixY = 6
        m.monsters.push({ id: 0, type: "shadow", x: 6, y: 3, dirX: 1, minX: 4, maxX: 8, alive: true, hp: 2, image: "pkg:/images/game/monster_shadow.png" })
        m.monsters.push({ id: 1, type: "shadow", x: 11, y: 4, dirX: -1, minX: 9, maxX: 12, alive: true, hp: 2, image: "pkg:/images/game/monster_shadow.png" })
        setGameDialog("KOLI", "pkg:/images/characters/koli.png", "Koli: 'O Abismo das Águas Ancestrais! As ruínas submersas abrigam espectros aquáticos da Dark Team!'")

    else if stageNum = 27
        m.playerX = 7: m.playerY = 6: m.pagonixX = 7: m.pagonixY = 7
        m.monsters.push({ id: 0, type: "grunt", x: 4, y: 3, dirX: 1, minX: 3, maxX: 5, alive: true, hp: 2, image: "pkg:/images/game/monster_grunt.png" })
        m.monsters.push({ id: 1, type: "grunt", x: 10, y: 3, dirX: -1, minX: 9, maxX: 11, alive: true, hp: 2, image: "pkg:/images/game/monster_grunt.png" })
        setGameDialog("PAGONIX", "pkg:/images/kurions/pagonix.png", "Pagonix: 'PAGO! Pise no interruptor da eclusa para liberar o fluxo de Aether e baixar as comportas!'")

    else if stageNum = 28
        m.playerX = 1: m.playerY = 6: m.pagonixX = 1: m.pagonixY = 5
        m.monsters.push({ id: 0, type: "golem", x: 6, y: 2, dirX: 1, minX: 4, maxX: 8, alive: true, hp: 2, image: "pkg:/images/game/monster_golem.png" })
        m.monsters.push({ id: 1, type: "shadow", x: 11, y: 5, dirX: -1, minX: 9, maxX: 12, alive: true, hp: 2, image: "pkg:/images/game/monster_shadow.png" })
        setGameDialog("KOLI", "pkg:/images/characters/koli.png", "Koli: 'O Santuário dos Corais Sagrados! Ative o altar sagrado de luz para purificar as águas de Aether!'")

    else if stageNum = 29
        m.playerX = 7: m.playerY = 6: m.pagonixX = 7: m.pagonixY = 7
        m.monsters.push({ id: 0, type: "grunt", x: 4, y: 3, dirX: 1, minX: 3, maxX: 6, alive: true, hp: 2, image: "pkg:/images/game/monster_grunt.png" })
        m.monsters.push({ id: 1, type: "grunt", x: 10, y: 3, dirX: -1, minX: 8, maxX: 12, alive: true, hp: 2, image: "pkg:/images/game/monster_grunt.png" })
        m.monsters.push({ id: 2, type: "shadow", x: 7, y: 4, dirX: 1, minX: 6, maxX: 8, alive: true, hp: 2, image: "pkg:/images/game/monster_shadow.png" })
        setGameDialog("SOLDADO DARK TEAM", "pkg:/images/game/monster_grunt.png", "SOLDADO: 'Intrusos no abismo! Não permitam que alcancem o covil do Leviatã!'")

    else if stageNum = 30
        m.playerX = 7: m.playerY = 6: m.pagonixX = 7: m.pagonixY = 7
        m.monsters.push({ id: 0, type: "boss", x: 7, y: 2, dirX: 1, minX: 6, maxX: 8, alive: true, hp: 4, image: "pkg:/images/game/monster_boss.png" })
        m.monsters.push({ id: 1, type: "shadow", x: 3, y: 4, dirX: 1, minX: 2, maxX: 4, alive: true, hp: 2, image: "pkg:/images/game/monster_shadow.png" })
        m.monsters.push({ id: 2, type: "shadow", x: 11, y: 4, dirX: -1, minX: 10, maxX: 12, alive: true, hp: 2, image: "pkg:/images/game/monster_shadow.png" })
        setGameDialog("LEVIATÃ ABISSAL", "pkg:/images/game/monster_boss.png", "LEVIATÃ: 'As profundezas engolirão a sua luz!' — Koli: 'Pagonix, ative o domo de cristal e concentre o feixe de luz!'")

    else if stageNum = 31
        m.playerX = 2: m.playerY = 6: m.pagonixX = 1: m.pagonixY = 6
        m.monsters.push({ id: 0, type: "grunt", x: 6, y: 4, dirX: 1, minX: 4, maxX: 8, alive: true, hp: 2, image: "pkg:/images/game/monster_grunt.png" })
        m.monsters.push({ id: 1, type: "grunt", x: 11, y: 4, dirX: -1, minX: 9, maxX: 12, alive: true, hp: 2, image: "pkg:/images/game/monster_grunt.png" })
        setGameDialog("KOLI", "pkg:/images/characters/koli.png", "Koli: 'A Fortaleza Celestial da Dark Team! Portões de ferro negro protegem a base do inimigo!'")

    else if stageNum = 32
        m.playerX = 7: m.playerY = 6: m.pagonixX = 7: m.pagonixY = 7
        m.monsters.push({ id: 0, type: "shadow", x: 4, y: 3, dirX: 1, minX: 3, maxX: 6, alive: true, hp: 2, image: "pkg:/images/game/monster_shadow.png" })
        m.monsters.push({ id: 1, type: "shadow", x: 10, y: 3, dirX: -1, minX: 8, maxX: 11, alive: true, hp: 2, image: "pkg:/images/game/monster_shadow.png" })
        setGameDialog("PAGONIX", "pkg:/images/kurions/pagonix.png", "Pagonix: 'PAGO! As prisões da fortaleza! Vários Kurions bebês estão enjaulados aqui! Vamos salvá-los!'")

    else if stageNum = 33
        m.playerX = 2: m.playerY = 6: m.pagonixX = 1: m.pagonixY = 6
        m.monsters.push({ id: 0, type: "grunt", x: 5, y: 3, dirX: 1, minX: 4, maxX: 7, alive: true, hp: 2, image: "pkg:/images/game/monster_grunt.png" })
        m.monsters.push({ id: 1, type: "golem", x: 10, y: 3, dirX: -1, minX: 8, maxX: 11, alive: true, hp: 2, image: "pkg:/images/game/monster_golem.png" })
        setGameDialog("KOLI", "pkg:/images/characters/koli.png", "Koli: 'A Sala dos Reatores Sombrios! Neutralize os motores com a luz do Colar para desarmar as defesas!'")

    else if stageNum = 34
        m.playerX = 7: m.playerY = 6: m.pagonixX = 7: m.pagonixY = 7
        m.monsters.push({ id: 0, type: "grunt", x: 4, y: 4, dirX: 1, minX: 3, maxX: 6, alive: true, hp: 3, image: "pkg:/images/game/monster_grunt.png" })
        m.monsters.push({ id: 1, type: "grunt", x: 10, y: 4, dirX: -1, minX: 8, maxX: 11, alive: true, hp: 3, image: "pkg:/images/game/monster_grunt.png" })
        setGameDialog("ESQUADRÃO DE ELITE", "pkg:/images/game/monster_grunt.png", "OFICIAL: 'Esquadrão de elite da Dark Team, fogo total!' — Pagonix: 'Casco Protetor pronto para repelir!'")

    else if stageNum = 35
        m.playerX = 7: m.playerY = 6: m.pagonixX = 7: m.pagonixY = 7
        m.monsters.push({ id: 0, type: "boss", x: 7, y: 2, dirX: 1, minX: 6, maxX: 8, alive: true, hp: 4, image: "pkg:/images/game/monster_boss.png" })
        m.monsters.push({ id: 1, type: "grunt", x: 3, y: 4, dirX: 1, minX: 2, maxX: 4, alive: true, hp: 2, image: "pkg:/images/game/monster_grunt.png" })
        m.monsters.push({ id: 2, type: "grunt", x: 11, y: 4, dirX: -1, minX: 10, maxX: 12, alive: true, hp: 2, image: "pkg:/images/game/monster_grunt.png" })
        setGameDialog("GENERAL SUPREMO", "pkg:/images/game/monster_boss.png", "GENERAL: 'Vocês chegaram longe demais, pirralhos! A escuridão reinará!' — Koli: 'Nós nunca desistiremos de Aether!'")

    else if stageNum = 36
        m.playerX = 2: m.playerY = 6: m.pagonixX = 1: m.pagonixY = 6
        m.monsters.push({ id: 0, type: "shadow", x: 5, y: 3, dirX: 1, minX: 4, maxX: 7, alive: true, hp: 2, image: "pkg:/images/game/monster_shadow.png" })
        m.monsters.push({ id: 1, type: "shadow", x: 10, y: 3, dirX: -1, minX: 8, maxX: 11, alive: true, hp: 2, image: "pkg:/images/game/monster_shadow.png" })
        setGameDialog("KOLI", "pkg:/images/characters/koli.png", "Koli: 'A Fenda Dimensional! O espaço ao redor está distorcido pela energia do Vórtice Sombrio!'")

    else if stageNum = 37
        m.playerX = 7: m.playerY = 6: m.pagonixX = 7: m.pagonixY = 7
        m.monsters.push({ id: 0, type: "golem", x: 4, y: 3, dirX: 1, minX: 3, maxX: 5, alive: true, hp: 3, image: "pkg:/images/game/monster_golem.png" })
        m.monsters.push({ id: 1, type: "golem", x: 10, y: 3, dirX: -1, minX: 9, maxX: 11, alive: true, hp: 3, image: "pkg:/images/game/monster_golem.png" })
        setGameDialog("PAGONIX", "pkg:/images/kurions/pagonix.png", "Pagonix: 'PAGO! A Escadaria das Estrelas Perdidas! Ative os interruptores para abrir a passagem celestial!'")

    else if stageNum = 38
        m.playerX = 1: m.playerY = 6: m.pagonixX = 1: m.pagonixY = 5
        m.monsters.push({ id: 0, type: "shadow", x: 5, y: 2, dirX: 1, minX: 4, maxX: 7, alive: true, hp: 2, image: "pkg:/images/game/monster_shadow.png" })
        m.monsters.push({ id: 1, type: "shadow", x: 9, y: 2, dirX: -1, minX: 8, maxX: 11, alive: true, hp: 2, image: "pkg:/images/game/monster_shadow.png" })
        setGameDialog("KOLI", "pkg:/images/characters/koli.png", "Koli: 'O Círculo dos Quatro Elementos! Purifique os Altares Sagrados com o Colar para restaurar o equilíbrio cósmico!'")

    else if stageNum = 39
        m.playerX = 7: m.playerY = 6: m.pagonixX = 7: m.pagonixY = 7
        m.monsters.push({ id: 0, type: "golem", x: 4, y: 3, dirX: 1, minX: 3, maxX: 5, alive: true, hp: 3, image: "pkg:/images/game/monster_golem.png" })
        m.monsters.push({ id: 1, type: "grunt", x: 10, y: 3, dirX: -1, minX: 9, maxX: 12, alive: true, hp: 3, image: "pkg:/images/game/monster_grunt.png" })
        m.monsters.push({ id: 2, type: "shadow", x: 7, y: 4, dirX: 1, minX: 6, maxX: 8, alive: true, hp: 2, image: "pkg:/images/game/monster_shadow.png" })
        setGameDialog("KOLI & PAGONIX", "pkg:/images/characters/koli.png", "Koli: 'A Antecâmara do Infinito! A última barreira que nos separa do confronto definitivo! Coragem, Pagonix!'")

    else if stageNum = 40
        m.playerX = 7: m.playerY = 6: m.pagonixX = 7: m.pagonixY = 7
        m.monsters.push({ id: 0, type: "boss", x: 7, y: 2, dirX: 1, minX: 6, maxX: 8, alive: true, hp: 5, image: "pkg:/images/game/monster_boss.png" })
        m.monsters.push({ id: 1, type: "shadow", x: 4, y: 4, dirX: 1, minX: 3, maxX: 5, alive: true, hp: 2, image: "pkg:/images/game/monster_shadow.png" })
        m.monsters.push({ id: 2, type: "shadow", x: 10, y: 4, dirX: -1, minX: 9, maxX: 11, alive: true, hp: 2, image: "pkg:/images/game/monster_shadow.png" })
        setGameDialog("A ENTIDADE DAS SOMBRAS", "pkg:/images/game/monster_boss.png", "VÓRTICE DAS SOMBRAS: 'A luz de Aether se extinguirá para sempre!' — Koli: 'Ative os 4 Altares Cósmicos e purifique o Vórtice para despertar Chalicrfax!'")
    end if

    renderStageTiles()
    updateGameEntitiesPosition()
    renderMonsters()
    updateGameHUD()
end sub

sub renderStageTiles()
    if m.gameTiles = invalid or m.gameTiles.count() < 120 then return

    idx = 0
    for r = 0 to 7
        rowStr = m.currMap[r]
        for c = 0 to 14
            char = Mid(rowStr, c + 1, 1)
            tile = m.gameTiles[idx]

            if char = "W"
                tile.uri = "pkg:/images/game/tile_wall.png"
            else if char = "D"
                tile.uri = "pkg:/images/game/tile_door.png"
            else if char = "X"
                tile.uri = "pkg:/images/game/tile_spike.png"
            else if char = "A"
                if m.stageAltarActivated or m.stageAltarsCount > 0
                    tile.uri = "pkg:/images/game/tile_altar_act.png"
                else
                    tile.uri = "pkg:/images/game/tile_altar.png"
                end if
            else if char = "B"
                if m.stageBarrierCleared
                    tile.uri = "pkg:/images/game/tile_floor.png"
                else
                    tile.uri = "pkg:/images/game/tile_barrier.png"
                end if
            else if char = "S"
                if m.stageSwitchActivated
                    tile.uri = "pkg:/images/game/tile_switch_on.png"
                else
                    tile.uri = "pkg:/images/game/tile_switch.png"
                end if
            else if char = "K"
                if m.stageKurionRescued
                    tile.uri = "pkg:/images/game/tile_cage_open.png"
                else
                    tile.uri = "pkg:/images/game/tile_cage.png"
                end if
            else if char = "M"
                tile.uri = "pkg:/images/game/tile_motor.png"
            else if char = "C"
                if m.stageChestOpened
                    tile.uri = "pkg:/images/game/tile_chest_open.png"
                else
                    tile.uri = "pkg:/images/game/tile_chest.png"
                end if
            else if char = "T"
                tile.uri = "pkg:/images/game/tile_altar.png"
            else
                tile.uri = "pkg:/images/game/tile_floor.png"
            end if

            idx = idx + 1
        end for
    end for
end sub

sub renderMonsters()
    for i = 0 to 3
        monNode = m.gameMonstersNodes[i]
        if i < m.monsters.count()
            mon = m.monsters[i]
            if mon.alive
                monNode.uri = mon.image
                monNode.translation = [mon.x * 80 + 80, mon.y * 70 + 55]
                monNode.visible = true
            else
                monNode.visible = false
            end if
        else
            monNode.visible = false
        end if
    end for
end sub

sub renderDrops()
    if m.gameDropsNodes = invalid then return
    for i = 0 to 3
        dropNode = m.gameDropsNodes[i]
        if m.drops <> invalid and i < m.drops.count()
            d = m.drops[i]
            if d.active
                if d.type = "gem"
                    dropNode.uri = "pkg:/images/game/item_gem.png"
                else
                    dropNode.uri = "pkg:/images/game/item_heart.png"
                end if
                dropNode.translation = [d.x * 80 + 92, d.y * 70 + 67]
                dropNode.visible = true
            else
                dropNode.visible = false
            end if
        else
            dropNode.visible = false
        end if
    end for
end sub

sub updateGameEntitiesPosition()
    if m.gamePlayer <> invalid
        m.gamePlayer.translation = [m.playerX * 80 + 77, m.playerY * 70 + 52]
    end if
    if m.gamePagonix <> invalid
        m.gamePagonix.translation = [m.pagonixX * 80 + 85, m.pagonixY * 70 + 60]
    end if
    if m.shieldActive and m.gamePagonixShield <> invalid
        m.gamePagonixShield.translation = [m.playerX * 80 + 69, m.playerY * 70 + 44]
    end if
end sub

sub updateGameHUD()
    if m.gameRoomTitle <> invalid
        m.gameRoomTitle.text = "FASE " + m.gameCurrentStage.toStr() + "/40: " + m.stageNames[m.gameCurrentStage - 1]
    end if

    if m.gameHpLabel <> invalid
        hearts = ""
        for h = 1 to m.hp
            hearts = hearts + "💎 "
        end for
        if m.hp = 0 then hearts = "ESGOTADA"
        m.gameHpLabel.text = "VIDA: " + hearts
    end if

    if m.gameGemsLabel <> invalid
        m.gameGemsLabel.text = "GEMAS: 💎 " + m.gameGems.toStr()
    end if

    if m.gameShieldLabel <> invalid
        if m.shieldActive
            m.gameShieldLabel.text = "ESCUDO: [ ATIVO! ]"
            m.gameShieldLabel.color = "0x22C55EFF"
        else if m.shieldCooldown
            m.gameShieldLabel.text = "ESCUDO: [ RECARGA ]"
            m.gameShieldLabel.color = "0xEF4444FF"
        else
            m.gameShieldLabel.text = "ESCUDO: [ ↺ PRONTO ]"
            m.gameShieldLabel.color = "0x38BDF8FF"
        end if
    end if

    if m.gameKeyLabel <> invalid
        m.gameKeyLabel.text = "CRISTAIS: ✦ " + m.shardsCount.toStr() + "/3"
    end if
end sub

sub activatePagonixShield()
    if m.shieldCooldown
        setGameDialog("PAGONIX", "pkg:/images/kurions/pagonix.png", "Pagonix: 'PAGO! O Casco de Cristal ainda está recarregando energia! Aguarde!'")
        return
    end if

    m.shieldActive = true
    m.shieldCooldown = true
    m.isInvulnerable = true

    if m.gamePagonixShield <> invalid
        m.gamePagonixShield.translation = [m.playerX * 80 + 69, m.playerY * 70 + 44]
        m.gamePagonixShield.visible = true
    end if

    if m.gameShieldTimer <> invalid then m.gameShieldTimer.control = "start"
    if m.gameShieldCooldownTimer <> invalid then m.gameShieldCooldownTimer.control = "start"

    updateGameHUD()
    setGameDialog("PAGONIX", "pkg:/images/game/pagonix_shield.png", "🛡️ CASCO PROTETOR DE CRISTAL ATIVADO! Pagonix envolve Koli em um domo impenetrável por 2.5s!")
end sub

sub onGameShieldTimerFired()
    m.shieldActive = false
    if m.gamePagonixShield <> invalid then m.gamePagonixShield.visible = false
    m.isInvulnerable = false
    updateGameHUD()
    setGameDialog("PAGONIX", "pkg:/images/kurions/pagonix.png", "Pagonix: 'O Domo de Cristal se dissipou! Fique atenta aos ataques, Koli!'")
end sub

sub onGameShieldCooldownTimerFired()
    m.shieldCooldown = false
    updateGameHUD()
end sub

sub openGameShop()
    m.gameShopModalOpen = true
    m.shopFocusIndex = 0
    if m.gameShopModal <> invalid then m.gameShopModal.visible = true
    if m.shopFeedbackMsg <> invalid then m.shopFeedbackMsg.text = "Use [▲ ▼] Navegar   •   [OK] Comprar Melhoria   •   [*] ou [BACK] Sair"
    updateShopVisuals()
end sub

sub closeGameShop()
    m.gameShopModalOpen = false
    if m.gameShopModal <> invalid then m.gameShopModal.visible = false
    updateGameHUD()
end sub

sub updateShopVisuals()
    if m.shopGemsBalance <> invalid
        m.shopGemsBalance.text = "Seu Saldo: 💎 " + m.gameGems.toStr() + " Gemas de Aether"
    end if

    ' Atualiza item 0 (Vida Máxima)
    if m.shopItemTitle_0 <> invalid
        if m.maxHp >= 5
            m.shopItemTitle_0.text = "Cristal de Vida Máxima (NÍVEL MÁXIMO: 5 Cristais)"
            m.shopItemPrice_0.text = "✓ ESGOTADO"
            m.shopItemPrice_0.color = "0x22C55EFF"
        else
            m.shopItemTitle_0.text = "+1 Cristal de Vida Máxima (Atual: " + m.maxHp.toStr() + " / Máx: 5)"
            m.shopItemPrice_0.text = "💎 30 Gemas"
            m.shopItemPrice_0.color = "0xFBBF24FF"
        end if
    end if

    ' Atualiza item 1 (Alcance do Feixe)
    if m.shopItemTitle_1 <> invalid
        if m.beamRange >= 2
            m.shopItemTitle_1.text = "Alcance do Colar (NÍVEL 2 ADQUIRIDO: Feixe Longo)"
            m.shopItemPrice_1.text = "✓ ESGOTADO"
            m.shopItemPrice_1.color = "0x22C55EFF"
        else
            m.shopItemTitle_1.text = "Alcance do Colar Nível 2 (Feixe Longo de 2 Blocos)"
            m.shopItemPrice_1.text = "💎 40 Gemas"
            m.shopItemPrice_1.color = "0xFBBF24FF"
        end if
    end if

    ' Atualiza item 2 (Poção de Éter)
    if m.shopItemSub_2 <> invalid
        m.shopItemSub_2.text = "Restaura toda a vida no local se Koli for derrotada (Em posse: " + m.potionsCount.toStr() + ")."
    end if

    ' Atualiza destaques dos botões da loja
    if m.shopItemBoxes <> invalid
        for i = 0 to 3
            if i = m.shopFocusIndex
                m.shopItemBoxes[i].color = "0x38BDF888"
            else
                m.shopItemBoxes[i].color = "0x1E293BFF"
            end if
        end for
    end if
end sub

sub purchaseShopItem()
    if m.shopFocusIndex = 0
        ' +1 Cristal de Vida
        if m.maxHp >= 5
            if m.shopFeedbackMsg <> invalid then m.shopFeedbackMsg.text = "⚠️ Você já atingiu o limite máximo de 5 Cristais de Vida!"
            return
        end if
        if m.gameGems < 30
            if m.shopFeedbackMsg <> invalid then m.shopFeedbackMsg.text = "⚠️ Gemas insuficientes! Purifique mais monstros para coletar gemas (Custo: 30)."
            return
        end if
        m.gameGems = m.gameGems - 30
        m.maxHp = m.maxHp + 1
        m.hp = m.maxHp
        m.storage.saveGameData(m.gameGems, m.maxHp, m.beamRange, m.potionsCount, m.highestStage)
        updateShopVisuals()
        updateGameHUD()
        if m.shopFeedbackMsg <> invalid then m.shopFeedbackMsg.text = "✨ Parabéns! Sua vida máxima aumentou para " + m.maxHp.toStr() + " Cristais!"

    else if m.shopFocusIndex = 1
        ' Alcance Nível 2
        if m.beamRange >= 2
            if m.shopFeedbackMsg <> invalid then m.shopFeedbackMsg.text = "⚠️ Alcance Nível 2 já está ativado no Colar do Começo!"
            return
        end if
        if m.gameGems < 40
            if m.shopFeedbackMsg <> invalid then m.shopFeedbackMsg.text = "⚠️ Gemas insuficientes! Purifique mais monstros para coletar gemas (Custo: 40)."
            return
        end if
        m.gameGems = m.gameGems - 40
        m.beamRange = 2
        m.storage.saveGameData(m.gameGems, m.maxHp, m.beamRange, m.potionsCount, m.highestStage)
        updateShopVisuals()
        updateGameHUD()
        if m.shopFeedbackMsg <> invalid then m.shopFeedbackMsg.text = "⚡ Alcance Nível 2 adquirido! Agora o feixe alcança 2 blocos de distância!"

    else if m.shopFocusIndex = 2
        ' Poção de Éter
        if m.gameGems < 25
            if m.shopFeedbackMsg <> invalid then m.shopFeedbackMsg.text = "⚠️ Gemas insuficientes para comprar a Poção de Éter (Custo: 25)."
            return
        end if
        m.gameGems = m.gameGems - 25
        m.potionsCount = m.potionsCount + 1
        m.storage.saveGameData(m.gameGems, m.maxHp, m.beamRange, m.potionsCount, m.highestStage)
        updateShopVisuals()
        updateGameHUD()
        if m.shopFeedbackMsg <> invalid then m.shopFeedbackMsg.text = "🛡️ Poção de Éter comprada! Total em posse: " + m.potionsCount.toStr() + "."

    else if m.shopFocusIndex = 3
        closeGameShop()
    end if
end sub

sub setGameDialog(speaker as String, avatar as String, text as String)
    if m.gameSpeakerName <> invalid then m.gameSpeakerName.text = speaker
    if m.gameSpeakerAvatar <> invalid then m.gameSpeakerAvatar.uri = avatar
    if m.gameDialogText <> invalid then m.gameDialogText.text = text
end sub

sub onGameGlowTimerFired()
    if m.gameActionGlow <> invalid then m.gameActionGlow.visible = false
end sub

sub onGameAttackTimerFired()
    if m.gameAttackBeam <> invalid then m.gameAttackBeam.visible = false
end sub

sub onGameInvulnerableTimerFired()
    m.isInvulnerable = false
end sub

sub onGameEnemyTimerFired()
    if m.focusArea <> "game" or m.gameOverModalOpen or m.gameStageClearModalOpen or m.gameVictoryModalOpen or m.gameShopModalOpen
        return
    end if

    for each mon in m.monsters
        if mon.alive
            dx = m.playerX - mon.x
            dy = m.playerY - mon.y
            dist = Abs(dx) + Abs(dy)

            ' IA: Persegue Koli se estiver a 2 passos de distância!
            if dist <= 2
                newMx = mon.x
                newMy = mon.y
                if Abs(dx) >= Abs(dy)
                    if dx > 0 then newMx = mon.x + 1 else if dx < 0 then newMx = mon.x - 1
                else
                    if dy > 0 then newMy = mon.y + 1 else if dy < 0 then newMy = mon.y - 1
                end if

                if canMonsterWalk(newMx, newMy)
                    mon.x = newMx
                    mon.y = newMy
                end if
            else
                ' Patrulha horizontal padrão
                newMx = mon.x + mon.dirX
                if newMx > mon.maxX
                    mon.dirX = -1
                    newMx = mon.x - 1
                else if newMx < mon.minX
                    mon.dirX = 1
                    newMx = mon.x + 1
                end if

                if canMonsterWalk(newMx, mon.y) then mon.x = newMx
            end if

            ' Checa colisão de dano com Koli
            if mon.x = m.playerX and mon.y = m.playerY
                if m.shieldActive
                    ' Repele o monstro para longe!
                    mon.x = mon.x - mon.dirX
                    setGameDialog("PAGONIX", "pkg:/images/game/pagonix_shield.png", "🛡️ O monstro colidiu contra o Casco de Cristal e foi repelido pela energia pura de Aether!")
                else
                    damagePlayer()
                end if
            end if
        end if
    end for

    renderMonsters()
end sub

function canMonsterWalk(tx as Integer, ty as Integer) as Boolean
    if tx < 0 or tx > 14 or ty < 0 or ty > 7 then return false
    char = Mid(m.currMap[ty], tx + 1, 1)
    if char = "W" or char = "A" or char = "C" or char = "K" or char = "M" or char = "B"
        return false
    end if
    return true
end function

sub damagePlayer()
    if m.isInvulnerable or m.shieldActive then return

    m.hp = m.hp - 1
    updateGameHUD()

    if m.hp <= 0
        ' Verifica se possui Poção de Éter para reviver
        if m.potionsCount > 0
            m.potionsCount = m.potionsCount - 1
            m.hp = m.maxHp
            m.isInvulnerable = true
            if m.gameInvulnerableTimer <> invalid then m.gameInvulnerableTimer.control = "start"
            m.storage.saveGameData(m.gameGems, m.maxHp, m.beamRange, m.potionsCount)
            updateGameHUD()
            setGameDialog("KOLI & PAGONIX", "pkg:/images/lore/colar.png", "✨ POÇÃO DE ÉTER ACIONADA! O poder de Aether reviveu Koli com vida cheia! (Restam: " + m.potionsCount.toStr() + ")")
            return
        end if

        ' Game Over!
        m.gameOverModal.visible = true
        m.gameOverModalOpen = true
        m.gameOverButtonIndex = 0
        updateGameOverButtonFocus()
        setGameDialog("PAGONIX", "pkg:/images/kurions/pagonix.png", "Pagonix: 'PAGO... Koli! As sombras nos dominaram! Use a esperança do Colar para recomeçar!'")
    else
        m.isInvulnerable = true
        if m.gameInvulnerableTimer <> invalid then m.gameInvulnerableTimer.control = "start"
        setGameDialog("KOLI", "pkg:/images/characters/koli.png", "Koli: 'Ai! Fui atingida pela névoa da Dark Team! Pagonix, fique atento!'")
    end if
end sub

sub updateGameOverButtonFocus()
    if m.gameOverButtonIndex = 0
        m.btnGameOverRetry.color = "0x38BDF8FF"
        m.btnGameOverExit.color = "0x334155FF"
    else
        m.btnGameOverRetry.color = "0x22C55EFF"
        m.btnGameOverExit.color = "0x38BDF8FF"
    end if
end sub

sub updateGameVictoryButtonFocus()
    if m.gameVictoryButtonIndex = 0
        m.btnVictoryReplay.color = "0x38BDF8FF"
        m.btnVictoryExit.color = "0x334155FF"
    else
        m.btnVictoryReplay.color = "0x22C55EFF"
        m.btnVictoryExit.color = "0x38BDF8FF"
    end if
end sub

function handleGameKey(key as String) as Boolean
    ' 0. Modal da Lojinha do Grande Dirigível
    if m.gameShopModalOpen
        if key = "up"
            if m.shopFocusIndex > 0
                m.shopFocusIndex = m.shopFocusIndex - 1
                updateShopVisuals()
            end if
            return true
        else if key = "down"
            if m.shopFocusIndex < 3
                m.shopFocusIndex = m.shopFocusIndex + 1
                updateShopVisuals()
            end if
            return true
        else if key = "OK"
            purchaseShopItem()
            return true
        else if key = "back" or key = "options" or key = "info"
            closeGameShop()
            return true
        end if
        return true
    end if

    ' 1. Modal de Game Over
    if m.gameOverModalOpen
        if key = "left" or key = "right"
            m.gameOverButtonIndex = 1 - m.gameOverButtonIndex
            updateGameOverButtonFocus()
            return true
        else if key = "OK"
            if m.gameOverButtonIndex = 0
                ' Tentar de novo a fase atual
                loadGameStage(m.gameCurrentStage)
            else
                ' Voltar ao menu
                m.gameOverModal.visible = false
                m.gameOverModalOpen = false
                m.focusArea = "sidebar"
                refreshMenuSelectionVisuals()
            end if
            return true
        else if key = "back"
            m.gameOverModal.visible = false
            m.gameOverModalOpen = false
            m.focusArea = "sidebar"
            refreshMenuSelectionVisuals()
            return true
        end if
        return false
    end if

    ' 2. Modal de Fase Concluída
    if m.gameStageClearModalOpen
        if key = "OK"
            if m.gameCurrentStage < 40
                loadGameStage(m.gameCurrentStage + 1)
            else
                m.gameStageClearModal.visible = false
                m.gameStageClearModalOpen = false
                triggerGrandVictory()
            end if
            return true
        else if key = "back"
            m.gameStageClearModal.visible = false
            m.gameStageClearModalOpen = false
            m.focusArea = "sidebar"
            refreshMenuSelectionVisuals()
            return true
        end if
        return false
    end if

    ' 3. Modal de Vitória Final
    if m.gameVictoryModalOpen
        if key = "left" or key = "right"
            m.gameVictoryButtonIndex = 1 - m.gameVictoryButtonIndex
            updateGameVictoryButtonFocus()
            return true
        else if key = "OK"
            if m.gameVictoryButtonIndex = 0
                m.gameVictoryModal.visible = false
                m.gameVictoryModalOpen = false
                loadGameStage(1)
            else
                m.gameVictoryModal.visible = false
                m.gameVictoryModalOpen = false
                m.focusArea = "sidebar"
                refreshMenuSelectionVisuals()
            end if
            return true
        else if key = "back"
            m.gameVictoryModal.visible = false
            m.gameVictoryModalOpen = false
            m.focusArea = "sidebar"
            refreshMenuSelectionVisuals()
            return true
        end if
        return false
    end if

    ' 4. Tecla BACK (Pausa / Retorna ao Menu Lateral)
    if key = "back"
        m.focusArea = "sidebar"
        refreshMenuSelectionVisuals()
        return true
    end if

    ' 5. Tecla * (Opções): Abre a Lojinha do Grande Dirigível
    if key = "options" or key = "info"
        openGameShop()
        return true
    end if

    ' 6. Tecla Replay (↺) ou Play: Ativa o Casco Protetor de Cristal do Pagonix
    if key = "replay" or key = "play"
        activatePagonixShield()
        return true
    end if

    ' Atalhos de Navegação de Fases: Avançar (>>) e Voltar (<<)
    if key = "forward" or key = "fastforward"
        if m.gameCurrentStage < 40
            loadGameStage(m.gameCurrentStage + 1)
        else
            triggerGrandVictory()
        end if
        return true
    else if key = "rewind" or key = "reverse"
        if m.gameCurrentStage > 1
            loadGameStage(m.gameCurrentStage - 1)
        end if
        return true
    end if

    ' 7. Tecla OK: Ataque / Feixe de Luz do Colar do Começo e Interação
    if key = "OK"
        maxDist = m.beamRange
        if maxDist < 1 then maxDist = 1

        hitAnyMonster = false

        for dist = 1 to maxDist
            targetBeamX = m.playerX
            targetBeamY = m.playerY

            if m.playerDir = "up"
                targetBeamY = targetBeamY - dist
            else if m.playerDir = "down"
                targetBeamY = targetBeamY + dist
            else if m.playerDir = "left"
                targetBeamX = targetBeamX - dist
            else if m.playerDir = "right"
                targetBeamX = targetBeamX + dist
            end if

            if targetBeamX < 0 or targetBeamX > 14 or targetBeamY < 0 or targetBeamY > 7 then exit for
            char = Mid(m.currMap[targetBeamY], targetBeamX + 1, 1)
            if char = "W" then exit for

            ' Mostra o feixe de luz do Colar
            if m.gameAttackBeam <> invalid
                m.gameAttackBeam.translation = [targetBeamX * 80 + 83, targetBeamY * 70 + 55]
                m.gameAttackBeam.visible = true
                if m.gameAttackTimer <> invalid then m.gameAttackTimer.control = "start"
            end if

            ' Checa combate contra monstros na célula alvejada
            for each mon in m.monsters
                if mon.alive and mon.x = targetBeamX and mon.y = targetBeamY
                    hitAnyMonster = true
                    mon.hp = mon.hp - 1
                    if mon.hp <= 0
                        mon.alive = false
                        m.gameScore = m.gameScore + 100

                        if mon.type = "boss" and m.gameCurrentStage = 40
                            triggerGrandVictory()
                            return true
                        end if

                        ' Gera drop do monstro purificado
                        if m.drops.count() < 4
                            dropType = "gem"
                            if m.hp < m.maxHp and Rnd(2) = 1
                                dropType = "heart"
                            end if
                            m.drops.push({
                                id: m.drops.count(),
                                x: mon.x,
                                y: mon.y,
                                type: dropType,
                                active: true
                            })
                            renderDrops()
                        end if

                        updateGameHUD()
                        renderMonsters()
                        setGameDialog("KOLI & PAGONIX", "pkg:/images/lore/colar.png", "✨ O feixe de luz do Colar purificou o monstro! As trevas se dissiparam! (+100 pts)")
                    else
                        setGameDialog("KOLI", "pkg:/images/characters/koli.png", "⚡ O ataque enfraqueceu o monstro! Continue atacando!")
                    end if
                    exit for
                end if
            end for

            ' Checa interação com objetos na célula alvejada
            handleStageObjectInteraction(targetBeamX, targetBeamY)

            if hitAnyMonster then exit for
        end for
        return true
    end if

    ' 8. Movimentação (D-Pad)
    targetX = m.playerX
    targetY = m.playerY

    if key = "up"
        m.playerDir = "up"
        targetY = targetY - 1
    else if key = "down"
        m.playerDir = "down"
        targetY = targetY + 1
    else if key = "left"
        m.playerDir = "left"
        targetX = targetX - 1
    else if key = "right"
        m.playerDir = "right"
        targetX = targetX + 1
    else
        return false
    end if

    ' Limites da grade
    if targetX < 0 or targetX > 14 or targetY < 0 or targetY > 7 then return true

    char = Mid(m.currMap[targetY], targetX + 1, 1)

    ' Colisões com Paredes e Objetos Sólidos
    if char = "W" or char = "A" or char = "C" or char = "K" or char = "M" or char = "T"
        ' Se colidiu tentando andar contra um objeto interativo, aciona a interação!
        if char <> "W"
            handleStageObjectInteraction(targetX, targetY)
        end if
        return true
    end if

    ' Barreira Sombria intransponível se não dissipada
    if char = "B" and not m.stageBarrierCleared
        setGameDialog("KOLI", "pkg:/images/characters/koli.png", "Koli: 'A barreira da Dark Team está muito forte! Precisamos ativar o mecanismo da sala para dissolvê-la!'")
        return true
    end if

    ' Armadilha de Espinhos
    if char = "X" and not m.shieldActive
        damagePlayer()
    end if

    ' Portais de Saída / Conclusão de Fase
    if char = "D"
        if m.gameCurrentStage = 40
            triggerGrandVictory()
        else
            triggerStageClear()
        end if
        return true
    end if

    ' Movimentação válida
    m.pagonixX = m.playerX
    m.pagonixY = m.playerY
    m.playerX = targetX
    m.playerY = targetY

    updateGameEntitiesPosition()

    ' Se pisou em interruptor de piso 'S', ativa o interruptor imediatamente!
    if char = "S" and not m.stageSwitchActivated
        m.stageSwitchActivated = true
        m.stageBarrierCleared = true
        m.gameScore = m.gameScore + 50
        updateGameHUD()
        renderStageTiles()
        setGameDialog("KOLI & PAGONIX", "pkg:/images/lore/colar.png", "⚡ Você pisou no interruptor ancestral! As barreiras da sala foram desativadas!")
    end if

    ' Checa coleta de drops na célula alcançada
    for each drop in m.drops
        if drop.active and drop.x = m.playerX and drop.y = m.playerY
            drop.active = false
            renderDrops()
            if drop.type = "gem"
                m.gameGems = m.gameGems + 10
                m.gameScore = m.gameScore + 50
                setGameDialog("KOLI & PAGONIX", "pkg:/images/game/item_gem.png", "💎 Você coletou 10 Gemas de Aether! Saldo: " + m.gameGems.toStr() + " gemas! (Abra a Lojinha com a tecla *)")
            else
                if m.hp < m.maxHp then m.hp = m.hp + 1
                m.gameScore = m.gameScore + 25
                setGameDialog("PAGONIX", "pkg:/images/game/item_heart.png", "❤️ Coração de Aether coletado! +1 Cristal de Vida recuperado!")
            end if
            m.storage.saveGameData(m.gameGems, m.maxHp, m.beamRange, m.potionsCount, m.highestStage)
            updateGameHUD()
            exit for
        end if
    end for

    ' Checa colisão com monstros no destino
    for each mon in m.monsters
        if mon.alive and mon.x = m.playerX and mon.y = m.playerY
            if m.shieldActive
                mon.x = mon.x - mon.dirX
                setGameDialog("PAGONIX", "pkg:/images/game/pagonix_shield.png", "🛡️ O monstro tocou no domo de cristal do Pagonix e foi repelido!")
            else
                damagePlayer()
            end if
            exit for
        end if
    end for

    return true
end function

sub handleStageObjectInteraction(tx as Integer, ty as Integer)
    ' Verifica interação tanto na frente quanto na célula de Koli
    coords = [[tx, ty], [m.playerX, m.playerY]]

    for each c in coords
        cx = c[0]
        cy = c[1]
        if cx >= 0 and cx <= 14 and cy >= 0 and cy <= 7
            char = Mid(m.currMap[cy], cx + 1, 1)

            ' 1. Baú 'C'
            if char = "C" and not m.stageChestOpened
                m.stageChestOpened = true
                m.shardsCount = m.shardsCount + 1
                m.gameScore = m.gameScore + 150
                m.hasKey = true
                updateGameHUD()
                renderStageTiles()
                setGameDialog("KOLI", "pkg:/images/characters/koli.png", "✨ Você abriu o Baú Ancestral e obteve o FRAGMENTO DE CRISTAL DE AETHER! (+150 pts)")
                return

            ' 2. Botão de Piso / Switch 'S' (Fase 2)
            else if char = "S" and not m.stageSwitchActivated
                m.stageSwitchActivated = true
                m.stageBarrierCleared = true
                m.gameScore = m.gameScore + 50
                updateGameHUD()
                renderStageTiles()
                setGameDialog("KOLI & PAGONIX", "pkg:/images/lore/colar.png", "⚡ O interruptor ancestral foi acionado! As barreiras da Dark Team foram desativadas!")
                return

            ' 3. Altar de Luz 'A'
            else if char = "A"
                if m.gameCurrentStage = 40
                    m.stageAltarsCount = m.stageAltarsCount + 1
                    m.gameScore = m.gameScore + 200
                    updateGameHUD()
                    renderStageTiles()
                    if m.stageAltarsCount >= 4
                        ' Derrota o Chefe Final!
                        for each mon in m.monsters
                            mon.alive = false
                        end for
                        renderMonsters()
                        triggerGrandVictory()
                    else
                        setGameDialog("KOLI", "pkg:/images/lore/colar.png", "✨ Altar Sagrado (" + m.stageAltarsCount.toStr() + "/4) Ativado! O poder de Aether está sobrecarregando o Vórtice Sombrio!")
                    end if
                    return
                else if not m.stageAltarActivated
                    m.stageAltarActivated = true
                    m.stageBarrierCleared = true
                    m.stageAltarsCount = m.stageAltarsCount + 1
                    m.gameScore = m.gameScore + 100
                    updateGameHUD()
                    renderStageTiles()
                    setGameDialog("KOLI", "pkg:/images/lore/colar.png", "⚡ O Colar do Começo ressoa com o Altar! A luz ancestral purificou o ambiente e removeu as barreiras!")
                    return
                end if

            ' 4. Gaiola com Kurion 'K' (Fase 3)
            else if char = "K" and not m.stageKurionRescued
                m.stageKurionRescued = true
                m.kurionsRescued = m.kurionsRescued + 1
                m.hp = 3 ' Cura total!
                m.gameScore = m.gameScore + 200
                updateGameHUD()
                renderStageTiles()
                setGameDialog("PAGONIX", "pkg:/images/kurions/pagonix.png", "PAGO! PAGO! O Kurion bebê foi libertado da gaiola e restaurou toda a sua vida! (+200 pts)")
                return

            ' 5. Motores de Cristal 'M' (Fase 4)
            else if char = "M"
                m.stageMotorsCount = m.stageMotorsCount + 1
                m.gameScore = m.gameScore + 100
                updateGameHUD()
                if m.stageMotorsCount >= 3
                    m.stageBarrierCleared = true
                    renderStageTiles()
                    setGameDialog("KOLI & PAGONIX", "pkg:/images/lore/dirigivel.png", "⚡ Todos os 3 Motores de Cristal foram reativados! As barreiras se abriram! Siga para a ponte de comando!")
                else
                    setGameDialog("KOLI", "pkg:/images/lore/dirigivel.png", "⚡ Motor de Cristal reativado (" + m.stageMotorsCount.toStr() + "/3)! O dirigível está ganhando altitude!")
                end if
                return

            ' 6. Tábua Ancestral 'T' (Fase 1)
            else if char = "T"
                setGameDialog("INSCRIÇÃO ANCESTRAL", "pkg:/images/lore/colar.png", "📜 'Aquele que empunha o Colar do Começo: direcione sua luz para expurgar as trevas e despertar os guardiões dos céus.'")
                return
            end if
        end if
    end for
end sub

sub triggerStageClear()
    nextStage = m.gameCurrentStage + 1
    if nextStage <= 40 and nextStage > m.highestStage
        m.highestStage = nextStage
        m.storage.saveGameData(m.gameGems, m.maxHp, m.beamRange, m.potionsCount, m.highestStage)
    end if

    m.stageClearTitle.text = "✨ FASE " + m.gameCurrentStage.toStr() + "/40 CONCLUÍDA! ✨"
    m.stageClearDesc.text = "Você superou os desafios de " + m.stageNames[m.gameCurrentStage - 1] + "! Pontuação atual: " + m.gameScore.toStr() + " pts."
    m.gameStageClearModal.visible = true
    m.gameStageClearModalOpen = true
end sub

sub triggerGrandVictory()
    setGameDialog("CHALICRFAX", "pkg:/images/kurions/chalicrfax.png", "🦅 CHALICRFAX SURGE NOS CÉUS DE AETHER! O Vórtice Sombrio foi purificado para sempre!")
    m.gameVictoryModal.visible = true
    m.gameVictoryModalOpen = true
    m.gameVictoryButtonIndex = 0
    updateGameVictoryButtonFocus()
end sub
