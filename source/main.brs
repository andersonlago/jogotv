' Ponto de entrada do canal Roku
' Kurions — Saga Origens & A Lenda de Aether
sub Main()
    ' Cria a tela SceneGraph
    screen = CreateObject("roSGScreen")
    m.port = CreateObject("roMessagePort")
    screen.SetMessagePort(m.port)
    
    ' Cria e exibe a cena principal do aplicativo (com menu integrado)
    scene = screen.CreateScene("MainScene")
    screen.Show()
    
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
' CARREGAMENTO DE DADOS DO STORYBOARD
' ============================================

function LoadStoryData() as Object
    raw = ReadAsciiFile("pkg:/story_data.json")
    if raw <> invalid and Len(raw) > 0 then
        parsed = ParseJson(raw)
        if parsed <> invalid then return parsed
    end if
    return {
        capitulo_1: {
            titulo: "O Despertar das Sombras",
            cenas: [
                {
                    id: "cena_01",
                    duracao_segundos: 5,
                    fundo: {
                        tipo: "gradiente",
                        cores: ["#0f0c29", "#302b63", "#24243e"]
                    },
                    elementos: [
                        {
                            tipo: "texto",
                            conteudo: "Há milênios, Aether dormia...",
                            posicao: { x: 300, y: 100 }
                        }
                    ]
                }
            ]
        }
    }
end function
